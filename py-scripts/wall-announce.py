#!/usr/bin/env python3

import json
import re
import subprocess
import time
from pathlib import Path

import markdown
import requests


def get_pass(s: str) -> str:
    return subprocess.check_output(("pass", "show", s), text=True).strip()


WALL_BASE_URL = "https://wall.evanchen.cc"
WALL_RECENT_DATA = Path("~/Sync/Websites/wall.evanchen.cc/latest.json").expanduser()
LIST_API_URL = "https://list.evanchen.cc/api/subs/wall/"
POSTMARK_BULK_URL = "https://api.postmarkapp.com/email/bulk"

LIST_API_TOKEN = get_pass("evanchen.cc/list")
POSTMARK_SERVER_TOKEN = get_pass("postmark/list")
WALL_VENHANCE_DISCORD_WEBHOOK = get_pass("discord/wall")

# POST_BODY and NUMBER are replaced by Python; {{token}} by Postmark.
TEXT_TEMPLATE = """\
#NUMBER. POST_BODY

* Posted at https://wall.evanchen.cc/NUMBER/
* To edit mail settings, visit: https://list.evanchen.cc/edit/{{token}}
* Replies welcome
"""

HTML_SUFFIX = (
    r"<p><i>"
    r'<a href="https://list.evanchen.cc/edit/{{token}}">Edit mail settings</a>. '
    r"Replies welcome."
    r"</i></p>"
)

POLL_INTERVAL_FIRST = 30
POLL_INTERVAL = 15
POLL_TIMEOUT = 90


BLOCKQUOTE_MARKER = re.compile(r"^ {0,3}(?:>\s?)+")
LIST_MARKER = re.compile(r"^ {0,3}(?:[-*+]|\d{1,9}[.)])(?:\s|$)")


def join_lines(lines: list[str]) -> list[str]:
    r"""Join soft-wrapped lines, starting a fresh line at each list item.

    >>> join_lines(["one", "two"])
    ['one two']
    >>> join_lines(["- first item", "  wrapped", "- second item"])
    ['- first item wrapped', '- second item']
    >>> join_lines(["text", "*emph* is not a bullet"])
    ['text *emph* is not a bullet']
    """
    joined: list[str] = []
    for line in lines:
        if not line.strip():
            continue
        if joined and not LIST_MARKER.match(line):
            joined[-1] += " " + line.strip()
        else:
            joined.append(line.strip())
    return joined


def unwrap_paragraph(para: str) -> str:
    r"""Join the soft-wrapped lines of a single paragraph.

    Blockquotes keep exactly one `>` marker, on the front of the joined line,
    instead of dragging one along per soft-wrapped line; list items stay on
    their own lines instead of being run together.

    >>> unwrap_paragraph("line one\nline two")
    'line one line two'
    >>> unwrap_paragraph("> quoted one\n> quoted two")
    '> quoted one quoted two'
    >>> unwrap_paragraph("> lazy quote\ncontinuation")
    '> lazy quote continuation'
    >>> unwrap_paragraph("> quote one\n>\n> quote two")
    '> quote one\n> quote two'
    >>> unwrap_paragraph("- one\n- two")
    '- one\n- two'
    >>> unwrap_paragraph("1. first\n2. second that is\n   wrapped")
    '1. first\n2. second that is wrapped'
    >>> unwrap_paragraph("intro:\n- one\n- two")
    'intro:\n- one\n- two'
    >>> unwrap_paragraph("> - quoted one\n> - quoted two")
    '> - quoted one\n> - quoted two'
    """
    lines = para.split("\n")
    lead = ""
    while lines and not lines[0].strip():
        lead += lines.pop(0) + "\n"
    if not lines:
        return para
    if not BLOCKQUOTE_MARKER.match(lines[0]):
        return lead + "\n".join(join_lines(lines))
    # a `>`-only line separates paragraphs inside the quote; keep them apart
    groups: list[list[str]] = [[]]
    for line in lines:
        content = BLOCKQUOTE_MARKER.sub("", line)
        if content.strip():
            groups[-1].append(content)
        elif groups[-1]:
            groups.append([])
    return lead + "\n".join(
        "> " + line for group in groups if group for line in join_lines(group)
    )


def unwrap(text: str) -> str:
    r"""Join soft-wrapped lines within paragraphs, preserving code blocks.

    >>> unwrap("hello world")
    'hello world'
    >>> unwrap("line one\nline two\n\nnew para")
    'line one line two\n\nnew para'
    >>> unwrap("before\n\n```\ncode\nhere\n```\n\nafter")
    'before\n\n```\ncode\nhere\n```\n\nafter'
    >>> unwrap("a\nb\n\n```python\nx = 1\ny = 2\n```\n\nc\nd")
    'a b\n\n```python\nx = 1\ny = 2\n```\n\nc d'
    >>> unwrap("intro\n\n> quote a\n> quote b\n\nafter")
    'intro\n\n> quote a quote b\n\nafter'
    >>> unwrap("a\n\n```\n> code\n> quote\n```\n\n> real\n> quote")
    'a\n\n```\n> code\n> quote\n```\n\n> real quote'
    >>> unwrap("intro\n\n- one\n- two that is\n  wrapped\n\nafter")
    'intro\n\n- one\n- two that is wrapped\n\nafter'
    """
    parts = re.split(r"(```.*?```)", text, flags=re.DOTALL)
    result = []
    for i, part in enumerate(parts):
        if i % 2 == 1:
            result.append(part)
        else:
            result.append("\n\n".join(unwrap_paragraph(p) for p in part.split("\n\n")))
    return "".join(result)


