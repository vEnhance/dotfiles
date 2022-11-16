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
c.content.javascript.enabled = False
c.content.pdfjs = True
c.zoom.default = 100
c.fonts.default_size = '16pt'

c.content.blocking.method = "both"
c.hints.chars = '1234567890'
c.tabs.background = False

config.bind(r'x', 'tab-close')
config.bind(r'<Ctrl-W>', 'close')
config.bind(r'd', 'scroll-page 0 0.5')
config.bind(r'u', 'scroll-page 0 -0.5')
config.bind(r'E', 'spawn firefox "{url}"')
config.bind(r'Z', 'tab-only')
config.bind(r'<Backspace>', 'config-source')
config.bind(r'<Return>', 'tab-clone')
config.bind(r'<Space>', 'tab-give')
config.bind(r'|', 'mode-enter passthrough')

ALLOW_JAVASCRIPT_WEBSITES = (
    r'*://web.evanchen.cc/*',
    r'*://127.0.0.1/*',
    r'*://localhost/*',
    r'*://github.com/*',
    r'*://mit.edu/*',
    r'*://*.mit.edu/*',
    r'*://*.miro.com/*',
    r'*://*.play.pretzel.rocks/*',
    r'*://*.www.twitch.tv/*',
    r'*://hanab.live/*',
    r'*://artofproblemsolving.com/*',
)
for site in ALLOW_JAVASCRIPT_WEBSITES:
    config.set('content.javascript.enabled', True, site)
