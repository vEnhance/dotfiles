"""
 Copyright 2009 Luca Trevisan

 Additional contributors: Radu Grigore

 LaTeX2WP version 0.6.2

 This file is part of LaTeX2WP, a program that converts
 a LaTeX document into a format that is ready to be
 copied and pasted into WordPress.

 You are free to redistribute and/or modify LaTeX2WP under the
 terms of the GNU General Public License (GPL), version 3
 or (at your option) any later version.

 I hope you will find LaTeX2WP useful, but be advised that
 it comes WITHOUT ANY WARRANTY; without even the implied warranty
 of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GPL for more details.

 You should have received a copy of the GNU General Public
 License along with LaTeX2WP.  If you can't find it,
 see <http://www.gnu.org/licenses/>.
"""

# Lines starting with #, like this one, are comments

# change to HTML = True to produce standard HTML
HTML = False

# color of LaTeX formulas
textcolor = "000000"

# colors that can be used in the text
colors = { "red" : "ff0000" , "green" : "00ff00" , "blue" : "0000ff" }
# list of colors defined above
colorchoice = ["red","green","blue"]


# counters for theorem-like environments
# assign any counter to any environment. Make sure that
# maxcounter is an upper bound to the any counter being used

T = { "theorem" : 0 , "lemma" : 0 , "proposition" : 0, "definition" : 0,
               "corollary" : 0, "remark" : 0 , "example" : 0, "claim" : 0,
			   "exercise" : 0, 
			   "axiom" : 1, "problem" : 2, "ques" : 0, # Napkin
			   "sproblem" : 2, "dproblem" : 2
			   }

# list of theorem-like environments
ThmEnvs = T.keys()

# the way \begin{theorem}, \begin{lemma} etc are translated in HTML
# the string _ThmType_ stands for the type of theorem
# the string _ThmNumb_ is the theorem number

box_string =  "<div style=\"color: #000000 !important; border: 1px red solid;" + \
		"padding-left: 8px; padding-top: 4px; margin-bottom: 8px !important; \">"
head_string = "<p style=\"margin-bottom: 6px\"><b style=\"color: #ff4d4d !important;\">"

beginthm = "\n" + box_string + head_string + "_ThmType_ _ThmNumb_" + "</b></p>"

# translation of \begin{theorem}[...]. The string
# _ThmName_ stands for the content betwee the
# square brackets

beginnamedthm = "\n" + box_string + head_string + "_ThmType_ _ThmNumb_" + "</b>" + " <b>(_ThmName_)</b>" + "</p>"

#translation of \end{theorem}, \end{lemma}, etc.
endthm = "<p style=\"margin-bottom:-12px;\"></p></div>\n"


beginproof = "<em>Proof:</em> "
endproof = "$latex \Box&fg=000000$\n"

section = "\n<h2>_SecNumb_. _SecName_ </h2>\n"
sectionstar = "\n<h2>_SecName_</h2>\n"
subsection = "\n<h3>_SecNumb_._SubSecNumb_. _SecName_ </h3>\n"
subsectionstar = "\n<h3> _SecName_ </h3>\n"

# Font styles. Feel free to add others. The key *must* contain
# an open curly bracket. The value is the namem of a HTML tag.
fontstyle = {
  r'{\em ' : 'em',
  r'{\bf ' : 'b',
  r'{\it ' : 'i',
  r'{\sl ' : 'i',
  r'\textit{' : 'i',
  r'\textsl{' : 'i',
  r'\emph{' : 'em',
  r'\textbf{' : 'b',
  r'\vocab{' : 'b',
}

# Macro definitions
# It is a sequence of pairs [string1,string2], and
# latex2wp will replace each occurrence of string1 with an
# occurrence of string2. The substitutions are performed
# in the same order as the pairs appear below.
# Feel free to add your own.
# Note that you have to write \\ instead of \
# and \" instead of "

M = [    
          [r"\ii",       r"\item"] ,
          [r"\to",       r"\rightarrow"] ,
          [r"\NN",       r"{\mathbb N}"],
          [r"\ZZ",       r"{\mathbb Z}"],
          [r"\CC",       r"{\mathbb C}"],
          [r"\RR",       r"{\mathbb R}"],
          [r"\QQ",       r"{\mathbb Q}"],
          [r"\FF",       r"{\mathbb F}"],
          [r"\OO",       r"{\mathcal O}"],
          [r"\pp",       r"{\mathfrak p}"],
          [r"\qq",       r"{\mathfrak q}"],
          [r"\Norm",     r"\text{N}"],
          [r"\End",      r"\text{End}"],
          [r"\xor",      r"\oplus"],
          [r"\eps",      r"\epsilon"],
          [r"\dg",       r"^{\circ}"],
          [r"\ol",       r"\overline"],
          [r"\inv",      r"^{-1}"],
          [r"\half",     r"\frac{1}{2}"],
          [r"\defeq",    r"\overset{\text{def}}{=}"],
          [r"\id",       r"\mathrm{id}"],
          [r"\qedhere",  r""], # sigh
          [r"\injto",    r"\hookrightarrow"],
		  [r"\img",      r"\text{Im }"]  # :(
    ]
