import sys
from markdown import markdown as _m

def markdown(content):
	return _m(content,
		extensions=['extra', 'sane_lists', 'smarty'])

if __name__ == "__main__":
	print(markdown(''.join(sys.stdin.readlines())))
