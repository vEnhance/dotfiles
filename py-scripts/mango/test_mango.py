"""Tests for py-scripts/mango.py"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from mango import (
    FileType,
    extract_prefix_and_content,
    find_break_point,
    is_indented_code,
    is_list_item,
    process_file,
    wrap_paragraph,
)

# ---------------------------------------------------------------------------
# is_indented_code
# ---------------------------------------------------------------------------


def test_indented_code_four_spaces():
    assert is_indented_code("    code here")


def test_indented_code_more_spaces():
    assert is_indented_code("        deeply indented")


def test_indented_code_three_spaces_not_code():
    assert not is_indented_code("   only three")


def test_indented_code_no_indent():
    assert not is_indented_code("plain text")


def test_indented_code_blank_line():
    assert not is_indented_code("")
    assert not is_indented_code("   \n")


# ---------------------------------------------------------------------------
# is_list_item
# ---------------------------------------------------------------------------


def test_list_item_dash():
    assert is_list_item("- item")


def test_list_item_star():
    assert is_list_item("* item")


def test_list_item_plus():
    assert is_list_item("+ item")


def test_list_item_ordered():
    assert is_list_item("1. item")
    assert is_list_item("42. item")


def test_list_item_indented():
    assert is_list_item("  - nested")


def test_list_item_not_list():
    assert not is_list_item("just text")
    assert not is_list_item("-no space")
    assert not is_list_item("*no space")


# ---------------------------------------------------------------------------
# find_break_point
# ---------------------------------------------------------------------------


def test_break_point_sentence_end():
    # Sentence break must be >= MIN_WIDTH (30) to be used; put the period later.
    text = "First part of a longer sentence here. And this continues on for a very long time indeed."
    bp = find_break_point(text, 80)
    assert bp is not None
    assert text[:bp].rstrip().endswith(".")


def test_break_point_comma():
    text = "First part, second part that goes on and on and on forever."
    bp = find_break_point(text, 50)
    assert bp is not None
    assert "," in text[:bp]


def test_break_point_returns_none_if_short():
    text = "Short line."
    assert find_break_point(text, 100) is None


def test_break_point_natural_only_no_space_fallback():
    # A long line with no sentence/punct break should return None in natural_only mode
    text = "a" * 50 + " " + "b" * 50
    bp = find_break_point(text, 80, natural_only=True)
    assert bp is None


def test_break_point_space_fallback():
    text = "a" * 50 + " " + "b" * 50
    bp = find_break_point(text, 80, natural_only=False)
    assert bp is not None


# ---------------------------------------------------------------------------
# wrap_paragraph
# ---------------------------------------------------------------------------


def test_wrap_paragraph_short_unchanged():
    text = "Short line."
    result = wrap_paragraph(text, available_width=80)
    assert result == ["Short line."]


def test_wrap_paragraph_wraps_long():
    text = "This is a sentence. " * 6
    result = wrap_paragraph(text.strip(), available_width=80)
    assert len(result) > 1
    for line in result:
        assert len(line) <= 110  # may exceed 80 but stays reasonable


def test_wrap_paragraph_preserves_indent_latex():
    text = "word " * 30
    result = wrap_paragraph(
        text.strip(), available_width=80, indent="  ", preserve_indent=True
    )
    for line in result:
        assert line.startswith("  ")


def test_wrap_paragraph_no_indent_on_continuation_markdown():
    text = "word " * 30
    result = wrap_paragraph(
        text.strip(), available_width=80, indent="  ", preserve_indent=False
    )
    # First line gets indent, subsequent lines do not
    assert result[0].startswith("  ")
    if len(result) > 1:
        assert not result[1].startswith("  ")


# ---------------------------------------------------------------------------
# extract_prefix_and_content
# ---------------------------------------------------------------------------


def test_extract_list_item_dash():
    content, prefix = extract_prefix_and_content("- hello world", FileType.MARKDOWN)
    assert prefix == "- "
    assert content == "hello world"


def test_extract_list_item_ordered():
    content, prefix = extract_prefix_and_content("1. hello world", FileType.MARKDOWN)
    assert prefix == "1. "
    assert content == "hello world"


def test_extract_blockquote():
    content, prefix = extract_prefix_and_content("> quoted text", FileType.MARKDOWN)
    assert prefix == "> "
    assert content == "quoted text"


def test_extract_plain_line():
    content, prefix = extract_prefix_and_content("plain text here", FileType.MARKDOWN)
    assert prefix == ""
    assert content == "plain text here"


def test_extract_latex_indented():
    content, prefix = extract_prefix_and_content("  latex text", FileType.LATEX)
    assert prefix == "  "
    assert content == "latex text"


# ---------------------------------------------------------------------------
# process_file: header zone detection
# ---------------------------------------------------------------------------


def test_header_zone_skips_frontmatter(tmp_path):
    """key: value lines at the top of the file should not be wrapped."""
    long_value = "x" * 200
    md = tmp_path / "test.md"
    md.write_text(f"title: {long_value}\ndate: 2024-01-01\n\nNormal paragraph.\n")
    process_file(md)
    result = md.read_text()
    # The title line should be untouched (not wrapped)
    assert f"title: {long_value}" in result


def test_header_zone_ends_after_content(tmp_path):
    """key: value pattern mid-file should be wrapped if it's long enough."""
    long_value = "word " * 30
    md = tmp_path / "test.md"
    # Put a real paragraph first to exit the header zone, then a key: value line
    md.write_text(
        f"This is a normal paragraph that ends the header zone.\n\nAnswer: {long_value}\n"
    )
    process_file(md)
    result = md.read_text()
    # The Answer: line should have been wrapped (split into multiple lines)
    # The key point: it was NOT simply left as-is because it matched key: pattern
    lines = result.splitlines()
    answer_line = next((ln for ln in lines if ln.startswith("Answer:")), None)
    # If there's an Answer: line it should be shorter than the full content
    # (i.e., it got wrapped), OR there is no single Answer: line (it got split)
    if answer_line:
        assert len(answer_line) < len(f"Answer: {long_value}".rstrip())


