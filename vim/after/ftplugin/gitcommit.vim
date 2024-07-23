setlocal tabstop=4
let b:ale_fixers = []
let b:ale_fix_on_save = 0

" https://www.reddit.com/r/vim/comments/dj37wt/plugin_for_conventional_commits/
inoreabbrev <buffer> BB BREAKING CHANGE:
let b:airline_whitespace_disabled = 1
