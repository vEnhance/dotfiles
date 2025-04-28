let b:ale_linters = ['vale', 'chktex']
let b:ale_fixers = g:ale_fixers['*'] + ['death_to_double_dollar_signs']

function EvanCompileLaTeX(continuous)
  " von compiler
  if a:continuous
    VimtexCompile
  elseif b:vimtex.compiler.is_running()
    VimtexView
  else
    VimtexCompileSS
  endif
endfunction

function! SyncTexForward()
  exec 'silent !zathura --synctex-forward '.line('.').':'.col('.').':%:p %:p:r.pdf &'
endfunction

" latex compile continuously
nnoremap <silent> <localleader>p :call EvanCompileLaTeX(1)<CR>
" latex compile once
nnoremap <silent> <localleader>c :call EvanCompileLaTeX(0)<CR>
" latex halt compile
nnoremap <silent> <localleader>h <plug>(vimtex-stop)
" latex synctex
nmap <silent> <localleader>s :call SyncTexForward()<CR>
" vimtex toc
nnoremap <silent> <localleader>t <plug>(vimtex-toc-toggle)
" vimtex open viewer
nnoremap <silent> <localleader>v <plug>(vimtex-view)
" latex remove all double dollar signs
nnoremap <silent> <localleader>f :%s/\$\$/\\\[/<CR>:%s/\$\$/\\\]/<CR>

" Wrap in dollar signs
nnoremap <localleader>w i$<Esc>ea$<Esc>

set conceallevel=2

set textwidth=88 " LaTeX can be a bit wider, follow Black
