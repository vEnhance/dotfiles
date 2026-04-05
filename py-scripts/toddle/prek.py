"""prek.toml generation logic."""

import re
import sys
from pathlib import Path

from jinja2 import Environment, FileSystemLoader

from .utils import ansi

TEMPLATES_DIR = Path(__file__).parent / "templates"
SKELETON = Path(__file__).parent.parent.parent / "prek.toml"

# Always skip these regardless of conditions
SKIP_REPOS = {
    "https://github.com/Vimjas/vint",
}
RUMDL_REPO = "https://github.com/rvben/rumdl-pre-commit"
DJLINT_REPO = "https://github.com/djlint/djLint"
UV_REPO = "https://github.com/astral-sh/uv-pre-commit"
SHELLCHECK_REPO = "https://github.com/shellcheck-py/shellcheck-py"
SHFMT_REPO = "https://github.com/scop/pre-commit-shfmt"


def split_skeleton(text: str) -> tuple[str, list[tuple[str, str]]]:
    """Split prek.toml text into (header, [(repo_url, raw_block), ...])."""
    parts = re.split(r"(?=^\[\[repos\]\])", text, flags=re.MULTILINE)
    header = parts[0].strip()
    blocks = []
    for part in parts[1:]:
        m = re.search(r'^repo\s*=\s*"([^"]+)"', part, re.MULTILINE)
        repo_url = m.group(1) if m else ""
        part = re.sub(r"(?m)^ *#.*\n?", "", part)  # strip comments
        blocks.append((repo_url, part))
    return header, blocks


def strip_pip_compile(block: str) -> str:
    """Remove the pip-compile hook entry from a uv-pre-commit block."""
    block = re.sub(
        r",\s*\n\s*\{[^{}]*id\s*=\s*\"pip-compile\"[^{}]*\}",
        "",
        block,
        flags=re.DOTALL,
    )
    block = re.sub(
        r"hooks\s*=\s*\[\s*\n\s*(\{[^}]+\})\s*\n\s*\]",
        r"hooks = [\1]",
        block,
    )
    return block


def find_preserved_blocks(
    text: str, skeleton_urls: set[str]
) -> tuple[list[tuple[str, str]], set[str]]:
    """Scan existing prek.toml for blocks to preserve verbatim.

    Preserves:
      (i)  repos whose URL is not in the skeleton (unknown/project-specific,
           including repo = "local")
      (ii) repos with internal comments (project-customized)

    Returns (preserved_blocks, override_urls), where override_urls are skeleton
    repos that should be skipped because the project has a customized version.
    """
    parts = re.split(r"(?=^\[\[repos\]\])", text, flags=re.MULTILINE)
    preserved: list[tuple[str, str]] = []
    override_urls: set[str] = set()

    for part in parts:
        if not part.startswith("[[repos]]"):
            continue
        m = re.search(r'^repo\s*=\s*"([^"]+)"', part, re.MULTILINE)
        repo_url = m.group(1) if m else ""

        is_unknown = repo_url not in skeleton_urls
        has_comment = "#" in part

        if is_unknown or has_comment:
            preserved.append((repo_url, part))
            if has_comment and not is_unknown:
                override_urls.add(repo_url)

    return preserved, override_urls


def has_templates_html(repo_root: Path) -> bool:
    for d in repo_root.rglob("templates"):
        if d.is_dir() and any(d.rglob("*.html")):
            return True
    return False


def render_prek_workflow(has_uv: bool) -> str:
    env = Environment(
        loader=FileSystemLoader(TEMPLATES_DIR),
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
    )
    return env.get_template("prek.yml.j2").render(has_uv=has_uv)


def write_prek_toml(repo_root: Path) -> bool:
    """Detect repo conditions, write prek.toml, and return has_uv_lock."""
    has_rumdl = (repo_root / "rumdl.toml").exists() or (
        repo_root / ".rumdl.toml"
    ).exists()
    has_uv_lock = (repo_root / "uv.lock").exists()
    has_requirements = has_uv_lock and (repo_root / "requirements.txt").exists()
    has_templates = has_templates_html(repo_root)
    has_shell = any(repo_root.rglob("*.sh"))

    if has_uv_lock and not (repo_root / ".python-version").exists():
        print(
            ansi(
                "Error: uv.lock found but no .python-version — create one first (e.g. uv python pin 3.14)",
                "1;31",
            )
        )
        sys.exit(1)

    skeleton_text = SKELETON.read_text()
    header, skeleton_blocks = split_skeleton(skeleton_text)
    skeleton_urls = {url for url, _ in skeleton_blocks}

    preserved_blocks: list[tuple[str, str]] = []
    override_urls: set[str] = set()
    existing = repo_root / "prek.toml"
    if existing.exists():
        preserved_blocks, override_urls = find_preserved_blocks(
            existing.read_text(), skeleton_urls
        )

    selected: list[str] = [header]

    for repo_url, block in skeleton_blocks:
        if repo_url in override_urls:
            continue
        skip = (
            repo_url in SKIP_REPOS
            or (repo_url == RUMDL_REPO and not has_rumdl)
            or (repo_url == DJLINT_REPO and not has_templates)
            or (repo_url == UV_REPO and not has_uv_lock)
            or (repo_url in (SHELLCHECK_REPO, SHFMT_REPO) and not has_shell)
        )
        if skip:
            print(f"{ansi('- Skipping:', '33')} {repo_url}")
            continue
        print(f"{ansi('+ Using:', '32')} {repo_url}")
        if repo_url == UV_REPO and not has_requirements:
            block = strip_pip_compile(block)
        selected.append(block)

    for repo_url, block in preserved_blocks:
        print(ansi(f"* Preserving: {repo_url}", "1;36"))
        selected.append(block)

    prek_toml_is_new = not existing.exists()
    existing.write_text("\n\n".join([block.strip() for block in selected]) + "\n")
    print("Wrote prek.toml")

    return prek_toml_is_new, has_uv_lock
