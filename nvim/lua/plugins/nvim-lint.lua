return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "vale" },
        text = { "vale" },
        rst = { "vale" },
        asciidoc = { "vale" },
        python = { "pyright", "ruff" },
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
}
