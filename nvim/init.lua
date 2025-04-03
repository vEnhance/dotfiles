-- monkey patch treesitter to not run on markdown
-- (at least until i can get my color scheme to look nice with it)
if vim.treesitter then
  local _patched = false
  if not _patched then
    local original = vim.treesitter.start
    vim.treesitter.start = function(bufnr, lang)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      lang = lang or vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
      if lang == "markdown" or lang == "markdown_inline" then return end
      return original(bufnr, lang)
    end
    _patched = true
  end
end

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
