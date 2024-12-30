vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.python_host_prog = "/usr/bin/python"

vim.cmd 'set runtimepath^=~/.vim runtimepath+=~/.vim/after'
vim.cmd 'let &packpath = &runtimepath'
vim.cmd 'source ~/.vimrc'

vim.diagnostic.config({
  virtual_text = {
    prefix = ' ●', -- Could be '●', '▎', 'x'
  }
})

require("neo-tree").setup()
require("snacks").setup({
  bigfile = { enabled = true },
  dim = { enabled = true },
  indent = { enabled = true },
  quickfile = { enabled = true },
})
