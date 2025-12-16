vim.opt_local.textwidth = 100

-- Only spellcheck comments, not code
vim.cmd.syntax({ args = { "spell", "notoplevel" } })
