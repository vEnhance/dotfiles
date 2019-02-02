## qutebrowser config.py

c.backend = 'webengine'
c.content.pdfjs =  True
c.statusbar.hide = False
c.tabs.show = 'always'
c.url.default_page = 'http://web.evanchen.cc/static/browser-homepage.html'
c.url.searchengines = {
		'DEFAULT' : 'https://duckduckgo.com/?q={}'
		}
c.url.start_pages = c.url.default_page
# config.unbind('<Escape>', mode='insert')

c.input.insert_mode.auto_load  = True
c.input.insert_mode.auto_leave = False
