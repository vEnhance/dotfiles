require("config.lazy")

-- Asymptote LSP
local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

if not configs.asy_ls then
  configs.asy_ls = {
    default_config = {
      cmd = { "asy", "-lsp" },
      filetypes = { "asy" },
      single_file_support = true,
      settings = {},
    },
  }
end
lspconfig.asy_ls.setup({})
