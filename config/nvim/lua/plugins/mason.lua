-- Non-LSP tools that Mason should never install.
-- Use mason package names. To disable LSP servers instead, see lsp.lua.
-- See: https://mason-registry.dev/registry/list
local never_install = {
  "markdownlint-cli2", -- added by LazyExtras, but we don't use it
  "markdown-toc", -- added by LazyExtras, but we don't use it
  "rumdl", -- I will install this on system
}

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.PATH = "append" -- prefer system binaries over Mason-installed ones
      opts.ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      }
      -- Only install a tool if it's not blocklisted and not already on the system.
      -- For most mason packages the binary name matches the package name.
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return not vim.tbl_contains(never_install, pkg) and vim.fn.executable(pkg) ~= 1
      end, opts.ensure_installed or {})
      return opts
    end,
  },
}
