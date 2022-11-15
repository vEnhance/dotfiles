setlocal tabstop=4
let b:ale_fixers = []
let b:ale_fix_on_save = 0

" https://www.reddit.com/r/vim/comments/dj37wt/plugin_for_conventional_commits/
inoreabbrev <buffer> BB BREAKING CHANGE:

function! HandleFZF(arg)
  normal! gg
  normal! 0
  call feedkeys('O' . a:arg . '(<++>): <++>\<Esc>^\<C-j>', 't')
endfunction

command! -nargs=1 HandleFZF call HandleFZF(<f-args>)

let g:categorized = 0
function! SetConventionalCommit()
  let s:choices = ['', 'fix', 'feat', 'docs', 'refactor', 'polish', 'edit', 'chore', 'test', 'style',]
  if g:categorized == 0
    let g:categorized = 1
    call fzf#run({'source' : s:choices, 'sink': 'HandleFZF', 'up' : '10'})
  endif
endfunction

function! GitCommitStartup()
  normal! gg
  let line = getline('.')
  if line ==# ''
    call SetConventionalCommit()
  endif
endfunction

nnoremap <localleader>c :call SetConventionalCommit()<CR>
let b:airline_whitespace_disabled = 1
