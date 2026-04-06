## Korean spellcheck files for NFC format

Wow was this was way harder than I thought it would be.
If you just want the generated binary file, you can find
[ko.utf-8.spl](../ko.utf-8.spl) in the directory above this one.

If you're curious how this was made:

1. Install the [Hunspell dictionary for Korean](https://github.com/spellcheck-ko/hunspell-dict-ko);
   Arch users can find it [in the AUR](https://aur.archlinux.org/packages/hunspell-ko).
2. Run `make-vim-korean-dict.py` to generate the two output files `ko_KR.aff`
   and `ko_KR.dic` which are adapted to be readable by VIM.
   - `ko_KR.aff` is modified by removing the commands not supported by VIM, most
     notably `ICONV` and `OCONV` that allow either NFD on NFC encodings to be
     used.
   - `ko_KR.dic` is changed from NFD to NFC encoding, which seems to be more
     common.
   - In an ideal world, I'd really support both, but this is the stopgap for
     now.
3. Open Vim and run `:mkspell /tmp/ko ~/dotfiles/vim/spell/korean-setup/ko_KR`.
   This generates the file `/tmp/ko.utf-8.spl`.
4. Move the generated file into `~/.vim/spell`, or somewhere Vim can find it.
5. Make sure `spelllang` includes `ko`.
