return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["*"] = { "trim_whitespace", "trim_newlines" },
        python = { "ruff_fix", "ruff_format" },
      },
    },
  },
}
