function sha-phrase
    echo -n $argv[1] | sha256sum | cut -d ' ' -f 1
end
