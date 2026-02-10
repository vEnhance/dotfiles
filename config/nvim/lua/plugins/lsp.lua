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
        ty = {
          mason = not command_exists("ty"), -- Use system if available
        },
        pyright = {
          mason = not command_exists("pyright"), -- Use system if available
        },
        ruff = {
          mason = not command_exists("ruff"), -- Use system if available
        },

        -- eslint
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

        -- Fish
        fish_lsp = {
          mason = not command_exists("fish-lsp"),
        },

        -- Typst
        tinymist = {
          mason = not command_exists("tinymist"),
        },

        -- Additional common servers
        marksman = { -- Markdown
          mason = not command_exists("marksman"),
        },
        yamlls = { -- YAML
          mason = not command_exists("yaml-language-server"),
        },
      },
    },
  },
}
