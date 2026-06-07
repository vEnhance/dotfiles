#!/usr/bin/env python3

import json
import os
import re
import time
from pathlib import Path

import markdown
import requests
from dotenv import load_dotenv

WALL_RECENT_DATA = Path("~/Sync/Websites/wall.evanchen.cc/latest.json").expanduser()
LIST_API_URL = "https://list.evanchen.cc/api/subs/wall/"
POSTMARK_BULK_URL = "https://api.postmarkapp.com/email/bulk"

load_dotenv(Path("~/secrets/broadcasts.env").expanduser())
LIST_API_TOKEN = os.environ["LIST_API_TOKEN"]
POSTMARK_SERVER_TOKEN = os.environ["POSTMARK_SERVER_TOKEN"]
WALL_VENHANCE_DISCORD_WEBHOOK = os.environ["WALL_VENHANCE_DISCORD_WEBHOOK"]

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
    """
    parts = re.split(r"(```.*?```)", text, flags=re.DOTALL)
    result = []
    for i, part in enumerate(parts):
        if i % 2 == 1:
            result.append(part)
        else:
            result.append("\n\n".join(p.replace("\n", " ") for p in part.split("\n\n")))
    return "".join(result)


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
        body: str = recent_data["body"]
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
    markdown_body = f"[**#{number}**](https://wall.evanchen.cc/{number}). " + body
    html_body = markdown.markdown(markdown_body) + HTML_SUFFIX
    discord_content = (
        f"[**#{number}**](https://wall.evanchen.cc/{number}/). {unwrap(body)}"
    )

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
