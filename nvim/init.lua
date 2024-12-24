vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.python_host_prog = "/usr/bin/python"

vim.cmd 'set runtimepath^=~/.vim runtimepath+=~/.vim/after'
vim.cmd 'let &packpath = &runtimepath'
vim.cmd 'source ~/.vimrc'

-- https://github.com/nvim-treesitter/nvim-treesitter/issues/5536#issuecomment-1826400562
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
}
require("ibl").setup()

vim.diagnostic.config({
  virtual_text = {
    prefix = ' ●', -- Could be '●', '▎', 'x'
  }
})

require("neo-tree").setup()
