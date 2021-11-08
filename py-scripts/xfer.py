import argparse
import getpass
import random
import sys
from hashlib import sha512
from pathlib import Path
from subprocess import call


def h(text: str) -> str:
	return sha512(text.encode('UTF-8')).hexdigest()


parser = argparse.ArgumentParser(
	prog='xfer', description='Temporarily upload a file to evanchen.cc/xfer'
)

parser.add_argument('filename', nargs='?', help='Path of file to upload')
parser.add_argument('-n', '--name', help='Name of the file to upload.')
parser.add_argument('-s', '--salt', nargs='?', const=str(random.random()), default='')
group = parser.add_mutually_exclusive_group()
group.add_argument('-p', '--password', help='Path to a password file, else getpass used.')
group.add_argument('-i', '--insecure', help='Specify the password via command line (insecure)')
group.add_argument('-e', '--echo', action='store_true', help="Don't hide with getpass.")
parser.add_argument(
	'-d', '--dry-run', action='store_true', help='Dry run, do not actually upload file.'
)
parser.add_argument('-w', '--wipe', action='store_true', help='Erase all files.')
args = parser.parse_args()

if __name__ == "__main__":
	if args.filename is not None:
		if args.password:
			password = Path(args.password).read_text().strip()
		elif args.insecure:
			password = args.insecure
		elif args.echo:
			password = input('Password: ').strip()
		else:
			while True:
				password = getpass.getpass().strip()
				password_confirm = getpass.getpass(prompt='Repeat: ').strip()
				if password == password_confirm:
					break
				else:
					print("Passwords did not match. Try again.")
		filename = args.name or args.filename
		salt = args.salt
		kludge = 'evanchen.cc/xfer|' + filename + '|' + args.salt + '|' + password
		h1 = h(kludge)
		h2 = h(h1)
		checksum = h2[0:6]
		if not args.dry_run:
			url = f"gs://web.evanchen.cc/xfer-payload/{h1}"
			call(
				f'gsutil cp "{args.filename}" {url} > /dev/null',
				shell=True,
			)
			call(
				f"gsutil -m setmeta -h 'Cache-Control:private, max-age=0, no-transform' {url}",
				shell=True,
			)
		print(f'https://web.evanchen.cc/xfer.html?f={filename}&h={checksum}&s{salt}')
	elif args.wipe:
		if 'y' in input("Are you sure? ").lower():
			call(
				"gsutil -m rm gs://web.evanchen.cc/xfer-payload/*",
				shell=True,
			)
	else:
		print("Need to specify a file to upload (or use --wipe to erase all).")
		sys.exit(1)
