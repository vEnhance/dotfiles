"""CommonMark rendering shared by my scripts (md alias, mutt, otis, wall-announce).

Uses markdown-it-py, so lists nest by content column (2 spaces is fine),
don't need a blank line before them, and keep their start number.
"""

import re
import sys

from markdown_it import MarkdownIt
from markdown_it.common.utils import escapeHtml
from markdown_it.rules_core import StateCore
from mdit_py_plugins.deflist import deflist_plugin
from mdit_py_plugins.dollarmath import dollarmath_plugin
from mdit_py_plugins.footnote import footnote_plugin

PREAMBLE = r"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">

<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Mate">
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Verdana">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"></script>

<link rel="apple-touch-icon" sizes="180x180" href="https://web.evanchen.cc/icons/apple-touch-icon.png">
<link rel="icon" type="image/png" href="https://web.evanchen.cc/icons/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="https://web.evanchen.cc/icons/favicon-16x16.png" sizes="16x16">
<link rel="manifest" href="https://web.evanchen.cc/icons/manifest.json">
<link rel="mask-icon" href="https://web.evanchen.cc/icons/safari-pinned-tab.svg" color="#5bbad5">
<link rel="shortcut icon" href="https://web.evanchen.cc/icons/favicon.ico">

<meta name="msapplication-config" content="https://web.evanchen.cc/icons/browserconfig.xml">
<meta name="theme-color" content="#ffffff">
<link type="text/css" rel="stylesheet" href="https://web.evanchen.cc/css/simple-53544.css">

<script type="text/javascript">
MathJax = {
    tex: {
        inlineMath: [['$','$'], ['\\(','\\)']],
        displayMath: [['\\[', '\\]']],
    }
};
</script>
<script type="text/javascript" id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
</script>
</head>

<body>
<div id="container">
<div id="content">"""


_SMARTY_SUBS = (
    (re.compile(r"---"), "\u2014"),
    (re.compile(r"--"), "\u2013"),
    (re.compile(r"\.\.\."), "\u2026"),
)


def _smart_punctuation(state: StateCore) -> None:
    """Dashes and ellipses only, like Python-Markdown's smarty.

    The stock "replacements" rule also turns (c) into a copyright sign,
    which wrecks problem parts labelled (a), (b), (c).
    """
    for block in state.tokens:
        if block.type != "inline" or not block.children:
            continue
        in_autolink = False
        for token in block.children:
            if token.type == "link_open" and token.info == "auto":
                in_autolink = True
            elif token.type == "link_close" and token.info == "auto":
                in_autolink = False
            elif token.type == "text" and not in_autolink:
                for pattern, repl in _SMARTY_SUBS:
                    token.content = pattern.sub(repl, token.content)


def _keep_tex(content: str, opts: dict) -> str:
    """Pass math through verbatim (protected from emphasis parsing) for MathJax."""
    tex = escapeHtml(content)
    return f"\\[{tex}\\]" if opts["display_mode"] else f"${tex}$"


_md = (
    MarkdownIt("commonmark", {"html": True, "typographer": True})
    .enable(["table", "strikethrough", "smartquotes"])
    .use(footnote_plugin)
    .use(deflist_plugin)
    .use(dollarmath_plugin, allow_space=False, allow_digits=False, renderer=_keep_tex)
)
_md.core.ruler.before("smartquotes", "smart_punctuation", _smart_punctuation)


def markdown(content: str) -> str:
    return _md.render(content)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as f:
            content = "".join(f.readlines())
    else:
        content = "".join(sys.stdin.readlines())
    print(PREAMBLE)
    print(markdown(content))
    print("</div></div>")
    print(r"</body></html>")
