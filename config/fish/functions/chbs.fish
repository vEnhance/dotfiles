# correct horse battery staple
function chbs
    shuf -n 1000 /usr/share/dict/words | ag "^[a-z]{3,9}\$" | head -n 12
end
