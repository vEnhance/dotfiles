## qutebrowser config.py

config.load_autoconfig()

c.backend = 'webengine'
c.content.blocking.method = "both"
c.content.javascript.enabled = False
c.content.pdfjs = True
c.content.pdfjs = True
c.fonts.default_size = '16pt'
c.hints.chars = '1234567890'
c.input.insert_mode.auto_leave = False
c.input.insert_mode.auto_load = True
c.tabs.background = False
c.tabs.last_close = 'close'
c.tabs.show = 'always'
c.url.default_page = 'https://web.evanchen.cc/static/browser-homepage.html'
c.url.searchengines = {'DEFAULT': 'https://duckduckgo.com/?q={}'}
c.url.start_pages = c.url.default_page
c.zoom.default = 100

config.bind(r'<Backspace>', 'config-source')
config.bind(r'<Ctrl-W>', 'tab-close')
config.bind(r'<Return>', 'tab-clone')
config.bind(r'E', 'spawn firefox "{url}"')
config.bind(r'W', 'spawn --userscript qute-bitwarden')
config.bind(r'Z', 'tab-only')
config.bind(r'd', 'scroll-page 0 0.5')
config.bind(r'u', 'scroll-page 0 -0.5')
config.bind(r'x', 'tab-close')
config.bind(r'|', 'mode-enter passthrough')
config.bind('\\', 'tab-give')

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
    r'*://bitwarden.com/*',
)
for site in ALLOW_JAVASCRIPT_WEBSITES:
    config.set('content.javascript.enabled', True, site)
