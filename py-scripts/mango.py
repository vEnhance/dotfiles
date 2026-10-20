#!/usr/bin/python3
"""
🥭 MANGO 🥭

Line wrapper that intelligently wraps long lines at natural break points
for Markdown and LaTeX files. Wraps at sentence endings, commas, and
semicolons while preserving code blocks, headers, math environments,
and other special constructs.
"""

import argparse
import io
import re
import sys
from enum import Enum
from pathlib import Path

MIN_WIDTH = 30  # Minimum width for left part of break
PREF_WIDTH = 80  # Target width when wrapping lines
THRESH_WIDTH = 88  # Lines <= 88 chars never wrap
MAX_WIDTH = 110  # Maximum line width / tier 2 threshold
MARKDOWN_INDENTED_CODE_SPACES = 4  # Number of spaces for indented code blocks


class FileType(Enum):
    """Supported file types."""

    MARKDOWN = "markdown"
    LATEX = "latex"


def detect_file_type(filepath: Path) -> FileType:
    """
    Detect file type based on file extension.

    Args:
        filepath: Path to the file

    Returns:
        FileType enum value
    """
    suffix = filepath.suffix.lower()
    if suffix in [".tex", ".latex"]:
        return FileType.LATEX
    elif suffix in [".md", ".markdown"]:
        return FileType.MARKDOWN
    else:
        # Default to Markdown for backward compatibility
        return FileType.MARKDOWN


class EnvironmentTracker:
    """
    Tracks whether we're inside special environments that should not be wrapped.
    Handles both Markdown and LaTeX environments.
    """

    def __init__(self, file_type: FileType):
        self.file_type = file_type
        self.in_fenced_code = False
        self.in_display_math = False  # For Markdown $$ blocks
        self.latex_env_stack = []  # Stack of LaTeX environment names

    def is_protected(self) -> bool:
        """Check if we're currently in any protected environment."""
        return (
            self.in_fenced_code or self.in_display_math or len(self.latex_env_stack) > 0
        )

    def process_line_markdown(self, line: str) -> None:
        """Update state based on a Markdown line."""
        if line.strip().startswith(r"```"):
            self.in_fenced_code = not self.in_fenced_code
            return

        stripped = line.strip()
        if stripped.startswith("$$"):
            if stripped.endswith("$$") and len(stripped) > 2:
                pass  # Single-line $$ block
            else:
                self.in_display_math = not self.in_display_math

    def process_line_latex(self, line: str) -> None:
        """Update state based on a LaTeX line."""
        stripped = line.strip()

        if stripped == r"\[":
            self.latex_env_stack.append("displaymath_bracket")
        elif (
            stripped == r"\]"
            and self.latex_env_stack
            and self.latex_env_stack[-1] == "displaymath_bracket"
        ):
            self.latex_env_stack.pop()

        begin_match = re.match(r"\\begin\{([^}]+)\}", stripped)
        if begin_match:
            env_name = begin_match.group(1)
            protected_envs = {
                "asy",
                "equation",
                "equation*",
                "align",
                "align*",
                "gather",
                "gather*",
                "multline",
                "multline*",
                "verbatim",
                "lstlisting",
                "minted",
                "Verbatim",
            }
            if env_name in protected_envs:
                self.latex_env_stack.append(env_name)

        end_match = re.match(r"\\end\{([^}]+)\}", stripped)
        if end_match:
            env_name = end_match.group(1)
            if self.latex_env_stack and self.latex_env_stack[-1] == env_name:
                self.latex_env_stack.pop()

    def process_line(self, line: str) -> None:
        """Process a line and update state based on file type."""
        if self.file_type == FileType.MARKDOWN:
            self.process_line_markdown(line)
        else:  # FileType.LATEX
            self.process_line_latex(line)


def get_latex_indent(line: str) -> str:
    """
    Get the indentation (leading whitespace) of a LaTeX line.
    This will be preserved on continuation lines.
    """
    return line[: len(line) - len(line.lstrip())]


def is_indented_code(line: str) -> bool:
    r"""Check if line is indented code (4+ spaces at start).

    >>> is_indented_code("    code here"), is_indented_code("        deeper")
    (True, True)
    >>> is_indented_code("   only three"), is_indented_code("plain text")
    (False, False)
    >>> is_indented_code(""), is_indented_code("   \n")
    (False, False)
    """
    if not line or line.isspace():
        return False
    # Count leading spaces
    spaces = len(line) - len(line.lstrip(" "))
    return spaces >= MARKDOWN_INDENTED_CODE_SPACES


