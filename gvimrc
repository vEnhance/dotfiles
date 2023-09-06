set encoding=utf-8
set guifont=Inconsolata\ Semi-Condensed\ Semi-Bold\ 22


if hostname() ==# 'ArchScythe'
  let s:basefontsize = 20
elseif hostname() ==# 'ArchDiamond'
  let s:basefontsize = 18
elseif hostname() ==# 'ArchMajestic'
  let s:basefontsize = 20
elseif hostname() ==# 'ArchBootes'
  let s:basefontsize = 18
elseif hostname() ==# 'ArchSapphire'
  let s:basefontsize = 20
else
  let s:basefontsize = 22
endif

let s:fontsize = s:basefontsize

function! AdjustFontSize(amount)
  let s:fontsize = s:fontsize+a:amount
  execute 'set guifont=Inconsolata\ Semi-Condensed\ Semi-Bold\ ' . s:fontsize
endfunction
function! ResetFontSize()
  let s:fontsize = s:basefontsize
  call AdjustFontSize(0)
endfunction

call AdjustFontSize(0)
nnoremap <C-0> :call ResetFontSize()<CR>
nnoremap <C-S-+> :call AdjustFontSize(1)<CR>
nnoremap  :call AdjustFontSize(-1)<CR>
nnoremap <C-ScrollWheelUp> :call AdjustFontSize(1)<CR>
nnoremap <C-ScrollWheelDown> :call AdjustFontSize(-1)<CR>
set guioptions-=T  "remove toolbar

colorscheme reclipse
