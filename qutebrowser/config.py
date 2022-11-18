## qutebrowser config.py

config.load_autoconfig()

c.backend = 'webengine'
c.content.blocking.method = "both"
c.content.javascript.enabled = False
c.content.pdfjs = False
c.fonts.default_size = '16pt'
c.hints.chars = '1234567890'
c.input.insert_mode.auto_leave = True
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
config.bind(r'<Return>', 'download-clear')
config.bind(r'e', 'tab-clone')
config.bind(r'E', 'spawn firefox "{url}"')
config.bind(r'W', 'spawn --userscript qute-bitwarden')
config.bind(r'Z', 'tab-only')
config.bind(r'd', 'scroll-page 0 0.5')
config.bind(r'u', 'scroll-page 0 -0.5')
config.bind(r'x', 'tab-close')
config.bind(r'|', 'mode-enter passthrough')
config.bind('\\', 'tab-give')

ALLOW_JAVASCRIPT_WEBSITES = (
    r'*://*.archlinux.org/*',
    r'*://*.bitwarden.com/*',
    r'*://*.duckduckgo.com/*',
    r'*://*.evanchen.cc/*',
    r'*://*.miro.com/*',
    r'*://*.mit.edu/*',
    r'*://*.pretzel.rocks/*',
    r'*://*.readthedocs.io/*',
    r'*://*.tailwindcss.com/*',
    r'*://*.www.twitch.tv/*',
    r'*://127.0.0.1/*',
    r'*://accounts.google.com/*',
    r'*://artofproblemsolving.com/*',
    r'*://bitwarden.com/*',
    r'*://discord.com/*',
    r'*://github.com/*',
    r'*://hanab.live/*',
    r'*://localhost/*',
    r'*://mit.edu/*',
    r'*://tailwindcomponents.com/*',
    r'*://tailwindcss.com/*',
)

for site in ALLOW_JAVASCRIPT_WEBSITES:
    config.set('content.javascript.enabled', True, site)
