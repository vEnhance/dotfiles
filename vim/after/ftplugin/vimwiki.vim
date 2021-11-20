function EvanOpenWikiLinkOrSave()
	" try WikiLink
	let lnk = matchstr(vimwiki#base#matchstr_at_cursor(vimwiki#vars#get_syntaxlocal('rxWikiLink')),
				\ vimwiki#vars#get_syntaxlocal('rxWikiLinkMatchUrl'))
	" try WikiIncl
	if lnk ==? ''
		let lnk = matchstr(vimwiki#base#matchstr_at_cursor(vimwiki#vars#get_global('rxWikiIncl')),
					\ vimwiki#vars#get_global('rxWikiInclMatchUrl'))
	endif
	" try Weblink
	if lnk ==? ''
		let lnk = matchstr(vimwiki#base#matchstr_at_cursor(vimwiki#vars#get_syntaxlocal('rxWeblink')),
					\ vimwiki#vars#get_syntaxlocal('rxWeblinkMatchUrl'))
	endif

	if vimwiki#vars#get_wikilocal('syntax') ==# 'markdown'
		" markdown image ![]()
		if lnk ==# ''
			let lnk = matchstr(vimwiki#base#matchstr_at_cursor(vimwiki#vars#get_syntaxlocal('rxImage')),
						\ vimwiki#vars#get_syntaxlocal('rxWeblinkMatchUrl'))
			if lnk !=# ''
				if lnk !~# '\%(\%('.vimwiki#vars#get_global('web_schemes1').'\):\%(\/\/\)\?\)\S\{-1,}'
					" prepend file: scheme so link is opened by sytem handler if it isn't a web url
					let lnk = 'file:'.lnk
				endif
			endif
		endif
	endif

	if lnk !=? ''
		VimwikiFollowLink
	else
		call EvanSave()
	endif
endfunction



nnoremap <buffer> <CR> :call EvanOpenWikiLinkOrSave()<CR>
nnoremap <buffer> ,<CR> :VimwikiFollowLink<CR>

noremap <buffer> <Backspace> :CtrlSpaceGoUp<CR>
noremap <buffer> <S-Backspace> :CtrlSpaceGoDown<CR>
