-- Helper function to check if a command exists in system PATH
local function command_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Rust
        rust_analyzer = {
          mason = not command_exists("rust-analyzer"), -- Use system if available
        },

        -- Python
        pyright = {
          mason = not command_exists("pyright"), -- Use system if available
        },
        ruff = {
          mason = not command_exists("ruff"), -- Use system if available
        },

        -- TypeScript/JavaScript
        ts_server = {
          mason = not command_exists("typescript-language-server"),
        },
        eslint = {
          mason = not command_exists("vscode-eslint-language-server"),
        },

        -- Lua
        lua_ls = {
          mason = not command_exists("lua-language-server"),
        },

        -- Bash/Shell
        bashls = {
          mason = not command_exists("bash-language-server"),
        },

        -- Go
        gopls = {
          mason = not command_exists("gopls"),
        },

        -- Additional common servers
        marksman = { -- Markdown
          mason = not command_exists("marksman"),
        },
        jsonls = { -- JSON
          mason = not command_exists("vscode-json-language-server"),
        },
        yamlls = { -- YAML
          mason = not command_exists("yaml-language-server"),
        },
      },
    },
  },
}
