# Implements https://zoo.cs.yale.edu/classes/cs461/2009/lectures/ln21.pdf
# Definitely not a good use of my time.

import argparse
import getpass
import json
import random
import secrets
from pathlib import Path

MAX = 1001
N = 192
PAYLOAD_FILENAME = "yao-payload.json"
KEY_FILENAME = "yao-key.json"


def miller_rabin_test(n, k=5):
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0:
        return False
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    for _ in range(k):
        a = random.randint(2, n - 2)
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def generate_n_bit_prime(n):
    while True:
        candidate = secrets.randbits(n)
        candidate |= (1 << n - 1) | 1  # Ensure candidate is n-bits and odd
        if miller_rabin_test(candidate):
            return candidate


def generate_key_pair(bits):
    p = generate_n_bit_prime(bits)
    q = generate_n_bit_prime(bits)
    e = 65537

    while p % e == 1:
        p = generate_n_bit_prime(bits)
    while q % e == 1:
        q = generate_n_bit_prime(bits)

    n = p * q
    phi = (p - 1) * (q - 1)

    d = pow(e, -1, phi)
    return (e, d, n)


parser = argparse.ArgumentParser("yao", description="Run millionaire problem.")
parser.add_argument("salary", nargs="?", type=int, default=None)
parser.add_argument(
    "-n", "--nocache", action="store_true", help="Don't save the RSA key."
)
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--alice", action="store_true", help="Specify you are Alice")
group.add_argument("--bob", action="store_true", help="Specify you are Bob")

opts = parser.parse_args()

if Path(PAYLOAD_FILENAME).exists():
    Path(PAYLOAD_FILENAME).unlink()
if opts.alice is True:
    SI = int(
        opts.salary
        if opts.salary is not None
        else getpass.getpass(
            f"You are Alice. What's your salary? (Input hidden, 0-{MAX}) "
        )
    )
    SJ = None
    assert 0 <= SI < MAX, f"Out of range. Must be between 0 and {MAX}"
else:
    SI = None
    SJ = int(
        opts.salary
        if opts.salary is not None
        else getpass.getpass(
            f"You are Bob. What's your salary? (Input hidden, 0-{MAX}) "
        )
    )
    assert 0 <= SJ < MAX, f"Out of range. Must be between 0 and {MAX}"

if opts.alice is True:
    if Path(KEY_FILENAME).exists():
        with open(KEY_FILENAME) as f:
            data = json.load(f)
            cached_N = data["N"]
            cached_e = data["e"]
            cached_d = data["d"]
            cached_n = data["n"]
    else:
        cached_N = None
        cached_e = None
        cached_d = None
        cached_n = None
    if cached_N == N and cached_N is not None:
        print(f"Read RSA keypair from {KEY_FILENAME}.")
        e = cached_e
        d = cached_d
        n = cached_n
    else:
        e, d, n = generate_key_pair(bits=N)
        if opts.nocache is False:
            with open(KEY_FILENAME, "w") as f:
                json.dump({"N": N, "e": e, "d": d, "n": n}, fp=f)
            print(f"We wrote this RSA keypair to {KEY_FILENAME} so it stays the same.")
    assert e is not None
    assert n is not None
    print("Send the following value of n to Bob:")
    print(n)
    print("-" * 40)
else:
    n = int(input("Enter the value of n that Alice provided:\n"))
    e = 65537
    d = None
    print("-" * 40)

if opts.bob is True:
    assert SJ is not None
    x = secrets.randbits(N)
    C = pow(x, e, n)
    m = (C - SJ) % n
    print("Send the following value of m to Bob:")
    print(m)
    print("-" * 40)
else:
    m = int(input("Enter the value of m that Bob sends:\n"))
    x = None
    print("-" * 40)

if opts.alice is True:
    assert SI is not None
    while True:
        print("Hi")
        assert d is not None
        p = generate_n_bit_prime(N)
        Y = [pow(m + i, d, n) for i in range(MAX)]
        Z = [y % p for y in Y]
        sortedZ = list(sorted(Z))
        if all(sortedZ[i] - sortedZ[i - 1] >= 3 for i in range(1, MAX)):
            break
    with open(PAYLOAD_FILENAME, "w") as f:
        W = tuple((Z[i] + int(i > SI) - int(i < SI)) % p for i in range(0, MAX))
        json.dump(
            {"m": m, "p": p, "stream": W},
            fp=f,
        )
    print(f"We wrote the file {PAYLOAD_FILENAME}.")
    print("Send that to Bob and Bob will tell you the result.")
else:
    print(f"Alice should send you a file called {PAYLOAD_FILENAME}")
    print("Put that file in the directory of this script.")
    while not Path(PAYLOAD_FILENAME).exists():
        input("File not found. Press enter once it's here...")
    with open(PAYLOAD_FILENAME) as f:
        data = json.load(f)
    assert data["m"] == m
    p = data["p"]
    assert miller_rabin_test(p)
    W = data["stream"]
    assert x is not None
    assert SJ is not None
    assert W[SJ] % p == x - 1 or W[SJ] % p == x or W[SJ] % p == x + 1, (W[SJ] % p, x)
    if W[SJ] % p == x - 1:
        print("🅰️ Alice has more money than Bob!")
    elif W[SJ] % p == x + 1:
        print("🅱️ Bob has more money than Alice!")
    else:
        print("😮 The two provided numbers are equal!")
