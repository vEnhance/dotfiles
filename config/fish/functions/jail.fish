function jail -d "Starts a ethereal Fish shell"
    fish --private --no-config --init-command=(string join "; " \
        "fish_config prompt choose arrow" \
        "fish_config theme choose 'Base16 Default Dark'" \
        "source /usr/share/fish/functions/fish_greeting.fish" \
        "fish_greeting" \
        "fish_vi_key_bindings" \
    )
end
