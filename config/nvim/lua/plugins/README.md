# The full IDE experience

aka notes to self because omg i'm so confused right now

## Toolkit (`coding.lua`)

1. The **language servers** is a whole suite, including diagnostics.
   It talks to the editor using the Language Server Protocol.
   - Add them in `servers` under `nvim-lspconfig`
   - If there is a server from this you don't want, set `enabled = false`.

1. A **linter** is a single program that provides diagnostics on a single file.
   - Add them in `linters_by_ft` under `nvim-lint`
   - Linters only need to be added here if they don't have an LSP tool already.
     - So `rumdl`, `ruff`, etc. don't need to be here, for example.
   - (Contrary to the name, ALE actually has its own language server client.)

1. A **formatter** does code fixing and is often independent of LSP.
   - Add them in `formatters_by_ft` under `conform.nvim`.

## Mason (`mason.lua`)

This controls **home installation of LSP, linter, and formatters**.

- `mason-lspconfig` will automatically tell Mason to install LSP's
  requested by `nvim-lspconfig`.
- But we've configured Mason to not install something if system already has it.
  - To avoid version hell where Mason's version might be behind.
  - Also, it's just wasteful… I have so many copies of Ruff now…
- The `never_install` lists packages that Mason should NOT install.
  - For tools we don't use at all, if blocking in `coding.lua` is enough, do that.

## LazyVim

The LazyVim suite might add several things automatically
that I might want to revert.

- LSP's: Disable with `enabled = false`.
- Linters and formatters: Override `linters_by_ft` or `formatters_by_ft`.
- Mason `ensure_installed` entries: Add to `never_install`.