def is_list_item(line: str) -> bool:
    """Check if line is a list item.

    >>> [is_list_item(s) for s in ["- a", "* a", "+ a", "1. a", "42. a", "  - a"]]
    [True, True, True, True, True, True]
    >>> [is_list_item(s) for s in ["just text", "-no space", "*no space"]]
    [False, False, False]
    """
    stripped = line.lstrip()
    # Unordered lists: -, *, +
    if stripped and stripped[0] in "-*+" and len(stripped) > 1 and stripped[1] == " ":
        return True
    # Ordered lists: 1., 2., etc.
    return bool(re.match(r"^\d+\.\s", stripped))


def get_indent(line: str) -> str:
    """Get the leading whitespace of a line."""
    return line[: len(line) - len(line.lstrip())]


def is_inside_latex(text: str, position: int) -> bool:
    r"""
    Check if a position in text is inside a LaTeX expression (between $ or $$).
    Handles escaped dollar signs \$.
    """
    dollar_count = 0
    i = 0
    while i < position:
        if text[i] == "$":
            if i > 0 and text[i - 1] == "\\":
                num_backslashes = 0
                j = i - 1
                while j >= 0 and text[j] == "\\":
                    num_backslashes += 1
                    j -= 1
                if num_backslashes % 2 == 1:  # odd = escaped
                    i += 1
                    continue
            dollar_count += 1
        i += 1

    return dollar_count % 2 == 1


def find_break_point(
    text: str,
    available_width: int,
    natural_only: bool = False,
    preferred_width: int | None = None,
) -> int | None:
    """
    Find the optimal break point in text before available_width.
    Priority: sentence endings (. ! ?), then commas/semicolons, then spaces.
    Avoids breaking inside LaTeX expressions (between $ signs).

    Args:
        text: The text to find a break point in
        available_width: Maximum position to break at
        natural_only: If True, only consider sentence/punctuation breaks, not spaces
        preferred_width: Preferred position for space fallback (defaults to available_width)

    Returns the position after the punctuation/space, or None if no break found.

    Sentence endings win, as long as the break is at least MIN_WIDTH in:

    >>> t = "First part of a longer sentence here. And this continues on for a while."
    >>> t[: find_break_point(t, 60)]
    'First part of a longer sentence here. '

    A comma before MIN_WIDTH is ignored, so this falls back to a space:

    >>> t = "First part, second part that goes on and on and on forever."
    >>> t[: find_break_point(t, 50)]
    'First part, second part that goes on and on and on '

    >>> find_break_point("Short line.", 100) is None
    True
    >>> t = "a" * 50 + " " + "b" * 50
    >>> find_break_point(t, 80, natural_only=True) is None
    True
    >>> find_break_point(t, 80)
    51
    """
    if len(text) <= available_width:
        return None

    sentence_breaks = []
    for match in re.finditer(r"[.!?]\s+", text[:available_width]):
        break_pos = match.end()
        if not is_inside_latex(text, break_pos) and break_pos >= MIN_WIDTH:
            sentence_breaks.append(break_pos)

    if sentence_breaks:
        return sentence_breaks[-1]

    punct_breaks = []
    for match in re.finditer(r"[,;:]\s+", text[:available_width]):
        break_pos = match.end()
        if not is_inside_latex(text, break_pos) and break_pos >= MIN_WIDTH:
            punct_breaks.append(break_pos)

    if punct_breaks:
        return punct_breaks[-1]

    if not natural_only:
        search_start = min(
            preferred_width if preferred_width else available_width, len(text) - 1
        )
        for i in range(search_start, MIN_WIDTH - 1, -1):
            if text[i] == " " and not is_inside_latex(text, i + 1):
                return i + 1

    return None


