# You are running inside a box

You're in a bubblewrap container. Many failures here are deliberate; don't
work around them, just tell the user what you couldn't do.

- **`$HOME` is a separate box directory.**
  Only the current project is mounted from the host, plus a few read-only
  configs (git, ruff, rumdl, shellcheck, latexmk, `~/texmf`, local typst packages).
  The user's other repos and dotfiles aren't.

- **Python: just use `uv sync` / `uv run`.**
  If `UV_PROJECT_ENVIRONMENT` is set, that's the project's venv
  (a box-only copy under `~/.virtualenvs`, writable from the Bash sandbox).
  Don't make throwaway venvs in `/tmp`.
  Python installs under `~/.local/share/uv/python` are read-only,
  so if a needed Python version is missing, ask the user to install it on the host.

- **No desktop.** No display, D-Bus, clipboard, or host processes.
  To test GUI programs, use `xvfb-run -a` (plus `xdotool`, `import -window root`)
  with the Bash sandbox disabled, since the sandbox blocks the X socket.

- **No git identity, GPG, SSH, or `gh` auth.**
  Don't commit, push, or open PRs, and never set or invent a git identity.
  Leave changes uncommitted for the user.
  `.git/config` and `.git/hooks` are read-only.

- **`/tmp` is private and wiped on exit.** Fine for scratch files only.

- **`~/.claude/settings.json` and this file are read-only.**
  If a change is needed, tell the user.

- **Ignore untracked dotfiles like `.bashrc`, `.gitconfig`,
  `.mcp.json`, `.vscode`** in `git status` or `ls`.
  They're empty placeholders created by the Bash sandbox.
  Never delete, edit, or commit them.
