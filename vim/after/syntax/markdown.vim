scriptencoding 'utf-8'
if !has('gui_running')
  hi mkdLink ctermfg=87
  hi link mkdHeading Special
  hi htmlH1 ctermfg=red
  hi htmlH2 ctermfg=red
  hi htmlH3 ctermfg=red
  hi htmlH4 ctermfg=red
  hi htmlH5 ctermfg=red
  hi htmlH6 ctermfg=red
endif

syn region mkdURL matchgroup=mkdDelimiter   start="("     end=")"  contained oneline contains=protocol,truncate
syn region mkdLinkDefTarget start="<\?\zs\S" excludenl end="\ze[>[:space:]\n]"   contained nextgroup=mkdLinkTitle,mkdLinkDef skipwhite skipnl oneline contains=protocol,truncate

syn match protocol `https\:` contained cchar=: conceal
syn match truncate `\%(///\=[^/ \t]\+/\)\zs\S\+\ze\%([/#?]\w\|\S\{10}\)` contained cchar=… conceal
hi link protocol mkdURL
hi link truncate mkdURL

hi link mkdLinkDefTarget mkdURL
hi mkdURL ctermfg=Gray

call SyntaxRange#Include('```bash', '```', 'bash', 'PreProc')
call SyntaxRange#Include('```c', '```', 'c', 'PreProc')
call SyntaxRange#Include('```coffee', '```', 'coffee', 'PreProc')
call SyntaxRange#Include('```cpp', '```', 'cpp', 'PreProc')
call SyntaxRange#Include('```css', '```', 'css', 'PreProc')
call SyntaxRange#Include('```diff', '```', 'diff', 'PreProc')
call SyntaxRange#Include('```html', '```', 'html', 'PreProc')
call SyntaxRange#Include('```jjavascript', '```', 'javascript', 'PreProc')
call SyntaxRange#Include('```js', '```', 'javascript', 'PreProc')
call SyntaxRange#Include('```json', '```', 'json', 'PreProc')
call SyntaxRange#Include('```jsonc', '```', 'jsonc', 'PreProc')
call SyntaxRange#Include('```latex', '```', 'tex', 'PreProc')
call SyntaxRange#Include('```mysql', '```', 'mysql', 'PreProc')
call SyntaxRange#Include('```python', '```', 'python', 'PreProc')
call SyntaxRange#Include('```sh', '```', 'sh', 'PreProc')
call SyntaxRange#Include('```shell', '```', 'sh', 'PreProc')
call SyntaxRange#Include('```sql', '```', 'sql', 'PreProc')
call SyntaxRange#Include('```ts', '```', 'typescript', 'PreProc')
call SyntaxRange#Include('```text', '```', 'text', 'PreProc')
call SyntaxRange#Include('```txt', '```', 'text', 'PreProc')
call SyntaxRange#Include('```typescript', '```', 'typescript', 'PreProc')
call SyntaxRange#Include('```xml', '```', 'xml', 'PreProc')
call SyntaxRange#Include('```yaml', '```', 'yaml', 'PreProc')
call SyntaxRange#Include('```yml', '```', 'yaml', 'PreProc')

set spell
