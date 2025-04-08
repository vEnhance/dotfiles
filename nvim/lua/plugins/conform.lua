return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["*"] = { "trim_whitespace", "trim_newlines" },
        python = { "ruff_fix", "ruff_format" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        rust = { "rustfmt" },
        typescript = { "prettier", "eslint" },
        htmldjango = { "djlint" },
        bib = { "bibclean" },
        fish = { "fish_indent" },
        javascript = { "prettier" },
      },
    },
  },
}
