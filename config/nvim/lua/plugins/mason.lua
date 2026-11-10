-- Mason is disabled: all LSP servers, linters, formatters, and debug adapters
-- come from system packages instead (see installers/packages.txt).
-- LazyVim enables servers directly when mason-lspconfig is absent.
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false }, -- pulled in by dap.core
}
