## qutebrowser config.py

config.load_autoconfig()

c.backend = 'webengine'
c.content.pdfjs =  True
# c.statusbar.hide = False
c.tabs.show = 'always'
c.url.default_page = 'file:///home/evan/Documents/www/static/browser-homepage.html'
c.url.searchengines = {
		'DEFAULT' : 'https://duckduckgo.com/?q={}'
		}
c.url.start_pages = c.url.default_page
# config.unbind('<Escape>', mode='insert')

c.input.insert_mode.auto_load  = True
c.input.insert_mode.auto_leave = False
c.content.javascript.enabled = False

config.bind('gt', 'tab-next')
config.bind('x', 'tab-close')
config.bind('d', 'scroll-page 0 0.5')
config.bind('u', 'scroll-page 0 -0.5')
