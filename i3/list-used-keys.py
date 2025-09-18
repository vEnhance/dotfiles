#!/usr/bin/env python3

import os
import re
import sys


def get_script_dir():
    """Get the directory where this script is located"""
    return os.path.dirname(os.path.abspath(__file__))


def main():
    """Parse i3 config and show used/available keybindings"""
    config_path = os.path.join(get_script_dir(), "config")

    if not os.path.exists(config_path):
        print(f"Error: {config_path} not found", file=sys.stderr)
        sys.exit(1)

    # Read config file
    with open(config_path, "r") as f:
        config_content = f.read()

    # Find all single-letter mod keybindings
    pattern = r"^bindsym \$mod\+([a-z]) (.*)$"
    matches = re.findall(pattern, config_content, re.MULTILINE)

    # Create dict of used keys and their bindings
    used_keys = {}
    for key, binding in matches:
        used_keys[key] = f"bindsym $mod+{key} {binding}"

    # Generate all letters a-z
    all_keys = [chr(i) for i in range(ord("a"), ord("z") + 1)]

    # ANSI color codes
    BOLD_YELLOW = "\033[1;33m"
    RESET = "\033[0m"

    # Print all 26 keys in order
    for key in all_keys:
        if key in used_keys:
            print(used_keys[key])
        else:
            print(f"{BOLD_YELLOW}$mod+{key} is free to use{RESET}")


if __name__ == "__main__":
    main()
