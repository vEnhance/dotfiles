if hostname() ==# 'ArchScythe'
  let s:basefontsize = 16
elseif hostname() ==# 'ArchDiamond'
  let s:basefontsize = 18
elseif hostname() ==# 'ArchMajestic'
  let s:basefontsize = 20
elseif hostname() ==# 'ArchBootes'
  let s:basefontsize = 18
elseif hostname() ==# 'ArchSapphire'
  let s:basefontsize = 18
else
  let s:basefontsize = 22
endif

let s:fontsize = s:basefontsize

colorscheme reclipse

set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175

function! AdjustFontSize(amount)
  let s:fontsize = s:fontsize+a:amount
  execute 'GuiFont! Inconsolata Semi Condensed Semibold:h' . s:fontsize
endfunction
function! ResetFontSize()
  let s:fontsize = s:basefontsize
  call AdjustFontSize(0)
endfunction

call AdjustFontSize(0)
nnoremap <C-0> :call ResetFontSize()<CR>
nnoremap <C-S-+> :call AdjustFontSize(1)<CR>
nnoremap <C--> :call AdjustFontSize(-1)<CR>
nnoremap <C-ScrollWheelUp> :call AdjustFontSize(1)<CR>
nnoremap <C-ScrollWheelDown> :call AdjustFontSize(-1)<CR>
