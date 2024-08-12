# https://zoo.cs.yale.edu/classes/cs461/2009/lectures/ln21.pdf

import argparse
import getpass
import random
from pathlib import Path

MAX = 1001
N = 192


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
        candidate = random.getrandbits(n)
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
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--alice", action="store_true", help="Specify you are Alice")
group.add_argument("--bob", action="store_true", help="Specify you are Bob")

opts = parser.parse_args()

if Path("payload.txt").exists():
    Path("payload.txt").unlink()
if opts.alice is True:
    SI = int(
        opts.salary
        if opts.salary is not None
        else getpass.getpass("You are Alice. What's your salary? (Input hidden) ")
    )
    SJ = None
    assert SI < MAX
else:
    SI = None
    SJ = int(
        opts.salary
        if opts.salary is not None
        else getpass.getpass("You are Bob. What's your salary? (Input hidden) ")
    )
    assert SJ < MAX

if opts.alice is True:
    e, d, n = generate_key_pair(bits=N)
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
    x = random.getrandbits(N)
    C = pow(x, e, n)
    m = (C - SJ) % n
    print("Send the following value of m to Bob:")
    print(m)
    print("-" * 40)
else:
    m = int(input("Enter the value of m that Bob sends:\n"))
    x = None
    print("-" * 40)

# Bob does dumb stuff
if opts.alice is True:
    assert SI is not None
    while True:
        print("Hi")
        assert d is not None
        p = generate_n_bit_prime(N)
        Y = [pow(m + i, d, n) for i in range(MAX)]
        Z = [y % p for y in Y]
        sortedZ = list(sorted(Z))
        print(sortedZ)
        if all(sortedZ[i] - sortedZ[i - 1] >= 2 for i in range(1, MAX)):
            break
    with open("payload.txt", "w") as f:
        print(m, file=f)
        print(p, file=f)
        for i in range(0, MAX):
            print((Z[i] + int(i > SI)) % p, file=f)
else:
    print("Alice should send you a file called payload.txt")
    print("Put that file in the directory of this script.")
    while not Path("payload.txt").exists():
        input("Press enter once ready...")
    with open("payload.txt") as f:
        assert int(f.readline()) == m
        p = int(f.readline())
        W = [int(line) for line in f]
        assert x is not None
        assert SJ is not None
        print(SJ)
        print(x)
        print(W)
        assert W[SJ] % p == x or W[SJ] % p == x + 1
        if W[SJ] % p == x:
            print("Alice has at least as much money as Bob")
        else:
            print("Bob has more money than Alice")