def test_header_zone_delimiter_doesnt_exit(tmp_path):
    """--- delimiters should not end the header zone."""
    long_value = "x" * 200
    md = tmp_path / "test.md"
    md.write_text(f"---\ntitle: {long_value}\n---\n\nBody text.\n")
    process_file(md)
    result = md.read_text()
    assert f"title: {long_value}" in result


def test_header_zone_blank_lines_dont_exit(tmp_path):
    """Blank lines at the top should not end the header zone."""
    long_value = "x" * 200
    md = tmp_path / "test.md"
    md.write_text(f"\n\ntitle: {long_value}\n")
    process_file(md)
    result = md.read_text()
    assert f"title: {long_value}" in result


def test_header_zone_normal_sentence_not_exempt(tmp_path):
    """A sentence starting with 'Answer:' deep in the file must not be exempt."""
    # Build a line that's long enough to trigger wrapping (>88 chars)
    filler = "word " * 25  # ~125 chars
    md = tmp_path / "test.md"
    content = f"This paragraph exits the header zone.\n\nAnswer: {filler.strip()}\n"
    md.write_text(content)
    process_file(md)
    result = md.read_text()
    lines = result.splitlines()
    # The Answer: line (if it still starts with Answer:) should be ≤ MAX_WIDTH chars
    # or there should be continuation lines showing it was wrapped
    answer_lines = [ln for ln in lines if ln.startswith("Answer:")]
    other_answer = [ln for ln in lines if "word" in ln and not ln.startswith("Answer:")]
    # Either it was wrapped into multiple lines, or at least the first line is short
    assert answer_lines or other_answer  # something happened to the content
    if answer_lines:
        # If Answer: line exists, it should be shorter than original (wrapped)
        assert len(answer_lines[0]) < len(f"Answer: {filler.strip()}")
