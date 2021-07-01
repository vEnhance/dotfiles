import argparse
import getpass
from hashlib import sha512
from subprocess import call

def h(text: str) -> str:
	return sha512(text.encode('UTF-8')).hexdigest()

parser = argparse.ArgumentParser(prog = 'xfer',
		description = 'Temporarily upload a file to evanchen.cc/xfer')
parser.add_argument('filename',
		help = 'Path of file to upload')
parser.add_argument('-n', '--name',
		help = 'Name of the file to upload.')
args = parser.parse_args()

if __name__ == "__main__":
	password = getpass.getpass().strip()
	filename = args.name or args.filename
	kludge = 'evanchen.cc/xfer|' + filename + '|' + password
	h1 = h(kludge)
	h2 = h(h1)
	checksum = h2[0:6]
	call(f'gsutil cp {args.filename} '
			f'gs://web.evanchen.cc/xfer-payload/{h1} '
			f'> /dev/null',
			shell=True)
	print(f'https://web.evanchen.cc/xfer.html?f={filename}&h={checksum}')

