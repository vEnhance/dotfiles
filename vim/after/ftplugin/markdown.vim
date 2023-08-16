set shiftwidth=2
set softtabstop=2
set tabstop=2
set textwidth=80

" markdown should allow double trailing space
" unfortunately, right now this variable apparently has to be global
" maybe i should submit a PR that would read a buffer variable instead?
" i dunno if that's too trivial for the community to care about
let g:airline#extensions#whitespace#trailing_regexp = '\t$\|\s\{3,\}$\|[^ ] $'
let b:airline_whitespace_trailing_regexp = '\t$\|\s\{3,\}$\|[^ ] $'
let b:ale_fixers = ['remove_trailing_lines', 'prettier']

" Pet peeves
inoremap <C-R><C-R> As a reminder (see syllabus 3.2, third bullet), it's appreciated if you can include the sources of problems (e.g. "Shortlist 2018 A7") when provided, because the problem numbers can often change during edits.
inoremap <C-R><C-D> Small LaTeX tip: you should generally use \dots over \cdots or "...". (In a list, you want the dots to be bottom-aligned (equivalent to \ldots). But \dots will automatically detect the alignment for you.)
inoremap <C-R><C-O> LaTeX tip: When typing any of the operators \min, \max, \deg, \gcd, \log, \exp, \sin, \cos, \tan you should always remember to include the backslash so that the operator is properly typed in Roman font, rather than interpreted as a string of badly named variables.
inoremap <C-R><C-T> LaTeX tip: use `\mid` instead of `\|` to denote divisibility.
inoremap <C-R><C-M> Small LaTeX tip: use `\pmod{n}` to typeset (mod n).
inoremap <C-R><C-S> Small LaTeX tip: use `\cdot` to typeset multiplication rather than `*`.
inoremap <C-R><C-Q> In LaTeX, quotes are a bit weird; see https://tex.stackexchange.com/a/10672/76888.