def wrap_paragraph(
    text: str,
    available_width: int = MAX_WIDTH,
    indent: str = "",
    natural_only: bool = False,
    preferred_width: int | None = None,
    preserve_indent: bool = False,
) -> list[str]:
    """
    Wrap a paragraph at natural break points.
    Returns a list of wrapped lines.

    Args:
        text: The text to wrap
        available_width: Maximum width for lines
        indent: String to prepend to each line
        natural_only: If True, only break at natural points (sentences/punctuation), not arbitrary spaces
        preferred_width: Preferred width for space fallback when force-wrapping
        preserve_indent: If True, preserve indent on continuation lines (for LaTeX)

    >>> wrap_paragraph("Short line.")
    ['Short line.']
    >>> for line in wrap_paragraph("This is a sentence. " * 6):
    ...     print(line)
    This is a sentence. This is a sentence. This is a sentence. This is a sentence. This is a sentence.
    This is a sentence.

    The indent goes on every line in LaTeX mode, but only the first in Markdown:

    >>> text = " ".join(["word"] * 30)
    >>> [line[:6] for line in wrap_paragraph(text, 80, "  ", preserve_indent=True)]
    ['  word', '  word']
    >>> [line[:6] for line in wrap_paragraph(text, 80, "  ")]
    ['  word', 'word w']
    """
    if not text or text.isspace():
        return [text] if text else [""]

    lines = []
    remaining = text.strip()

    while remaining:
        # Determine the indent to use for this line
        if preserve_indent or not lines:
            # LaTeX mode: always use indent, OR first line in any mode
            line_indent = indent
        else:
            # Markdown mode continuation lines: no indent
            line_indent = ""

        if len(remaining) <= available_width:
            lines.append(line_indent + remaining)
            break

        break_point = find_break_point(
            remaining, available_width, natural_only, preferred_width
        )

        if break_point is None:
            if natural_only:
                lines.append(line_indent + remaining)
                break
            else:
                next_space = remaining.find(" ", available_width)
                if next_space > 0:
                    break_point = next_space + 1
                else:
                    lines.append(line_indent + remaining)
                    break

        lines.append(line_indent + remaining[:break_point].rstrip())
        remaining = remaining[break_point:].lstrip()

    return lines


def extract_prefix_and_content(
    line_stripped: str, file_type: FileType
) -> tuple[str, str]:
    """
    Extract prefix (list markers, blockquotes, indentation) and content from a line.

    Args:
        line_stripped: Line with trailing whitespace removed
        file_type: Type of file being processed

    Returns:
        Tuple of (content, prefix)

    >>> extract_prefix_and_content("- hello world", FileType.MARKDOWN)
    ('hello world', '- ')
    >>> extract_prefix_and_content("1. hello world", FileType.MARKDOWN)
    ('hello world', '1. ')
    >>> extract_prefix_and_content("> quoted text", FileType.MARKDOWN)
    ('quoted text', '> ')
    >>> extract_prefix_and_content("plain text here", FileType.MARKDOWN)
    ('plain text here', '')
    >>> extract_prefix_and_content("  latex text", FileType.LATEX)
    ('latex text', '  ')
    """
    if file_type == FileType.LATEX:
        # LaTeX: only preserve indentation
        indent = get_latex_indent(line_stripped)
        content = line_stripped[len(indent) :]
        return content, indent
    else:
        # Markdown: handle list items, blockquotes, and indentation
        content = line_stripped
        prefix = ""
        stripped = content.lstrip()
        indent = content[: len(content) - len(stripped)]

        if is_list_item(content):
            match = re.match(r"^(\s*)([-*+]|\d+\.)\s+", content)
            if match:
                prefix = match.group(0)
                content = content[len(prefix) :]
        elif content.strip().startswith("> "):  # blockquote
            match = re.match(r"^(\s*>+\s*)", content)
            if match:
                prefix = match.group(0)
                content = content[len(prefix) :]
        else:
            prefix = indent
            content = stripped

        return content, prefix


