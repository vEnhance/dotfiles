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

Mason is **disabled entirely**. Every LSP server, linter, formatter,
and debug adapter comes from system packages (`installers/packages.txt`).

- To avoid version hell and a dozen copies of Ruff in `~/.local/share`.
- LazyVim enables servers directly when `mason-lspconfig` is absent.
- `coding.lua` auto-disables any server whose binary isn't on `$PATH`,
  so a missing optional package just means no LSP for that filetype.
- To get a new server, install it with pacman and (if no extra covers it)
  list it under `servers` in `coding.lua`.

## LazyVim

The LazyVim suite might add several things automatically
that I might want to revert.

- LSP's: Disable with `enabled = false`.
- Linters and formatters: Override `linters_by_ft` or `formatters_by_ft`.
