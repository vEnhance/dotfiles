#!/bin/python3

import argparse
import secrets
import string

parser = argparse.ArgumentParser("gen-password")
parser.add_argument("length", type=int, nargs="?", default=16)
args = parser.parse_args()

symbols = "!@#$%^&*?"
alphabet = string.ascii_letters + string.digits + symbols
N: int = args.length
assert N >= 6

out_chars = [" "] * N
available_indices = list(range(N))


def set_char(choices):
    i = secrets.choice(available_indices)
    available_indices.remove(i)
    out_chars[i] = secrets.choice(choices)


set_char(symbols)
set_char(string.ascii_uppercase)
set_char(string.ascii_lowercase)
set_char(string.digits)

while len(available_indices) > 0:
    set_char(alphabet)
print("".join(out_chars))
