setlocal ts=4
" this goes in ~/.vim/after/ftplugin/gitcommit.vim

" https://www.reddit.com/r/vim/comments/dj37wt/plugin_for_conventional_commits/
inoreabbrev <buffer> BB BREAKING CHANGE:

function! HandleFZF(arg)
	normal gg
	normal 0
	call feedkeys("O" . a:arg . ": ", 't')
endfunction

command! -nargs=1 HandleFZF call HandleFZF(<f-args>)

let b:categorized = 0
function! s:SetConventionalCommit()
	let s:choices = ['fix', 'feat', 'docs', 'style', 'refactor', 'chore', 'test', 'improvement']
	if b:categorized == 0
		let b:categorized = 1
		call fzf#run({'source' : s:choices, 'sink': 'HandleFZF'})
	endif
endfunction

autocmd BufEnter COMMIT_EDITMSG call s:SetConventionalCommit()
