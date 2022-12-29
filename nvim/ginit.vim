if hostname() ==# 'ArchScythe'
  Guifont! Inconsolata Semi Condensed SemiBold:h21
elseif hostname() ==# 'ArchDiamond'
  Guifont! Inconsolata Semi Condensed SemiBold:h20
elseif hostname() ==# 'ArchMajestic'
  Guifont! Inconsolata Semi Condensed SemiBold:h20
elseif hostname() ==# 'ArchSapphire'
  Guifont! Inconsolata Semi Condensed SemiBold:h20
elseif hostname() ==# 'dagobah'
  Guifont! Inconsolata Semi Condensed SemiBold:h21
else
  Guifont! Inconsolata Semi Condensed SemiBold:h22
endif
colorscheme reclipse

set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175
