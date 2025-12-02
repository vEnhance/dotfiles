#!/usr/bin/env python3
"""
Markdown line wrapper that intelligently wraps long lines at natural break points
(sentence endings, commas, semicolons) while preserving code blocks, headers, and
YAML frontmatter.
"""

import argparse
import re
import sys
from pathlib import Path
from typing import List, Optional


# Configuration constants
MIN_WIDTH = 30  # Minimum width for left part of break
TIER1_WIDTH = 80  # Lines <= 80 chars never wrap
MAX_WIDTH = 100  # Maximum line width / tier 2 threshold
INDENTED_CODE_SPACES = 4  # Number of spaces for indented code blocks


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
    return spaces >= INDENTED_CODE_SPACES


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
    # Count unescaped dollar signs before the position
    dollar_count = 0
    i = 0
    while i < position:
        if text[i] == "$":
            # Check if it's escaped
            if i > 0 and text[i - 1] == "\\":
                # Check if the backslash itself is escaped
                num_backslashes = 0
                j = i - 1
                while j >= 0 and text[j] == "\\":
                    num_backslashes += 1
                    j -= 1
                # If odd number of backslashes, the $ is escaped
                if num_backslashes % 2 == 1:
                    i += 1
                    continue
            dollar_count += 1
        i += 1

    # Odd number means we're inside LaTeX
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

    # Look for sentence endings first (. ! ? followed by space)
    sentence_breaks = []
    for match in re.finditer(r"[.!?]\s+", text[:available_width]):
        break_pos = match.end()
        if not is_inside_latex(text, break_pos) and break_pos >= MIN_WIDTH:
            sentence_breaks.append(break_pos)

    if sentence_breaks:
        return sentence_breaks[-1]  # Last sentence break before available_width

    # Look for commas or semicolons
    punct_breaks = []
    for match in re.finditer(r"[,;:]\s+", text[:available_width]):
        break_pos = match.end()
        if not is_inside_latex(text, break_pos) and break_pos >= MIN_WIDTH:
            punct_breaks.append(break_pos)

    if punct_breaks:
        return punct_breaks[-1]

    # Fall back to any space (only if not natural_only)
    if not natural_only:
        # Use preferred_width if specified, otherwise use available_width
        search_start = min(
            preferred_width if preferred_width else available_width, len(text) - 1
        )
        for i in range(search_start, MIN_WIDTH - 1, -1):
            if text[i] == " " and not is_inside_latex(text, i + 1):
                return i + 1

    # No good break point found
    return None


def wrap_paragraph(
    text: str,
    available_width: int = MAX_WIDTH,
    indent: str = "",
    natural_only: bool = False,
    preferred_width: int | None = None,
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
    """
    if not text or text.isspace():
        return [text] if text else [""]

    lines = []
    remaining = text.strip()

    while remaining:
        if len(remaining) <= available_width:
            lines.append(indent + remaining)
            break

        break_point = find_break_point(
            remaining, available_width, natural_only, preferred_width
        )

        if break_point is None:
            if natural_only:
                # Natural-only mode: if no natural break found, return as single line
                lines.append(indent + remaining)
                break
            else:
                # Force break at available_width
                # Try to break at next space after available_width
                next_space = remaining.find(" ", available_width)
                if next_space > 0:
                    break_point = next_space + 1
                else:
                    # No space found, just take everything
                    lines.append(indent + remaining)
                    break

        lines.append(indent + remaining[:break_point].rstrip())
        remaining = remaining[break_point:].lstrip()

    return lines


def process_file(filepath: Path, dry_run: bool = False) -> None:
    """Process a single markdown file."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {filepath}: {e}", file=sys.stderr)
        return

    output_lines = []
    in_yaml_frontmatter = False
    in_fenced_code = False

    for i, line in enumerate(lines):
        # Track YAML frontmatter
        if i == 0 and line.strip() == "---":
            in_yaml_frontmatter = True
            output_lines.append(line)
            continue

        if in_yaml_frontmatter:
            output_lines.append(line)
            if line.strip() == "---":
                in_yaml_frontmatter = False
            continue

        # Track fenced code blocks
        if is_fence_marker(line):
            in_fenced_code = not in_fenced_code
            output_lines.append(line)
            continue

        if in_fenced_code:
            output_lines.append(line)
            continue

        # Don't wrap protected content
        if is_header(line) or is_indented_code(line) or not line.strip():
            output_lines.append(line)
            continue

        # Tier 1: Lines ≤80 chars - never wrap
        line_stripped = line.rstrip("\n\r")
        if len(line_stripped) <= TIER1_WIDTH:
            output_lines.append(line)
            continue

        # Extract prefix (list markers, blockquotes, indent) for lines that might need wrapping
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
            # Just preserve indent
            prefix = indent
            content = stripped

        # Tier 2: Lines 81-100 chars - only wrap if natural break exists
        if len(line_stripped) <= MAX_WIDTH:
            wrapped = wrap_paragraph(
                content, MAX_WIDTH - len(prefix), "", natural_only=True
            )
            if len(wrapped) == 1 and wrapped[0].strip() == content.strip():
                # No natural break found, keep original line
                output_lines.append(line)
                continue
            # Natural break found, use wrapped result (fall through to output below)
        else:
            # Tier 3: Lines >100 chars - always wrap, prefer wrapping closer to 80
            wrapped = wrap_paragraph(
                content,
                MAX_WIDTH - len(prefix),
                "",
                preferred_width=TIER1_WIDTH - len(prefix),
            )

        # Output wrapped lines with prefix
        for j, wrapped_line in enumerate(wrapped):
            if j == 0:
                output_lines.append(prefix + wrapped_line + "\n")
            else:
                # Continuation lines: use same prefix for blockquotes, spaces for lists
                if is_blockquote(line_stripped):
                    continuation_prefix = prefix
                else:
                    continuation_prefix = " " * len(prefix)
                output_lines.append(continuation_prefix + wrapped_line + "\n")

    # Write output
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
        description="Wrap markdown lines at natural break points"
    )
    parser.add_argument("files", nargs="+", type=Path, help="Markdown files to process")
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
