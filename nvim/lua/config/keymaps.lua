-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<CR>", function()
  if vim.bo.modifiable then
    return ":wall<CR>"
  else
    return "<CR>"
  end
end, { expr = true, noremap = true })

vim.keymap.set("n", "<Space>-", function()
  vim.cmd([[
    if (winnr('$') == 1 || (winnr('$') == 2 && winnr() == 2))
      if tabpagenr('$') == 1
        bdelete
        if expand('%:p') ==# ''
          quit
        endif
      else
        bdelete
      endif
    elseif expand('%:l') ==# '__doc__'
      bdelete
    else
      close
    endif
  ]])
end, { noremap = true })
