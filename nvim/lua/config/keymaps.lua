-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<CR>", function()
  if vim.bo.modifiable then
    return ":wall<CR>"
  else
    return "<CR>"
  end
end, { expr = true, noremap = true, desc = "Write all" })

vim.keymap.del("n", "s")
vim.keymap.del("n", "S")

vim.keymap.set(
  "n",
  "<Space>e",
  ":let $VIM_DIR=expand('%:p:h')<CR>:silent !xfce4-terminal --working-directory='$VIM_DIR' &<CR>",
  { noremap = true, desc = "Open an xfce4-terminal" }
)

vim.keymap.set("n", "-h", "<C-w>h", { noremap = true, desc = "Move one window left" })
vim.keymap.set("n", "-l", "<C-w>l", { noremap = true, desc = "Move one window right" })
vim.keymap.set("n", "-j", "<C-w>j", { noremap = true, desc = "Move one window down" })
vim.keymap.set("n", "-k", "<C-w>k", { noremap = true, desc = "Move one window up" })
vim.keymap.set("n", "-i", ":split<CR>", { noremap = true, desc = "Open a horizontal split" })
vim.keymap.set("n", "-s", ":vsplit<CR>", { noremap = true, desc = "Open a vertical split" })

vim.keymap.set("n", "<BS>", ":bp<CR>", { noremap = true, desc = "Previous buffer" })

local function is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  return vim.v.shell_error == 0
end

vim.keymap.set("n", "<Space>o", function()
  if is_git_repo() then
    vim.cmd("FzfLua git_files")
  else
    vim.cmd("FzfLua files")
  end
end, { noremap = true, desc = "Find files" })

local function is_last_buffer()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  return #buffers == 1
end

vim.keymap.set("n", "<Space>-", function()
  if is_last_buffer() then
    vim.cmd("q")
  else
    Snacks.bufdelete()
  end
end, { noremap = true, desc = "Close buffer" })
