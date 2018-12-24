import re
import markdown
import sys


# taken from latex2wp
def process_latex(content):
	def separatemath(m) :
		mathre = re.compile(r"\$.*?\$"
						r"|\\begin\{equation}.*?\\end\{equation}"
						r"|\\\[.*?\\\]")
		math = mathre.findall(m)
		text = mathre.split(m)
		return (math,text)

	def processmath(M) :
		R = []
		mathdelim = re.compile(r"\$"
				r"|\\begin\{equation}"
				r"|\\end\{equation}"
				r"|\\\[|\\\]")
		for m in M:
			md = mathdelim.findall(m)
			mb = mathdelim.split(m)
			
			if md[0] == "$":
				m="$latex {"+mb[1]+"}" + "&fg=000000" + "$"
			else:
				m = r"<p align=center>$latex \displaystyle " + mb[1] \
						+ "&fg=000000" + "$" + "</p>\n"
			R= R + [m]
		return R

	math, text = separatemath(content)

	s = text[0]
	for i in range(len(math)) :
		s = s+"__math"+str(i)+"__"+text[i+1]
	math = processmath ( math )

	for i in range(len(math)) :
		s=s.replace("__math"+str(i)+"__",math[i])
	return s

with open(sys.argv[1]) as f:
	file_content = ''.join(f.readlines())
	latexed_content = process_latex(file_content)
	html_content = markdown.markdown(latexed_content)
	joined_content = html_content.replace("\n", "  ")
	print(joined_content)

