function aes-encode
    openssl aes-256-cbc -a -salt -pbkdf2 -pass pass:$argv
end
