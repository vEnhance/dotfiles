import sys
from markdown import markdown as _m

PREAMBLE = r"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">

<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Mate">
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Verdana">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"></script>

<link rel="apple-touch-icon" sizes="180x180" href="https://web.evanchen.cc/icons/apple-touch-icon.png">
<link rel="icon" type="image/png" href="https://web.evanchen.cc/icons/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="https://web.evanchen.cc/icons/favicon-16x16.png" sizes="16x16">
<link rel="manifest" href="https://web.evanchen.cc/icons/manifest.json">
<link rel="mask-icon" href="https://web.evanchen.cc/icons/safari-pinned-tab.svg" color="#5bbad5">
<link rel="shortcut icon" href="https://web.evanchen.cc/icons/favicon.ico">

<meta name="msapplication-config" content="https://web.evanchen.cc/icons/browserconfig.xml">
<meta name="theme-color" content="#ffffff">
<link type="text/css" rel="stylesheet" href="https://web.evanchen.cc/css/simple-53544.css">

<script type="text/javascript">
MathJax = {
    tex: {
        inlineMath: [['$','$'], ['\\(','\\)']],
        displayMath: [['\\[', '\\]']],
    }
};
</script>
<script type="text/javascript" id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
</script>
</head>

<body>
<div id="container">
<div id="content">"""


def markdown(content):
	return _m(content,
		extensions=['extra', 'sane_lists', 'smarty'])

if __name__ == "__main__":
	if len(sys.argv) > 1:
		with open(sys.argv[1]) as f:
			content = ''.join(f.readlines())
	else:
		content = ''.join(sys.stdin.readlines())
	print(PREAMBLE)
	print(markdown(content))
	print('</div></div>')
	print(r'</body></html>')
