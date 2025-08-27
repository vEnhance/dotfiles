return {
  {
    "mason-org/mason.nvim",
    version = "^1.11.0",
    opts = {
      PATH = "append", -- Put Mason's bin at end of PATH, prefer system binaries
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    version = "^1.11.0",
    opts = {
      ensure_installed = {}, -- Only install what we explicitly request
    },
  },
}
