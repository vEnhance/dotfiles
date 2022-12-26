vim.cmd 'set runtimepath^=~/.vim runtimepath+=~/.vim/after'
vim.cmd 'let &packpath = &runtimepath'
vim.cmd 'source ~/.vimrc'

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
