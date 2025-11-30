return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "vale" },
        text = { "vale" },
        rst = { "vale" },
        asciidoc = { "vale" },
        sh = { "shellcheck" },
        tex = { "vale", "chktex" },
      },
    },
    linters = {
      languagetool = {
        args = "--disable COMMA_PARENTHESIS_WHITESPACE,WHITESPACE_RULE,UPPERCASE_SENTENCE_START,LC_AFTER_PERIOD,FILE_EXTENSIONS_CASE,ARROWS,EN_UNPAIRED_BRACKETS,UNLIKELY_OPENING_PUNCTUATION,UNIT_SPACE,ENGLISH_WORD_REPEAT_BEGINNING_RULE,CURRENCY,REP_PASSIVE_VOICE,EN_UNPAIRED_QUOTES",
      },
    },
  },
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
        css = { "prettier" },
        javascript = { "prettier" },
        tex = { "death_to_double_dollar_signs" },
      },
      formatters = {
        death_to_double_dollar_signs = {
          meta = {
            description = "Remove double dollar signs in LaTeX.",
          },
          format = function(self, ctx, lines, callback)
            local out_lines = {}
            for _, line in ipairs(lines) do
              local trimmed = line:gsub("%$%$(.-)%$%$", function(inner)
                return "\\[ " .. inner .. " \\]"
              end)
              table.insert(out_lines, trimmed)
            end
            callback(nil, out_lines)
          end,
        },
      },
    },
  },
}
