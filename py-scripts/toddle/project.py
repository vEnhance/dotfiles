"""uv init, license, and pyproject.toml manipulation."""

import re
import subprocess
import sys
from datetime import date
from pathlib import Path

from jinja2 import Environment, FileSystemLoader

from .utils import ansi

TEMPLATES_DIR = Path(__file__).parent / "templates"


def insert_after_authors(text: str, new_line: str) -> str:
    """Insert a line after the authors field (handles multiline arrays).

    Falls back to before 'dependencies', then after '[project]'.
    """
    result = re.sub(
        r"(^authors\s*=\s*\[[^\]]*\])",
        f"\\1\n{new_line}",
        text,
        flags=re.MULTILINE,
    )
    if result != text:
        return result
    result = re.sub(
        r"(^dependencies\s*=)",
        f"{new_line}\n\\1",
        text,
        flags=re.MULTILINE,
    )
    if result != text:
        return result
    return re.sub(r"(\[project\][ \t]*\n)", f"\\1{new_line}\n", text)


def get_python_version(repo_root: Path) -> str:
    """Get current Python version as 'major.minor' (or pinned string)."""
    pv_file = repo_root / ".python-version"
    if pv_file.exists():
        return pv_file.read_text().strip()
    result = subprocess.run(
        [
            "python3",
            "-c",
            "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def run_uv_init(repo_root: Path) -> None:
    """Initialize a uv project and set the repository URL in pyproject.toml."""
    if (repo_root / "uv.lock").exists():
        print(
            ansi("Error: uv.lock already exists; -u/--uv requires a fresh repo", "1;31")
        )
        sys.exit(1)

    python_version = get_python_version(repo_root)
    subprocess.run(
        ["uv", "init", "--author-from", "git", "-p", python_version],
        check=True,
    )
    print(f"Ran: uv init --author-from git -p {python_version}")

    dirname = repo_root.name
    repo_url = f"https://github.com/vEnhance/{dirname}"
    pyproject = repo_root / "pyproject.toml"
    if pyproject.exists():
        text = pyproject.read_text()
        if not re.search(r"(?m)^urls\s*=", text):
            text = insert_after_authors(text, f'urls = {{ repository = "{repo_url}" }}')
            pyproject.write_text(text)
            print(f"Set repository URL: {repo_url}")


def add_license(repo_root: Path) -> None:
    """Write MIT LICENSE and add license field to pyproject.toml if absent."""
    env = Environment(
        loader=FileSystemLoader(TEMPLATES_DIR),
        keep_trailing_newline=True,
    )
    license_text = env.get_template("LICENSE").render(year=date.today().year)
    (repo_root / "LICENSE").write_text(license_text)
    print("Wrote LICENSE")

    pyproject = repo_root / "pyproject.toml"
    if pyproject.exists():
        text = pyproject.read_text()
        if not re.search(r"(?im)^license\s*=", text):
            text = insert_after_authors(text, 'license = { text = "MIT" }')
            pyproject.write_text(text)
            print('Added license = { text = "MIT" } to pyproject.toml')
