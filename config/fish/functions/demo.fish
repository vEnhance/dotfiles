function demo --description 'Start bash with minimal prompt for demos'
    LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 env PS1='\n$ ' bash --norc --noprofile
end
