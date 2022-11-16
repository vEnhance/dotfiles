## qutebrowser config.py

config.load_autoconfig()

c.backend = 'webengine'
c.content.pdfjs = True
# c.statusbar.hide = False
c.tabs.show = 'always'
c.url.default_page = 'https://web.evanchen.cc/static/browser-homepage.html'
c.url.searchengines = {'DEFAULT': 'https://duckduckgo.com/?q={}'}
c.url.start_pages = c.url.default_page
# config.unbind('<Escape>', mode='insert')

c.input.insert_mode.auto_load = True
c.input.insert_mode.auto_leave = False
c.content.javascript.clipboard = False
c.content.javascript.enabled = False
c.zoom.default = 100
c.fonts.default_size = '16pt'

c.content.blocking.method = "both"
c.hints.chars = '1234567890'
c.tabs.background = False

config.bind('gt', 'tab-next')
config.bind('x', 'tab-close')
config.bind('<Ctrl-W>', 'close')
config.bind('d', 'scroll-page 0 0.5')
config.bind('u', 'scroll-page 0 -0.5')
config.bind('z', 'spawn firefox "{url}"')
config.bind('Backspace', 'config-source')
