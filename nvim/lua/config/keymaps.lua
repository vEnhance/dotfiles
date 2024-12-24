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

vim.cmd([[
" Buffer switching: https://vi.stackexchange.com/a/9255
function! EvanSwitchBufNum(num)
  let l:buffers = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let l:input = a:num . ''
  while 1
    let l:cnt = 0
    let l:i = 0

    " count matches
    while l:i<len(l:buffers)
      let l:bn = l:buffers[l:i] . ''
      if l:input==l:bn[0:len(l:input)-1]
        let l:example = l:bn
        let l:cnt+=1
      endif
      let l:i+=1
    endwhile

    " no matches
    if l:cnt==0 && len(l:input)>0
      echo 'no buffer [' . l:input . ']'
      return ''
    elseif l:cnt==1 && l:input==l:example
      return ':b ' . l:example . "\<CR>"
    endif

    echo ':b ' . l:input
    let l:n = getchar()
    if l:n==char2nr("\<BS>") ||  l:n==char2nr("\<C-h>")
      " delete one word
      if len(l:input)>=2
        let l:input = l:input[0:len(l:input)-2]
      else
        let l:input = ''
      endif
    elseif l:n==char2nr("\<CR>") || (l:n<char2nr('0') || l:n>char2nr('9'))
      return ':b ' . l:input . "\<CR>"
    else
      let l:input = l:input . nr2char(l:n)
    endif
    let g:n = l:n
    endwhile
endfunc

nnoremap <expr> <Space>1 EvanSwitchBufNum(1)
nnoremap <expr> <Space>2 EvanSwitchBufNum(2)
nnoremap <expr> <Space>3 EvanSwitchBufNum(3)
nnoremap <expr> <Space>4 EvanSwitchBufNum(4)
nnoremap <expr> <Space>5 EvanSwitchBufNum(5)
nnoremap <expr> <Space>6 EvanSwitchBufNum(6)
nnoremap <expr> <Space>7 EvanSwitchBufNum(7)
nnoremap <expr> <Space>8 EvanSwitchBufNum(8)
nnoremap <expr> <Space>9 EvanSwitchBufNum(9)
]])
