return {
  {
    "mg979/vim-visual-multi",
    "tpope/vim-fugitive",
    {
      "kaarmu/typst.vim",
      init = function()
        vim.g.typst_conceal = 1
        vim.g.typst_conceal_math = 1
        vim.g.typst_conceal_emoji = 1
      end,
    },
    {
      "lervag/vimtex",
      init = function()
        vim.g.vimtex_fold_enabled = 1
        vim.g.vimtex_fold_levelmarker = "§"
        vim.g.vimtex_fold_manual = 1
        vim.g.vimtex_fold_types = {
          preamble = { enabled = 1 },
          sections = { enabled = 1 },
          envs = { enabled = 1 },
        }

        vim.g.vimtex_indent_on_ampersands = 0

        vim.g.vimtex_syntax_conceal = {
          accents = 1,
          ligatures = 1,
          cites = 1,
          fancy = 1,
          spacing = 0,
          greek = 1,
          math_bounds = 0,
          math_delimiters = 1,
          math_fracs = 1,
          math_super_sub = 1,
          math_symbols = 1,
          sections = 0,
          styles = 1,
        }

        vim.g.vimtex_syntax_packages = {
          amsmath = { conceal = 1, load = 2 },
          babel = { conceal = 1 },
          hyperref = { conceal = 1 },
          fontawesome5 = { conceal = 1 },
        }

        vim.g.vimtex_view_method = "zathura"

        vim.g.vimtex_syntax_custom_envs = {
          {
            name = "tikzcd",
            math = 1,
          },
          {
            name = "asy",
            region = "texCodeZone",
            nested = "asy",
          },
          {
            name = "asydef",
            region = "texCodeZone",
            nested = "asy",
          },
          {
            name = "lstlisting",
            region = "texCodeZone",
            nested = {
              bash = "language=[Bb]ash",
              c = "language=C",
              git = "language=git",
              make = "language=[Mm]ake",
              python = "language=[Pp]ython",
              rust = "language=[Rr]ust",
              sql = "language=SQL",
            },
          },
        }
      end,
    },
  },
}
