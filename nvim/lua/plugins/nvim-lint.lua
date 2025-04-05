-- ~/.config/nvim/lua/plugins/vale-lint.lua
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "prettier", "vale" },
        text = { "vale" },
        rst = { "vale" },
        asciidoc = { "vale" },
      },
    },
  },
}
