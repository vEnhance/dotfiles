"""GitHub Actions workflow detection and rendering."""

import re
import sys
import tomllib
from pathlib import Path

from jinja2 import Environment, FileSystemLoader

from .utils import ansi

TEMPLATES_DIR = Path(__file__).parent / "templates"


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
        print(ansi("Error: -d/--django-deploy but django not found", "1;31"))
        sys.exit(1)

    repo_wf_dir = repo_root / ".github" / "workflows"
    repo_wf_dir.mkdir(parents=True, exist_ok=True)

    env = Environment(
        loader=FileSystemLoader(TEMPLATES_DIR),
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
    )

    ctx = {
        "has_deploy": django_deploy,
        "has_coveralls": coveralls,
        "has_uv": uv_lock_exists,
        "has_pytest_xdist": _pyproject_has_dep(repo_root, "pytest-xdist"),
        "has_pytest_cov": _pyproject_has_dep(repo_root, "pytest-cov"),
    }

    def render(template: str, dest: Path) -> None:
        dest.write_text(env.get_template(template).render(ctx))
        print(f"Wrote {dest.relative_to(repo_root)}")

    if django_deploy:
        render("Makefile.j2", repo_root / "Makefile")

    if github_workflows:
        if is_django:
            django_filename = "django-deploy.yml" if django_deploy else "django.yml"
            render("workflows/django.yml.j2", repo_wf_dir / django_filename)
        else:
            if (repo_root / "prek.toml").exists():
                render("workflows/prek.yml.j2", repo_wf_dir / "prek.yml")
            if uv_lock_exists and _pyproject_has_dep(repo_root, "pytest"):
                render("workflows/pytest.yml.j2", repo_wf_dir / "pytest.yml")

    # conv-commit: overwrite if already present, or create if -c flag set
    conv_commit_path = repo_wf_dir / "conv-commit.yml"
    if conv_commit_path.exists() or conv_commit:
        render("workflows/conv-commit.yml.j2", conv_commit_path)
