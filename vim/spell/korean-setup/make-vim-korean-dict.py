import unicodedata

UNSUPPORTED_WORDS = (
    "LANG",
    "WORDCHARS",
    "ICONV",
    "OCONV",
    "AF",
    "MAXCPDSUGS",
    "MAXNGRAMSUGS",
    "MAXDIFF",
    "COMPOUNDMORESUFFIXES",
)

# Make the aff file but take out things unsupported by Vim
with open("/usr/share/hunspell/ko_KR.aff", "r", encoding="utf-8") as infile, open(
    "ko_KR.aff", "w", encoding="utf-8"
) as outfile:
    for line in infile:
        if not any(line.startswith(word) for word in UNSUPPORTED_WORDS):
            print(line.strip(), file=outfile)

# Make the dic file but re-normalize it to NFC
with open("/usr/share/hunspell/ko_KR.dic", "r", encoding="utf-8") as infile:
    content = infile.read()
content = unicodedata.normalize("NFC", content)
with open("ko_KR.dic", "w", encoding="utf-8") as outfile:
    print(content, file=outfile)
