function aes-decode
    openssl aes-256-cbc -a -d -pbkdf2 -pass pass:$argv
end
