"""
** ADAPTED FROM https://github.com/cryzed/bin **
Original author: Chris Braun
License: The MIT License (MIT)

Copyright (c) 2016 Chris Braun

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

#!/usr/bin/env python

import argparse
import collections
import getpass
import os
import re
import subprocess
import time
from pathlib import Path
from typing import List

import bs4
import requests

EXIT_FAILURE = 1
LOGIN_URL = 'https://aur.archlinux.org/login'
SEARCH_URL_TEMPLATE = 'https://aur.archlinux.org/packages/?O=%d&SB=w&SO=d&PP=250&do_Search=Go'
PACKAGES_URL = 'https://aur.archlinux.org/packages/'
VOTE_URL_TEMPLATE = 'https://aur.archlinux.org/pkgbase/%s/vote/'
UNVOTE_URL_TEMPLATE = 'https://aur.archlinux.org/pkgbase/%s/unvote/'
PACKAGES_PER_PAGE = 250

argument_parser = argparse.ArgumentParser()
argument_parser.add_argument('username')
argument_parser.add_argument(
    '--ignore',
    '-i',
    action='append',
    default=[],
    help=
    'Regex for packages that should not be voted. Can be passed multiple times.'
)
argument_parser.add_argument(
    '--unvote-all',
    '-u',
    action='store_true',
    help='Unvote all voted-for packages, all other arguments are ignored.')
argument_parser.add_argument('--no-unvote',
                             '-n',
                             action="store_true",
                             help="Don't unvote uninstalled packages.")
argument_parser.add_argument('--delay',
                             '-d',
                             type=float,
                             default=0,
                             help='Delay between voting actions (seconds).')

Package = collections.namedtuple(
    'Package', ('name', 'version', 'votes', 'popularity', 'voted', 'notify',
                'description', 'maintainer'))


def login(session, username, password):
    response = session.post(
        LOGIN_URL, {
            'user': username,
            'passwd': password,
            'next': '/'
        },
        headers={'referer': 'https://aur.archlinux.org/login'})
    soup = bs4.BeautifulSoup(response.text, 'html5lib')
    navbar = soup.select_one('#archdev-navbar')
    assert navbar is not None
    return bool(
        navbar.find(
            'form',
            action=lambda h: h and h.rstrip('/').endswith('/logout'
                                                         ),  # type: ignore
        ))


PATH_TO_VOTE = Path('~/Sync/pacman/').expanduser()


def get_used_aur_packages() -> set[str]:
    out: List[str] = []
    for fname in PATH_TO_VOTE.glob('*.vote.paclist'):
        with open(fname) as f:
            for line in f:
                out.append(line.strip())
    ret = set(out)

    normal_packages_lines = subprocess.check_output(
        ('paclist', 'core', 'community', 'extra'),
        universal_newlines=True,
    ).splitlines()
    for line in normal_packages_lines:
        pkgname = line.split(' ')[0]
        if pkgname in ret:
            ret.remove(pkgname)
    return ret


def get_voted_packages(session):
    offset = 0

    while True:
        response = session.get(SEARCH_URL_TEMPLATE % offset)
        soup = bs4.BeautifulSoup(response.text, 'html5lib')
        for row in soup.select('.results > tbody > tr'):
            package = Package(*(
                c.get_text(strip=True) for c in row.select(':scope > td')[1:]))
            if not package.voted:
                return

            yield package

        offset += PACKAGES_PER_PAGE


def vote_package(session, package):
    response = session.post(VOTE_URL_TEMPLATE % package,
                            {'do_Vote': 'Vote for this package'},
                            allow_redirects=True)
    return response.status_code == requests.codes.ok


def unvote_package(session, package):
    response = session.post(UNVOTE_URL_TEMPLATE % package,
                            {'do_UnVote': 'Remove vote'},
                            allow_redirects=True)
    return response.status_code == requests.codes.ok


# TODO: Handle split packages better
def main(arguments):
    password = (subprocess.run(
        ['secret-tool', 'lookup', 'user', 'vEnhance', 'type', 'aur'],
        text=True,
        capture_output=True,
    ).stdout or os.environ.get('AUR_AUTO_VOTE_PASSWORD') or
                getpass.getpass('Password: '))
    ignores = tuple(re.compile(r) for r in arguments.ignore)
    session = requests.Session()
    if not login(session, arguments.username, password):
        argument_parser.exit(EXIT_FAILURE, 'Could not login.\n')

    voted_packages = set(
        tuple(p.name for p in sorted(get_voted_packages(session))))

    # Unvote all packages and return immediately if --unvote-all was passed
    if arguments.unvote_all:
        for package in voted_packages:
            print('Unvoting package: %s... ' % package, end='', flush=True)
            if unvote_package(session, package):
                print('done.')
            else:
                print('failed.')
            time.sleep(arguments.delay)

        return

    good_packages = get_used_aur_packages()
    for package in sorted(good_packages.difference(voted_packages)):
        if any(i.match(package) for i in ignores):
            print('Not voting for ignored package:', package)
            continue

        print('Voting for package: %s... ' % package, end='', flush=True)
        if vote_package(session, package):
            print('done.')
        else:
            print('failed.')
        time.sleep(arguments.delay)

    # Unvote packages that are voted for in the AUR but not available on the system anymore, i.e. uninstalled since the
    # last voting
    if arguments.no_unvote:
        return

    for package in sorted(voted_packages.difference(good_packages)):
        if any(i.match(package) for i in ignores):
            print('Not unvoting ignored package:', package)
            continue

        print('Unvoting removed package: %s... ' % package, end='', flush=True)
        if unvote_package(session, package):
            print('done.')
        else:
            print('failed.')
        time.sleep(arguments.delay)


if __name__ == '__main__':
    arguments = argument_parser.parse_args()
    main(arguments)