def absolutize(text: str, base: str = WALL_BASE_URL) -> str:
    r"""Prefix root-relative links with `base`, so they work outside the site.

    >>> absolutize("see [link to post](/266) here")
    'see [link to post](https://wall.evanchen.cc/266) here'
    >>> absolutize("![fig](/static/x.png)")
    '![fig](https://wall.evanchen.cc/static/x.png)'
    >>> absolutize('[ref]: /266 "Title"')
    '[ref]: https://wall.evanchen.cc/266 "Title"'
    >>> absolutize('<a href="/266">x</a>')
    '<a href="https://wall.evanchen.cc/266">x</a>'
    >>> absolutize("[a](https://example.com/1), [b](//example.com/2), [c](266)")
    '[a](https://example.com/1), [b](//example.com/2), [c](266)'
    >>> absolutize("a\n\n```\n[x](/1)\n```\n\n[y](/2)")
    'a\n\n```\n[x](/1)\n```\n\n[y](https://wall.evanchen.cc/2)'
    """
    # a leading `//` is protocol-relative, hence already absolute
    patterns = (
        r"(\]\(\s*<?)/(?!/)",  # [text](/266), ![fig](/x.png), [text](</266>)
        r"(?m)^( {0,3}\[[^\]\n]+\]:\s*<?)/(?!/)",  # [ref]: /266
        r"""((?:href|src)=["'])/(?!/)""",  # <a href="/266">
    )
    parts = re.split(r"(```.*?```)", text, flags=re.DOTALL)
    for i, part in enumerate(parts):
        if i % 2 == 0:
            for pattern in patterns:
                part = re.sub(pattern, lambda m: f"{m[1]}{base}/", part)
            parts[i] = part
    return "".join(parts)


def wait_for_post(number: int) -> None:
    url = f"https://wall.evanchen.cc/{number}/"
    print(f"Waiting for {url} to go live…")
    deadline = time.monotonic() + POLL_TIMEOUT
    while time.monotonic() < deadline:
        r = requests.get(url, timeout=15)
        if r.status_code != 404:
            print(f"Post is live (HTTP {r.status_code}).")
            return
        remaining = int(deadline - time.monotonic())
        print(
            f"  Still 404, retrying in {POLL_INTERVAL}s ({remaining}s left before timeout)…"
        )
        time.sleep(POLL_INTERVAL)
    raise TimeoutError(f"Post #{number} never went live after {POLL_TIMEOUT}s")


def main():
    # Step 1. Read the most recent post
    with open(WALL_RECENT_DATA) as f:
        recent_data = json.load(f)
        number: int = recent_data["number"]
        body: str = absolutize(recent_data["body"])
        assert recent_data["sent"] is False, f"girl #{number} was already sent"

    # Step 2. Get subscriber list
    print("Fetching subscriber list…")
    resp = requests.get(
        LIST_API_URL,
        headers={"Authorization": f"Bearer {LIST_API_TOKEN}"},
        timeout=15,
    )
    resp.raise_for_status()
    subscribers = resp.json()["subscribers"]
    print(f"Found {len(subscribers)} subscribers. You're such a celebrity! /s")

    # Step 3. Render the post
    text_body = TEXT_TEMPLATE.replace("NUMBER", str(number)).replace("POST_BODY", body)
    markdown_body = f"[**#{number}**]({WALL_BASE_URL}/{number}). " + body
    html_body = markdown.markdown(markdown_body) + HTML_SUFFIX
    discord_content = f"[**#{number}**]({WALL_BASE_URL}/{number}/). {unwrap(body)}"

    # Step 4. Wait for post to go live
    print("Waiting 30 seconds before starting polling…")
    time.sleep(POLL_INTERVAL_FIRST)
    wait_for_post(number)

    # Step 5. Mark recent_data["sent"] as True to prevent duplication
    recent_data["sent"] = True
    with open(WALL_RECENT_DATA, "w") as f:
        json.dump(recent_data, f, indent=2)

    # Step 6. Send Postmark email
    payload = {
        "From": "Evan Chen <evan@evanchen.cc>",
        "Subject": f"[wall.evanchen.cc] #{number}",
        "TextBody": text_body,
        "HtmlBody": html_body,
        "MessageStream": "wall-evanchen-cc",
        "Messages": [
            {"To": sub["email"], "TemplateModel": {"token": sub["token"]}}
            for sub in subscribers
        ],
    }
    print(f"Sending #{number} via Postmark…")
    resp = requests.post(
        POSTMARK_BULK_URL,
        json=payload,
        headers={
            "Accept": "application/json",
            "Content-Type": "application/json",
            "X-Postmark-Server-Token": POSTMARK_SERVER_TOKEN,
        },
        timeout=60,
    )
    resp.raise_for_status()

    # Step 7. Send Discord
    print("Sending Discord notification…")
    dresp = requests.post(
        WALL_VENHANCE_DISCORD_WEBHOOK,
        json={"content": discord_content},
        timeout=15,
    )
    dresp.raise_for_status()


if __name__ == "__main__":
    main()
