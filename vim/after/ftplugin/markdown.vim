let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0

set tabstop=2
set tw=80
set sw=2

" taking a page from vimwiki
" vim markdown maxsave
syn match VimwikiLinkRest `\%(///\=[^/ \t]\+/\)\zs\S\+\ze\%([/#?]\w\|\S\{40}\)` cchar=~ conceal
set conceallevel=2
