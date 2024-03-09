# Based on
# - https://github.com/ideasman42/nerd-dictation/issues/59
# - https://github.com/ideasman42/nerd-dictation/blob/main/examples/default/nerd-dictation.py

import json
import re
import subprocess
from pathlib import Path

# -----------------------------------------------------------------------------
# Replace Multiple Words

TEXT_REPLACE_REGEX = (
    ("\\b" "data type" "\\b", "data-type"),
    ("\\b" "copy on write" "\\b", "copy-on-write"),
    ("\\b" "key word" "\\b", "keyword"),
    ("\\b" "paragraph" "\\b", "\r"),
    ("\\b" "new line" "\\b", "\r"),
)
TEXT_REPLACE_REGEX = tuple(
    (re.compile(match), replacement) for (match, replacement) in TEXT_REPLACE_REGEX
)


# -----------------------------------------------------------------------------
# Replace Single Words

# VOSK-API doesn't use capitals anywhere so they have to be explicit added in.
WORD_REPLACE = {
    "i": "I",
    "api": "API",
    "linux": "Linux",
    # It's also possible to ignore words entirely.
    "um": "",
}

# Regular expressions allow partial words to be replaced.
WORD_REPLACE_REGEX = (("^i'(.*)", "I'\\1"),)
WORD_REPLACE_REGEX = tuple(
    (re.compile(match), replacement) for (match, replacement) in WORD_REPLACE_REGEX
)

# -----------------------------------------------------------------------------
# Add Punctuation

CLOSING_PUNCTUATION = {
    "period": ".",
    "comma": ",",
    "coma": ",",  # this is easier to say
    "question mark": "?",
    "close quote": '"',
}

OPENING_PUNCTUATION = {
    "open quote": '"',
}

DICTATION_LAUNCHER_PATH = Path("~/dotfiles/sh-scripts/nerd-dictate.sh").expanduser()
STOP_SEQUENCE = ("STOP", "NOW")

# -----------------------------------------------------------------------------
# Main Processing Function


def nerd_dictation_process(text):
    for match, replacement in TEXT_REPLACE_REGEX:
        text = match.sub(replacement, text)

    for match, replacement in CLOSING_PUNCTUATION.items():
        text = text.replace(" " + match, replacement)

    for match, replacement in OPENING_PUNCTUATION.items():
        text = text.replace(match + " ", replacement)

    text = text.replace(" \r", "\r")
    text = text.replace("\r ", "\r")

    words = text.split(" ")

    for i, w in enumerate(words):
        w_init = w
        w_test = WORD_REPLACE.get(w)
        if w_test is not None:
            w = w_test
        if w_init == w:
            for match, replacement in WORD_REPLACE_REGEX:
                w_test = match.sub(replacement, w)
                if w_test != w:
                    w = w_test
                    break

        words[i] = w

    # Strip any words that were replaced with empty strings.
    words[:] = [w for w in words if w]

    # Stop dictation if the stop sequence appears
    if tuple(x.upper() for x in words[-len(STOP_SEQUENCE) :]) == STOP_SEQUENCE:
        words = words[: -len(STOP_SEQUENCE)]
        subprocess.run([DICTATION_LAUNCHER_PATH, "stop"])

    text = " ".join(words)

    # Add sentence case
    REGEX_SENTENCE = re.compile(r"([\.?!] |\r)[a-z]")
    text = REGEX_SENTENCE.sub(lambda match: match.group(0).upper(), text)
    # text = "\n".join(line[:1].upper() + line[1:] for line in text.splitlines())

    return text


def langtool(text, language):
    assert language == "en-US"
    orig_len = len(text)
    new_len = 0
    r = subprocess.check_output(
        ["languagetool", "-l", language, "--json"],
        input=text,
        text=True,
    )

    for m in json.loads(r)["matches"]:
        # len(text) can change while iterating due to additions or deletions,
        # which breaks the offset. Adjust the offset if length changes:
        if new_len:
            adj = new_len - orig_len
        else:
            adj = 0

        o = m["offset"] + adj
        n = m["length"]

        if m["rule"]["id"] in ["TOO_LONG_SENTENCE"]:
            # Skip rules from Language Tool that you don't want:
            print("============== langtool skipping ID: " + m["rule"]["id"])

        elif len(m["replacements"]) >= 1:
            # Try the first replacement
            text = text[:o] + m["replacements"][0]["value"] + text[o + n :]

        elif n > 0:
            # No replacement suggestions, but a length is provided so point out
            # the unexpected content with square brackets:
            text = text[:o] + "[" + text[o : o + n + 1] + "]" + text[o + n + 1 :]

        else:
            # If we get here this is probably an unhandled case:
            print("\n\n======== langtool no replacement? " + text)

            # Limit the "replacements" list to prevent huge debug:
            m["replacements"] = m["replacements"][0:3]

        new_len = len(text)

    return text
