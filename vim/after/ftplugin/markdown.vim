set tabstop=2
set tw=80
set sw=2
" markdown should allow double trailing space
" unfortunately, right now this variable apparently has to be global
" maybe i should submit a PR that would read a buffer variable instead?
" i dunno if that's too trivial for the community to care about
let g:airline#extensions#whitespace#trailing_regexp = '\t$\|\s\{3,\}$\|[^ ] $'
let b:airline_whitespace_trailing_regexp = '\t$\|\s\{3,\}$\|[^ ] $'
let b:ale_fixers = ['remove_trailing_lines',]

inoremap <C-R><C-R> As a reminder, it's appreciated if you can include the sources of problems (e.g. "Shortlist 2018 A7") when provided, because the problem numbers can often change during edits.
