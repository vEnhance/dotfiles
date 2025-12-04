#!/usr/bin/env python3
"""
🥭 MANGO 🥭

Line wrapper that intelligently wraps long lines at natural break points
for Markdown and LaTeX files. Wraps at sentence endings, commas, and
semicolons while preserving code blocks, headers, math environments,
and other special constructs.
"""

import argparse
import re
import sys
from enum import Enum
from pathlib import Path
from typing import List, Optional

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
        if is_fence_marker(line):
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


def is_latex_command_line(line: str) -> bool:
    """
    Check if a LaTeX line starts with a backslash command.
    These lines should never be wrapped.

    Examples: \\section{...}, \\item, \\usepackage{...}
    """
    stripped = line.lstrip()
    return stripped.startswith("\\")


def get_latex_indent(line: str) -> str:
    """
    Get the indentation (leading whitespace) of a LaTeX line.
    This will be preserved on continuation lines.
    """
    return line[: len(line) - len(line.lstrip())]


def is_header(line: str) -> bool:
    """Check if line is a markdown header."""
    return line.lstrip().startswith("#")


def is_fence_marker(line: str) -> bool:
    """Check if line is a fenced code block marker (```)."""
    stripped = line.lstrip()
    return stripped.startswith("```")


def is_indented_code(line: str) -> bool:
    """Check if line is indented code (4+ spaces at start)."""
    if not line or line.isspace():
        return False
    # Count leading spaces
    spaces = len(line) - len(line.lstrip(" "))
    return spaces >= MARKDOWN_INDENTED_CODE_SPACES


def is_list_item(line: str) -> bool:
    """Check if line is a list item."""
    stripped = line.lstrip()
    # Unordered lists: -, *, +
    if stripped and stripped[0] in "-*+" and len(stripped) > 1 and stripped[1] == " ":
        return True
    # Ordered lists: 1., 2., etc.
    if re.match(r"^\d+\.\s", stripped):
        return True
    return False


def is_blockquote(line: str) -> bool:
    """Check if line is a blockquote."""
    stripped = line.lstrip()
    return stripped.startswith(">")


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
) -> Optional[int]:
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
) -> List[str]:
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
        elif is_blockquote(content):
            match = re.match(r"^(\s*>+\s*)", content)
            if match:
                prefix = match.group(0)
                content = content[len(prefix) :]
        else:
            prefix = indent
            content = stripped

        return content, prefix


def process_file(filepath: Path, dry_run: bool = False) -> None:
    """Process a single file (Markdown or LaTeX)."""
    file_type = detect_file_type(filepath)

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {filepath}: {e}", file=sys.stderr)
        return

    output_lines = []
    env_tracker = EnvironmentTracker(file_type)

    for line in lines:
        # Detect frontmatter headers and don't wrap those
        if re.match(r"^[a-zA-Z_]+:", line):
            output_lines.append(line)
            continue

        env_tracker.process_line(line)

        if env_tracker.is_protected():
            output_lines.append(line)
            continue

        if file_type == FileType.MARKDOWN:
            if is_header(line) or is_indented_code(line) or not line.strip():
                output_lines.append(line)
                continue
        else:  # FileType.LATEX
            if is_latex_command_line(line) or not line.strip():
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
                if file_type == FileType.LATEX:
                    continuation_prefix = prefix
                elif is_blockquote(line_stripped):
                    continuation_prefix = prefix
                else:
                    continuation_prefix = " " * len(prefix)
                output_lines.append(continuation_prefix + wrapped_line + "\n")

    if dry_run:
        print(f"=== {filepath} ===")
        print("".join(output_lines))
    else:
        try:
            with open(filepath, "w", encoding="utf-8") as f:
                f.writelines(output_lines)
        except Exception as e:
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
