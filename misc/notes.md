# Notes

## Regrets

- `py-scripts` and `sh-scripts` would be better called just `py` or `sh`,
  but there are lots of HTTPS GitHub links now and it's too late to move those.
- `texmf` should be under `dot` but similarly is too late to change now.

## Notes on tabs

- Hard tabs are no longer used.
- Python/Perl uses 4 spaces for indentation.
- Python is formatted using `ruff`, more broadly.
- Fish uses 4 spaces for indentation as well.
- Shell, Typescript, JS, CSS, VimScript use 2 spaces for indentation.
- Markdown/JS/CSS use `prettier` for formatting.
- LaTeX and Markdown also use 2 spaces for indentation.
- If not specified, generally use 2 spaces for tabs.

## Using ArchDiamond as a TV

Some things I should change when using this as a TV.

In `~/.Xresources`:

- Change `Xft.dpi` from `192` to `96`

In `about:config` of Firefox:

- Change `layout.css.devPixelsPerPx` from `2` to `1`
