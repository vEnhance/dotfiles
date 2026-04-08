"""GitHub Actions workflow detection and rendering."""

import re
import sys
import tomllib
from pathlib import Path

from jinja2 import Environment, FileSystemLoader

from .utils import ansi

TEMPLATES_DIR = Path(__file__).parent / "templates"
WORKFLOWS_TEMPLATES_DIR = TEMPLATES_DIR / "workflows"


def _normalize(name: str) -> str:
    """Normalize a package name per PEP 503 (lowercase, collapse [-_.] to -)."""
    return re.sub(r"[-_.]", "-", name).lower()


def _dep_name(spec: str) -> str:
    """Extract the bare package name from a PEP 508 dependency string."""
    return re.split(r"[>=<!;\[\s]", spec.strip(), maxsplit=1)[0]


def _pyproject_has_dep(repo_root: Path, package: str) -> bool:
    """Return True if pyproject.toml lists package as a dependency in any group."""
    pyproject = repo_root / "pyproject.toml"
    if not pyproject.exists():
        return False
    with open(pyproject, "rb") as f:
        data = tomllib.load(f)

    target = _normalize(package)
    all_deps: list[str] = []
    all_deps.extend(data.get("project", {}).get("dependencies", []))
    for group in data.get("project", {}).get("optional-dependencies", {}).values():
        all_deps.extend(group)
    for group in data.get("dependency-groups", {}).values():
        all_deps.extend(d for d in group if isinstance(d, str))

    return any(_normalize(_dep_name(dep)) == target for dep in all_deps)


def detect_and_write_workflows(
    repo_root: Path,
    github_workflows: bool,
    django_deploy: bool,
    coveralls: bool,
    conv_commit: bool,
) -> None:
    """Detect project type and write appropriate GitHub Actions workflows."""
    uv_lock_exists = (repo_root / "uv.lock").exists()
    is_django = uv_lock_exists and _pyproject_has_dep(repo_root, "django")

    if django_deploy and not is_django:
        print(
            ansi(
                "Error: -d/--django-deploy requires a Django project (django not found in pyproject.toml)",
                "1;31",
            )
        )
        sys.exit(1)

    workflows_dir = repo_root / ".github" / "workflows"

    env = Environment(
        loader=FileSystemLoader(WORKFLOWS_TEMPLATES_DIR),
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
    )

    has_pytest_xdist = _pyproject_has_dep(repo_root, "pytest-xdist")
    has_pytest_cov = _pyproject_has_dep(repo_root, "pytest-cov")

    if django_deploy:
        top_env = Environment(
            loader=FileSystemLoader(TEMPLATES_DIR),
            trim_blocks=True,
            lstrip_blocks=True,
            keep_trailing_newline=True,
        )
        content = top_env.get_template("Makefile.j2").render(
            has_pytest_xdist=has_pytest_xdist,
            has_pytest_cov=has_pytest_cov,
        )
        (repo_root / "Makefile").write_text(content)
        print("Wrote Makefile")

    if github_workflows:
        workflows_dir.mkdir(parents=True, exist_ok=True)

        if is_django:
            content = env.get_template("django.yml.j2").render(
                has_deploy=django_deploy,
                has_coveralls=coveralls,
            )
            django_filename = "django-deploy.yml" if django_deploy else "django.yml"
            (workflows_dir / django_filename).write_text(content)
            print(f"Wrote .github/workflows/{django_filename}")
        else:
            if (repo_root / "prek.toml").exists():
                content = env.get_template("prek.yml.j2").render(has_uv=uv_lock_exists)
                (workflows_dir / "prek.yml").write_text(content)
                print("Wrote .github/workflows/prek.yml")

            if uv_lock_exists and _pyproject_has_dep(repo_root, "pytest"):
                content = env.get_template("pytest.yml.j2").render(
                    has_pytest_xdist=has_pytest_xdist,
                    has_pytest_cov=has_pytest_cov,
                )
                (workflows_dir / "pytest.yml").write_text(content)
                print("Wrote .github/workflows/pytest.yml")

    # conv-commit: overwrite if already present, or create if -c flag set
    conv_commit_path = workflows_dir / "conv-commit.yml"
    if conv_commit_path.exists() or conv_commit:
        workflows_dir.mkdir(parents=True, exist_ok=True)
        content = env.get_template("conv-commit.yml.j2").render()
        conv_commit_path.write_text(content)
        print("Wrote .github/workflows/conv-commit.yml")