def wrap_text(text: str, file_type: FileType) -> str:
    r"""Wrap the long lines of a whole document (Markdown or LaTeX).

    Continuation lines line up under list items and repeat blockquote markers:

    >>> print(wrap_text("- " + "Item text, with commas. " * 5, FileType.MARKDOWN), end="")
    - Item text, with commas. Item text, with commas. Item text, with commas. Item text, with commas.
      Item text, with commas.
    >>> print(wrap_text("> " + "Quoted text, with commas. " * 5, FileType.MARKDOWN), end="")
    > Quoted text, with commas. Quoted text, with commas. Quoted text, with commas. Quoted text, with commas.
    > Quoted text, with commas.

    ``key: value`` lines in the header zone at the top are left alone, even
    past ``---`` delimiters and blank lines:

    >>> s = "title: " + "x" * 200 + "\ndate: 2024-01-01\n\nNormal paragraph.\n"
    >>> wrap_text(s, FileType.MARKDOWN) == s
    True
    >>> s = "---\ntitle: " + "x" * 200 + "\n---\n\nBody text.\n"
    >>> wrap_text(s, FileType.MARKDOWN) == s
    True
    >>> s = "\n\ntitle: " + "x" * 200 + "\n"
    >>> wrap_text(s, FileType.MARKDOWN) == s
    True

    The header zone ends at the first ordinary line, so later ones get wrapped:

    >>> s = "Ends the header zone.\n\nAnswer: " + " ".join(["word"] * 25) + "\n"
    >>> print(wrap_text(s, FileType.MARKDOWN), end="")
    Ends the header zone.
    <BLANKLINE>
    Answer: word word word word word word word word word word word word word word
    word word word word word word word word word word word
    """
    lines = io.StringIO(text).readlines()
    output_lines = []
    env_tracker = EnvironmentTracker(file_type)
    in_header_zone = (
        True  # True until we see a non-header, non-delimiter, non-blank line
    )

    for line in lines:
        stripped = line.strip()

        # Track whether we're still in the frontmatter zone at the top of the file.
        # The zone ends once we encounter a line that isn't a key: value header,
        # a delimiter (--- or ===), or blank whitespace.
        if in_header_zone:
            is_header_line = bool(re.match(r"^[a-zA-Z][a-zA-Z0-9_-]*:\s", line))
            is_delimiter = bool(re.match(r"^[-=]{3,}\s*$", stripped))
            is_blank = not stripped
            if not (is_header_line or is_delimiter or is_blank):
                in_header_zone = False

        if in_header_zone and re.match(r"^[a-zA-Z][a-zA-Z0-9_-]*:\s", line):
            output_lines.append(line)
            continue

        env_tracker.process_line(line)

        if env_tracker.is_protected():
            output_lines.append(line)
            continue

        if file_type == FileType.MARKDOWN:
            if (
                line.lstrip().startswith("#")  # header
                or is_indented_code(line)
                or not line.strip()
            ):
                output_lines.append(line)
                continue
        else:  # FileType.LATEX
            if (
                line.strip().startswith("\\")  # command line
                or line.strip().startswith("%")  # comment
                or not line.strip()
            ):
                output_lines.append(line)
                continue

        # Tier 1: Never wrap
        line_stripped = line.rstrip("\n\r")
        if len(line_stripped) <= THRESH_WIDTH:
            output_lines.append(line)
            continue

        content, prefix = extract_prefix_and_content(line_stripped, file_type)
        preserve_indent = file_type == FileType.LATEX

        # Tier 2: Only wrap if natural break exists
        if len(line_stripped) <= MAX_WIDTH:
            wrapped = wrap_paragraph(
                content,
                MAX_WIDTH - len(prefix),
                "",
                natural_only=True,
                preserve_indent=preserve_indent,
            )
            if len(wrapped) == 1 and wrapped[0].strip() == content.strip():
                output_lines.append(line)
                continue
        else:
            # Tier 3: always wrap, prefer wrapping closer to 80
            wrapped = wrap_paragraph(
                content,
                MAX_WIDTH - len(prefix),
                "",
                preferred_width=PREF_WIDTH - len(prefix),
                preserve_indent=preserve_indent,
            )

        for j, wrapped_line in enumerate(wrapped):
            if j == 0:
                output_lines.append(prefix + wrapped_line + "\n")
            else:
                if file_type == FileType.LATEX or line_stripped.startswith("> "):
                    continuation_prefix = prefix
                else:
                    continuation_prefix = " " * len(prefix)
                output_lines.append(continuation_prefix + wrapped_line + "\n")

    return "".join(output_lines)


def process_file(filepath: Path, dry_run: bool = False) -> None:
    """Process a single file (Markdown or LaTeX)."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            text = f.read()
    except (OSError, UnicodeDecodeError) as e:
        print(f"Error reading {filepath}: {e}", file=sys.stderr)
        return

    output = wrap_text(text, detect_file_type(filepath))

    if dry_run:
        print(f"=== {filepath} ===")
        print(output)
    else:
        try:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(output)
        except (OSError, UnicodeEncodeError) as e:
            print(f"Error writing {filepath}: {e}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(
        prog="mango",
        description="Wrap lines at natural break points for Markdown and LaTeX files",
        epilog="🥭 Once named mangle, but renamed mango as it's shorter and easier to pronounce.",
    )
    parser.add_argument(
        "files",
        nargs="+",
        type=Path,
        help="Markdown (.md, .markdown) or LaTeX (.tex, .latex) files to process",
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Show changes without modifying files"
    )

    args = parser.parse_args()

    for filepath in args.files:
        if not filepath.exists():
            print(f"File not found: {filepath}", file=sys.stderr)
            continue

        if not filepath.is_file():
            print(f"Not a file: {filepath}", file=sys.stderr)
            continue

        process_file(filepath, args.dry_run)


if __name__ == "__main__":
    main()
