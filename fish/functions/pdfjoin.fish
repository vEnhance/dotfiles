function pdfjoin
    qpdf $argv[1] --pages $argv[1..-2] -- $argv[-1]
end
