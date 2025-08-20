## qutebrowser config.py

import datetime
from typing import TYPE_CHECKING, Any

from qutebrowser.api import interceptor

if TYPE_CHECKING:
    c: Any = object
    config: Any = object

config.load_autoconfig()

c.backend = "webengine"
c.colors.downloads.stop.bg = r"#00cca7"
c.content.blocking.method = "both"
c.content.javascript.enabled = False
c.content.pdfjs = True
c.downloads.position = "bottom"
c.downloads.remove_finished = 5000
c.fonts.default_size = "16pt"
c.hints.auto_follow = "unique-match"
c.hints.auto_follow_timeout = 700
c.hints.mode = "number"
c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = True
c.input.insert_mode.auto_load = True
c.tabs.background = False
c.tabs.last_close = "close"
c.tabs.show = "always"
c.url.default_page = "https://web.evanchen.cc/static/browser-homepage.html"
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "wiktionary": "https://wiktionary.org/wiki/{}",
    "htsk": "https://web.evanchen.cc/static/htsk.html?q={}",
}
c.url.start_pages = c.url.default_page
c.zoom.default = 100

c.qt.force_software_rendering = "chromium"  # QT grief :')

config.bind(r"<Backspace>", "config-source")
config.bind(r"<Ctrl-W>", "tab-close")
# config.bind(r'<Return>', 'download-clear')
config.bind(r"<Space>", "cmd-set-text -s :open wiktionary ")
config.bind(r"e", "tab-clone")
config.bind(r"E", 'spawn firefox "{url}"')
config.bind(r"Z", "tab-only")
config.bind(r"d", "scroll-page 0 0.5")
config.bind(r"u", "scroll-page 0 -0.5")
config.bind(r"x", "tab-close")
config.bind(r"|", "tab-give")
config.bind("\\", "mode-enter passthrough")

ALLOW_JAVASCRIPT_WEBSITES = (
    r"*://*.0xparc.org/*",
    r"*://*.amazon.com/*",
    r"*://*.archlinux.org/*",
    r"*://*.bitwarden.com/*",
    r"*://*.commonapp.org/*",
    r"*://*.crosserville.com/*",
    r"*://*.duckduckgo.com/*",
    r"*://*.evanchen.cc/*",
    r"*://*.facebook.com/*",
    r"*://*.firebaseapp.com/*",
    r"*://*.galacticpuzzlehunt.com/*",
    r"*://*.g2mathprogram.org/*",
    r"*://*.github.com/*",
    r"*://*.gradescope.com/*",
    r"*://*.hanabi.github.io/*",
    r"*://*.hmmt.org/*",
    r"*://*.howtostudykorean.com/*",
    r"*://*.imo-official.org/*",
    r"*://*.instagram.com/*",
    r"*://*.itch.io/*",
    r"*://*.komal.hu/*",
    r"*://*.lmfdb.org/*",
    r"*://*.miro.com/*",
    r"*://*.mit.edu/*",
    r"*://*.mitadmissions.org/*",
    r"*://*.monkeytype.com/*",
    r"*://*.myaccount.google.com/*",
    r"*://*.naver.com/*",
    r"*://*.notion.so/*",
    r"*://*.notion.site/*",
    r"*://*.overleaf.com/*",  # their documentation is admittedly not bad
    r"*://*.pretzel.rocks/*",
    r"*://*.probase.app/*",
    r"*://*.pythonanywhere.com/*",
    r"*://*.readthedocs.io/*",
    r"*://*.reference.slideroom.com/*",
    r"*://*.sagemath.org/*",
    r"*://*.stackexchange.com/*",
    r"*://*.steampowered.com/*",
    r"*://*.stripe.com/*",
    r"*://*.tailwindcss.com/*",
    r"*://*.teammatehunt.com/*",
    r"*://*.torproject.com/*",
    r"*://*.twitch.tv/*",
    r"*://*.wikipedia.org/*",
    r"*://*.wolframalpha.com/*",
    r"*://*.wikidata.org/*",
    r"*://*.usaco.org/*",
    r"*://*.youtube.com/*",
    r"*://0xparc.org/*",
    r"*://127.0.0.1/*",
    r"*://accounts.google.com/*",
    r"*://artofproblemsolving.com/*",
    r"*://arxiv.org/*",
    r"*://atcoder.jp/*",
    r"*://athemath.org/*",
    r"*://bitwarden.com/*",
    r"*://calendar.google.com/*",
    r"*://calendly.com/*",
    r"*://claude.ai/*",
    r"*://codeforces.com/*",
    r"*://dennisc.net/*",
    r"*://devjoe.appspot.com/*",
    r"*://discord.com/*",
    r"*://docs.google.com/*",
    r"*://drive.google.com/*",
    r"*://duckduckgo.com/*",
    r"*://gitlab.com/*",
    r"*://github.com/*",
    r"*://groups.google.com/*",
    r"*://hackmd.io/*",
    r"*://hanabi-competitions.com/*",
    r"*://hanabi.github.io/*",
    r"*://hanabi-league.com/*",
    r"*://hanabi-league.github.io/*",
    r"*://hanab.live/*",
    r"*://ioinformatics.org/*",
    # r"*://liquipedia.net/*",
    r"*://localhost/*",
    r"*://login.artofproblemsolving.com/*",
    r"*://mathoverflow.net/*",
    r"*://mit.edu/*",
    r"*://poll.ma.pe/*",
    r"*://projecteuler.net/*",
    r"*://pypi.org/*",
    r"*://nightbot.tv/*",
    r"*://regex101.com/*",
    r"*://sc2replaystats.com/*",
    r"*://stackoverflow.com/*",
    r"*://steamcommunity.com/*",
    r"*://streamlabs.com/*",
    r"*://swaroopg92.github.io/*",
    r"*://tailwindcomponents.com/*",
    r"*://tailwindcss.com/*",
    r"*://translate.google.com/*",
    r"*://typst.app/*",
    r"*://usaco.guide/*",
    r"*://usaco.org/*",
    r"*://usamo.wordpress.com/*",
    r"*://wordpress.com/*",
    r"*://www.google.com/maps/*",
    r"*://xkcd.com/*",
    r"*://youtube.com/*",
)

for site in ALLOW_JAVASCRIPT_WEBSITES:
    config.set("content.javascript.enabled", True, site)
    config.set("content.javascript.clipboard", "access-paste", site)


# Block youtube ads
def filter_youtube(info: interceptor.Request):
    """Block given request if necessary"""
    url = info.request_url
    if (
        url.host() == "www.youtube.com"
        and url.path() == "/get_video_info"
        and "&adformat=" in url.query()
    ):
        info.block()


interceptor.register(filter_youtube)


def block_wikipedia(info: interceptor.Request):
    now = datetime.datetime.now()
    if 0 <= now.hour < 8 and "wikipedia.org" in info.request_url.host():
        info.block()


interceptor.register(block_wikipedia)
