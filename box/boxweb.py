"""Playwright helpers for the box.

- launch(): chromium-headless-shell with the sandbox proxy's credentials.
- new_page(): a page whose jsDelivr/unpkg npm requests are served from the local
  mirror filled by web-setup.sh (exact version, else newest with the same major).

Import this before starting Playwright: the env var below is read by its driver.
"""

import os
import re
from pathlib import Path
from urllib.parse import unquote, urlsplit

# Playwright forces loopback traffic through the proxy, which the sandbox proxy
# refuses (403), breaking local dev servers. This lets the bypass list apply.
os.environ.setdefault("PLAYWRIGHT_DISABLE_FORCED_CHROMIUM_PROXIED_LOOPBACK", "1")

MIRROR = Path(
    os.environ.get("BOXWEB_MIRROR", "~/.local/share/web-assets/npm")
).expanduser()
CDN = re.compile(
    r"https://(?:cdn\.jsdelivr\.net/npm|unpkg\.com)/((?:@[^/]+/)?[^@/]+)@([^/]+)/([^?#]*)"
)


def _key(version: str) -> tuple[int, ...]:
    return tuple(int(x) if x.isdigit() else -1 for x in re.split(r"[.+-]", version))


def _find(name: str, version: str) -> Path | None:
    exact = MIRROR / f"{name}@{version}"
    if exact.is_dir():
        return exact
    major = version.lstrip("^~").split(".")[0]
    local = [
        p
        for p in (MIRROR / name).parent.glob(f"{Path(name).name}@{major}.*")
        if p.is_dir()
    ]
    return max(local, key=lambda p: _key(p.name.rsplit("@", 1)[1]), default=None)


def _serve(route) -> None:
    m = CDN.match(route.request.url)
    if m and (root := _find(m[1], m[2])):
        f = (root / m[3]).resolve()
        if f.is_file() and f.is_relative_to(root.resolve()):
            route.fulfill(path=f)
            return
    route.continue_()


def launch(p, **kwargs):
    """Launch chromium-headless-shell, using the sandbox proxy if there is one."""
    if url := os.environ.get("HTTPS_PROXY"):
        u = urlsplit(url)
        kwargs.setdefault(
            "proxy",
            {
                "server": f"http://{u.hostname}:{u.port}",
                "username": unquote(u.username or ""),
                "password": unquote(u.password or ""),
                "bypass": os.environ.get("NO_PROXY", "localhost,127.0.0.1,::1"),
            },
        )
    args = ["--no-sandbox", "--disable-dev-shm-usage", *kwargs.pop("args", [])]
    return p.chromium.launch(args=args, **kwargs)


def new_page(browser, **context_kwargs):
    """New page in a fresh context that serves CDN npm files from the mirror."""
    context = browser.new_context(**context_kwargs)
    context.route(CDN, _serve)
    return context.new_page()
