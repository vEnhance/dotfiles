import argparse
import getpass
from hashlib import sha512
from pathlib import Path
from subprocess import call


def h(text: str) -> str:
	return sha512(text.encode('UTF-8')).hexdigest()

parser = argparse.ArgumentParser(prog = 'xfer',
		description = 'Temporarily upload a file to evanchen.cc/xfer')
parser.add_argument('filename',
		help = 'Path of file to upload')
parser.add_argument('-n', '--name',
		help = 'Name of the file to upload.')
parser.add_argument('-p', '--password',
		help = 'Path to a password file, otherwise read from getpass.')
parser.add_argument('-i', '--insecure',
		help = 'Specify the password via command line (insecure)')
parser.add_argument('-e', '--echo', action = 'store_true',
		help = "Don't hide the password with getpass.")
parser.add_argument('-d', '--dry-run', action='store_true',
		help = 'Dry run, do not actually upload file.')
args = parser.parse_args()

if __name__ == "__main__":
	if args.password:
		password = Path(args.password).read_text().strip()
	elif args.insecure:
		password = args.insecure
	elif args.echo:
		password = input('Password: ').strip()
	else:
		password = getpass.getpass().strip()
		password_confirm = getpass.getpass(prompt = 'Repeat: ').strip()
		assert password == password_confirm, "nope, try again noob"
	filename = args.name or args.filename
	kludge = 'evanchen.cc/xfer|' + filename + '|' + password
	h1 = h(kludge)
	h2 = h(h1)
	checksum = h2[0:6]
	if not args.dry_run:
		call(f'gsutil cp "{args.filename}" '
				f'gs://web.evanchen.cc/xfer-payload/{h1} '
				f'> /dev/null',
				shell=True)
	print(f'https://web.evanchen.cc/xfer.html?f={filename}&h={checksum}')
