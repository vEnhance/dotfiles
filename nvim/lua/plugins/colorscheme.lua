-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavor = "mocha",
      transparent_background = true,
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.peach },
          CursorLineNr = { fg = colors.teal, bg = colors.overlay0, style = { "bold" } },
          Conceal = { fg = colors.yellow },
          Identifier = { style = { "bold" } },
          Include = { fg = colors.green },
          Function = { fg = colors.red },
          PreProc = { fg = colors.maroon, style = { "bold" } },
          Special = { fg = colors.green, style = { "bold" } },
          Statement = { fg = colors.sapphire, style = { "bold" } },
          texTitleArg = { fg = colors.base, style = { "bold" } },
          texEnvArgName = { fg = colors.red, style = { "bold" } },
          texEnvOpt = { fg = colors.text, style = { "bold" } },
          texMathEnvArgName = { fg = colors.green, style = { "bold" } },
          texCmd = { fg = colors.blue, style = { "bold" } },
          texCmdPart = { fg = colors.red, style = { "bold" } },
          texPartArgTitle = { fg = colors.yellow, style = { "bold" } },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
