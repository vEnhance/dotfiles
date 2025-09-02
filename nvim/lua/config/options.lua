-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.clipboard = ""
opt.colorcolumn = "+1"
opt.conceallevel = 2
opt.formatoptions:remove("t")
opt.spell = true
opt.relativenumber = false
opt.ruler = true
opt.textwidth = 80 -- default textwidth
