-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<CR>", function()
  if vim.bo.modifiable then
    return ":wall<CR>"
  else
    return "<CR>"
  end
end, { expr = true, remap = true, desc = "Write all" })

vim.keymap.del("n", "s")
vim.keymap.del("n", "S")
-- need to override the ones set by lazyvim here
vim.keymap.set("n", "<C-Up>", "<Plug>(VM-Add-Cursor-Up)")
vim.keymap.set("n", "<C-Down>", "<Plug>(VM-Add-Cursor-Down)")

vim.keymap.set("n", "<Space>t", function()
  vim.cmd("silent !xfce4-terminal --working-directory='" .. vim.fn.expand("%:p:h") .. "' &")
end, { noremap = true, silent = true, desc = "Open an xfce4-terminal" })

vim.keymap.set("n", "-o", "<C-w>o", { noremap = true, silent = true, desc = "Maximize window" })
vim.keymap.set("n", "-h", "<C-w>h", { noremap = true, silent = true, desc = "Move one window left" })
vim.keymap.set("n", "-l", "<C-w>l", { noremap = true, silent = true, desc = "Move one window right" })
vim.keymap.set("n", "-j", "<C-w>j", { noremap = true, silent = true, desc = "Move one window down" })
vim.keymap.set("n", "-k", "<C-w>k", { noremap = true, silent = true, desc = "Move one window up" })
vim.keymap.set("n", "-i", ":split<CR>", { noremap = true, silent = true, desc = "Open a horizontal split" })
vim.keymap.set("n", "-s", ":vsplit<CR>", { noremap = true, silent = true, desc = "Open a vertical split" })
vim.keymap.set("n", "<BS>", ":bp<CR>", { noremap = true, silent = true, desc = "Previous buffer" })

-- Git hotkeys
vim.keymap.set("n", "<leader>gg", function()
  vim.cmd("terminal git commit")
end, { desc = "git commit", silent = true })
vim.keymap.set("n", "<leader>gw", function()
  vim.cmd("terminal git commit %")
end, { desc = "git commit %", silent = true })
vim.keymap.set("n", "<leader>ga", function()
  vim.cmd("terminal git commit --all")
end, { desc = "git commit -a", silent = true })

vim.keymap.set("n", "<Space>y", function()
  print(vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1)), "name"))
end, { desc = "Get old syntax group" })

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

local function switch_buf_num(num)
  local buffers = {}
  for i = 1, vim.fn.bufnr("$") do
    if vim.fn.buflisted(i) == 1 then
      table.insert(buffers, tostring(i))
    end
  end

  local input = tostring(num)

  while true do
    local cnt = 0
    local example = nil

    for _, bn in ipairs(buffers) do
      if bn:sub(1, #input) == input then
        cnt = cnt + 1
        example = bn
      end
    end

    if cnt == 0 and #input > 0 then
      print("no buffer [" .. input .. "]")
      return ""
    elseif cnt == 1 and input == example then
      vim.cmd("b " .. example)
      return ""
    end

    print(":b " .. input)
    local n = vim.fn.getchar()

    if n == vim.fn.char2nr("<BS>") or n == vim.fn.char2nr("<C-h>") then
      input = input:sub(1, #input - 1)
    elseif n == vim.fn.char2nr("<CR>") or n < vim.fn.char2nr("0") or n > vim.fn.char2nr("9") then
      vim.cmd("b " .. input)
      return ""
    else
      if type(n) == "number" then
        input = input .. string.char(n)
      end
    end
  end
end

-- Create mappings for <Space>1 to <Space>9
for i = 1, 9 do
  vim.keymap.set("n", "<Space>" .. i, function()
    switch_buf_num(i)
  end, { expr = false, noremap = true, desc = "Switch to buffer " .. tostring(i) })
end
