-- Return the cmd table for a given lspconfig server name, or nil if unknown.
-- Tries the Neovim 0.11+ lsp/ runtime files first, then lspconfig's legacy
-- configs/ path as a fallback.
local function server_cmd(server_name)
  local files = vim.api.nvim_get_runtime_file("lsp/" .. server_name .. ".lua", false)
  if files[1] then
    local ok, config = pcall(dofile, files[1])
    if ok and type(config) == "table" and type(config.cmd) == "table" then
      return config.cmd
    end
  end
  local ok, config = pcall(require, "lspconfig.configs." .. server_name)
  if ok and type(config) == "table" then
    local cmd = config.default_config and config.default_config.cmd
    if type(cmd) == "table" then
      return cmd
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Servers not covered by any LazyVim extra. Binary detection is still
        -- automatic via the opts function below; just list the server name.
        fish_lsp = {},
        rumdl = {}, -- Markdown
        tinymist = {}, -- Typst
        vale_ls = {}, -- Vale

        -- Servers explicitly disabled (override LazyVim extras, etc.)
        marksman = { enabled = false }, -- replaced by rumdl
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- For every server registered by any plugin (LazyVim extras, etc.),
      -- skip Mason if the system already provides the binary.
      for server_name, server_opts in pairs(opts.servers or {}) do
        if server_opts.enabled ~= false and server_opts.mason ~= false then
          local cmd = server_cmd(server_name)
          if cmd and vim.fn.executable(cmd[1]) == 1 then
            server_opts.mason = false
          end
        end
      end
      return opts
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {}, -- all handled by LSP already
        sh = { "shellcheck" },
        tex = { "chktex" },
        ["*"] = { "codespell" },
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
        markdown = { "rumdl" },
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
