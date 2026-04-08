"""toddle - Generate prek.toml for the current git repository.

Name explanation: Originally was going to name it pre-prek,
but pre-K is short for pre-kindergarten, so I called it "toddle" instead.
(Because a toddler is a really small child.)

Run from the root of any git repository.
Reads toddle/templates/prek.toml as the skeleton and writes a tailored
prek.toml based on what's present in the repo.
Preserves any existing local hooks from a pre-existing prek.toml.
"""

import argparse
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from toddle.prek import render_prek_workflow, write_prek_toml  # noqa: E402
from toddle.project import add_license, run_uv_init  # noqa: E402
from toddle.utils import ansi  # noqa: E402

DOTFILES_ROOT = Path(__file__).parent.parent.parent
RUMDL_CONFIG = DOTFILES_ROOT / "config" / "rumdl" / "rumdl.toml"
TEMPLATES_DIR = Path(__file__).parent / "templates"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate prek.toml for a git repository."
    )
    parser.add_argument(
        "-g",
        "--github",
        action="store_true",
        help="Also write .github/workflows/prek.yml",
    )
    parser.add_argument(
        "-r",
        "--rumdl",
        action="store_true",
        help="Copy ~/dotfiles/config/rumdl/rumdl.toml to rumdl.toml",
    )
    parser.add_argument(
        "-u",
        "--uv",
        action="store_true",
        help="Run uv init (fails if uv.lock already present) and set repository URL",
    )
    parser.add_argument(
        "-l",
        "--license",
        action="store_true",
        help="Write MIT LICENSE and add license field to pyproject.toml",
    )
    parser.add_argument(
        "-i",
        "--init",
        action="store_true",
        help="Short for -ugrl (uv + github workflow + rumdl + license)",
    )
    parser.add_argument(
        "-c",
        "--conv-commit",
        action="store_true",
        help="Write .github/workflows/conv-commit.yml",
    )
    args = parser.parse_args()

    if args.init:
        args.uv = args.github = args.rumdl = args.license = True

    # Enforce git root with at least one commit
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            check=True,
        )
        git_root = Path(result.stdout.strip()).resolve()
        if git_root != Path.cwd().resolve():
            print(ansi("Error: must be run from the root of a git repository", "1;31"))
            sys.exit(1)
        subprocess.run(
            ["git", "rev-parse", "HEAD"],
            capture_output=True,
            check=True,
        )
    except subprocess.CalledProcessError:
        print(ansi("Error: not in a git repository with at least one commit", "1;31"))
        sys.exit(1)

    repo_root = Path.cwd()

    # -u: uv init (before prek.toml so uv.lock exists for detection)
    if args.uv:
        run_uv_init(repo_root)

    # -l: MIT license
    if args.license:
        add_license(repo_root)

    # -r: copy rumdl config
    if args.rumdl:
        dest = repo_root / "rumdl.toml"
        dest.write_text(RUMDL_CONFIG.read_text())
        print("Wrote rumdl.toml")

    prek_toml_is_new, has_uv_lock = write_prek_toml(repo_root)

    # -g: GitHub Actions workflow
    workflows_dir = repo_root / ".github" / "workflows"
    if args.github:
        workflows_dir.mkdir(parents=True, exist_ok=True)
        (workflows_dir / "prek.yml").write_text(render_prek_workflow(has_uv_lock))
        print("Wrote .github/workflows/prek.yml")
    elif prek_toml_is_new or not workflows_dir.exists():
        print(
            "Note: no .github/workflows/ directory found; pass -g to create a prek workflow."
        )

    if args.conv_commit:
        workflows_dir.mkdir(parents=True, exist_ok=True)
        (workflows_dir / "conv-commit.yml").write_text(
            (TEMPLATES_DIR / "conv-commit.yml.j2").read_text()
        )
        print("Wrote .github/workflows/conv-commit.yml")


if __name__ == "__main__":
    main()
