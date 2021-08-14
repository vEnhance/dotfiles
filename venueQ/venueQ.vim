" venueQ.vim

exec "py3file " . expand('<sfile>:p:h') . "/venueQ.py"
exec "py3file " . argv(0)

py3 << EOF

EOF
