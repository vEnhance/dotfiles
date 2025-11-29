return {
  {
    "mason-org/mason.nvim",
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
}
