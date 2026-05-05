#!/usr/bin/env python3

import json
import os
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

# POST_BODY and NUMBER are replaced by Python; {{token}} by Postmark.
TEXT_TEMPLATE = """\
#NUMBER. POST_BODY

* Posted at https://wall.evanchen.cc/NUMBER/
* To edit mail settings, visit: https://list.evanchen.cc/edit/{{token}}
"""

HTML_SUFFIX = r'<p><i><a href="https://list.evanchen.cc/edit/{{token}}">Edit mail settings</a>.</i></p>'


def main():
    # read the most recent post
    with open(WALL_RECENT_DATA) as f:
        recent_data = json.load(f)
        number: int = recent_data["number"]
        body: str = recent_data["body"]
        assert recent_data["sent"] is False
    # mark recent_data["sent"] as True to prevent duplication
    recent_data["sent"] = True
    with open(WALL_RECENT_DATA, "w") as f:
        json.dump(recent_data, f, indent=2)

    print("Fetching subscriber list ...")
    resp = requests.get(
        LIST_API_URL,
        headers={"Authorization": f"Bearer {LIST_API_TOKEN}"},
        timeout=15,
    )
    resp.raise_for_status()
    subscribers = resp.json()["subscribers"]

    text_body = TEXT_TEMPLATE.replace("NUMBER", str(number)).replace("POST_BODY", body)
    markdown_body = f"[**#{number}**](https://wall.evanchen.cc/{number}). " + body
    html_body = markdown.markdown(markdown_body) + HTML_SUFFIX

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
    print(f"Sending #{number} to {len(subscribers)} recipient(s) ...")
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


if __name__ == "__main__":
    main()
