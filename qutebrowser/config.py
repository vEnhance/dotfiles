## qutebrowser config.py

from qutebrowser.api import interceptor

config.load_autoconfig()

c.backend = 'webengine'
c.content.blocking.method = "both"
c.content.javascript.enabled = False
c.content.pdfjs = False
c.downloads.position = 'bottom'
c.fonts.default_size = '16pt'
c.hints.auto_follow = 'unique-match'
c.hints.auto_follow_timeout = 700
c.hints.mode = 'number'
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
config.bind(r'|', 'tab-give')
config.bind('\\', 'mode-enter passthrough')

ALLOW_JAVASCRIPT_WEBSITES = (
    r'*://*.amazon.com/*',
    r'*://*.archlinux.org/*',
    r'*://*.bitwarden.com/*',
    r'*://*.duckduckgo.com/*',
    r'*://*.evanchen.cc/*',
    r'*://*.facebook.com/*',
    r'*://*.instagram.com/*',
    r'*://*.miro.com/*',
    r'*://*.mit.edu/*',
    r'*://*.pretzel.rocks/*',
    r'*://*.readthedocs.io/*',
    r'*://*.tailwindcss.com/*',
    r'*://*.www.twitch.tv/*',
    r'*://*.youtube.com/*',
    r'*://127.0.0.1/*',
    r'*://accounts.google.com/*',
    r'*://artofproblemsolving.com/*',
    r'*://bitwarden.com/*',
    r'*://calendar.google.com/*',
    r'*://discord.com/*',
    r'*://github.com/*',
    r'*://hanab.live/*',
    r'*://localhost/*',
    r'*://mit.edu/*',
    r'*://tailwindcomponents.com/*',
    r'*://tailwindcss.com/*',
    r'*://youtube.com/*',
)

for site in ALLOW_JAVASCRIPT_WEBSITES:
    config.set('content.javascript.enabled', True, site)


# Block youtube ads
def filter_youtube(info: interceptor.Request):
    """Block given request if necessary"""
    url = info.request_url
    if (url.host() == "www.youtube.com" and url.path() == "/get_video_info" and
            "&adformat=" in url.query()):
        info.block


interceptor.register(filter_youtube)
