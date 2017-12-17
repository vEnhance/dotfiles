## qutebrowser config.py

c.backend = 'webkit'
c.content.pdfjs =  True
c.statusbar.hide = False
c.tabs.show = 'always'
c.url.default_page = 'file:///home/evan/dotfiles/homepage.html'
c.url.searchengines = {
		'DEFAULT' : 'https://duckduckgo.com/?q={}'
		}
c.url.start_pages = 'file:///home/evan/dotfiles/homepage.html'
# config.unbind('<Escape>', mode='insert')

c.input.insert_mode.auto_load  = True
c.input.insert_mode.auto_leave = False
