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


import re
from sys import argv

from latex2wpstyle import *

# prepare variables computed from the info in latex2wpstyle
count = dict()
for thm in ThmEnvs:
  count[T[thm]] = 0
count["section"] = count["subsection"] = count["equation"] = 0

ref={}

endlatex = "&fg="+textcolor
if HTML : endproof = "<img src=\"http://l.wordpress.com/latex.php?latex=\Box&fg=000000\">"


inthm = ""

"""
 At the beginning, the commands \$, \% and \& are temporarily
 replaced by placeholders (the second entry in each 4-tuple).
 At the end, The placeholders in text mode are replaced by
 the third entry, and the placeholders in math mode are
 replaced by the fourth entry.
"""

esc = [["\\$","_dollar_","&#36;","\\$"],
       ["\\%","_percent_","&#37;","\\%"],
       ["\\&","_amp_","&amp;","\\&"],
       [">","_greater_",">","&gt;"],
       ["<","_lesser_","<","&lt;"]]

M = M + [ ["\\more","<!--more-->"],
          ["\\newblock","\\\\"],
          ["\\sloppy",""],
          ["\\S","&sect;"]]

Mnomath =[["\\\\","<br/>\n"],
          ["\\ "," "],
          ["\\`a","&agrave;"],
          ["\\'a","&aacute;"],
          ["\\\"a","&auml;"],
          ["\\aa ","&aring;"],
          ["{\\aa}","&aring;"],
          ["\\`e","&egrave;"],
          ["\\'e","&eacute;"],
          ["\\\"e","&euml;"],
          ["\\`i","&igrave;"],
          ["\\'i","&iacute;"],
          ["\\\"i","&iuml;"],
          ["\\`o","&ograve;"],
          ["\\'o","&oacute;"],
          ["\\\"o","&ouml;"],
          ["\\`o","&ograve;"],
          ["\\'o","&oacute;"],
          ["\\\"o","&ouml;"],
          ["\\H o","&ouml;"],
          ["\\`u","&ugrave;"],
          ["\\'u","&uacute;"],
          ["\\\"u","&uuml;"],
          ["\\`u","&ugrave;"],
          ["\\'u","&uacute;"],
          ["\\\"u","&uuml;"],
          ["\\v{C}","&#268;"]]


cb = re.compile("\\{|}")

def extractbody(m) :

    begin = re.compile("\\\\begin\s*")
    m= begin.sub("\\\\begin",m)
    end = re.compile("\\\\end\s*")
    m = end.sub("\\\\end",m)
    
    beginenddoc = re.compile("\\\\begin\\{document}"
                          "|\\\\end\\{document}")
    parse = beginenddoc.split(m)
    if len(parse)== 1 :
       m = parse[0]
    else :
       m = parse[1]

    """
      removes comments, replaces double returns with <p> and
      other returns and multiple spaces by a single space.
    """

    for e in esc :
        m = m.replace(e[0],e[1])

    comments = re.compile("%.*?\n")
    m=comments.sub(" ",m)

        

    multiplereturns = re.compile("\n\n+")
    m= multiplereturns.sub ("<p>",m)
    spaces=re.compile("(\n|[ ])+")
    m=spaces.sub(" ",m)

    """
     removes text between \iffalse ... \fi and
     between \iftex ... \fi keeps text between
     \ifblog ... \fi
    """


    ifcommands = re.compile("\\\\iffalse|\\\\ifblog|\\\\iftex|\\\\fi")
    L=ifcommands.split(m)
    I=ifcommands.findall(m)
    m= L[0]
    for i in range(1,(len(L)+1)/2) :
        if (I[2*i-2]=="\\ifblog") :
            m=m+L[2*i-1]
        m=m+L[2*i]

    """
     changes $$ ... $$ into \[ ... \] and reformats
     eqnarray* environments as regular array environments
    """

    doubledollar = re.compile("\\$\\$")
    L=doubledollar.split(m)
    m=L[0]
    for i in range(1,(len(L)+1)/2) :
        m = m+ "\\[" + L[2*i-1] + "\\]" + L[2*i]

    m=m.replace("\\begin{eqnarray*}","\\[ \\begin{array}{rcl} ")
    m=m.replace("\\end{eqnarray*}","\\end{array} \\]")

    return m

def convertsqb(m):
    r = re.compile("\\\\item\\s*\\[.*?\\]")

    Litems = r.findall(m)
    Lrest = r.split(m)

    m = Lrest[0]
    for i in range(0,len(Litems)) :
      s= Litems[i]
      s=s.replace("\\item","\\nitem")
      s=s.replace("[","{")
      s=s.replace("]","}")
      m=m+s+Lrest[i+1]

    r = re.compile("\\\\begin\\s*\\{\\w+}\\s*\\[.*?\\]")
    Lthms = r.findall(m)
    Lrest = r.split(m)

    m = Lrest[0]
    for i in range(0,len(Lthms)) :
      s= Lthms[i]
      s=s.replace("\\begin","\\nbegin")
      s=s.replace("[","{")
      s=s.replace("]","}")
      m=m+s+Lrest[i+1]

    return m


def converttables(m) :
    retable = re.compile("\\\\begin\s*\\{tabular}.*?\\\\end\s*\\{tabular}"
                         "|\\\\begin\s*\\{btabular}.*?\\\\end\s*\\{btabular}")
    tables = retable.findall(m)
    rest = retable.split(m)
    m = rest[0]
    for i in range(len(tables)) :
        if tables[i].find("{btabular}") != -1 :
            m = m + convertonetable(tables[i],True)
        else :
            m = m + convertonetable(tables[i],False)
        m = m + rest[i+1]
    return m

# Evan Chen -- hack more
def convertaligns(m):
    realign = re.compile("\\\\begin\s*\\{align\\*?}.*?\\\\end\s*\\{align\\*?}")
    delims = re.compile("\\\\(begin|end)\s*\\{align\\*?}")
    aligns = realign.findall(m)
    rest = realign.split(m)
    m = rest[0]
    for i in range(len(aligns)) :
        math = delims.split(aligns[i])[2]
        m = m + r"\[ \begin{aligned}" + math + r"\end{aligned} \]"
        m = m + rest[i+1]
    return m


def convertmacros(m) :


    comm = re.compile("\\\\[a-zA-Z]*")
    commands = comm.findall(m)
    rest = comm.split(m)


    r= rest[0]
    for i in range( len (commands) ) :
      for s1,s2 in M :
        if s1==commands[i] :
          commands[i] = s2
      r=r+commands[i]+rest[i+1]
    return(r)


def convertonetable(m,border) :

    tokens = re.compile("\\\\begin\\{tabular}\s*\\{.*?}"
                        "|\\\\end\\{tabular}"
                        "|\\\\begin\\{btabular}\s*\\{.*?}"
                        "|\\\\end\\{btabular}"
                        "|&|\\\\\\\\")

    align = { "c" : "center", "l" : "left" , "r" : "right" }

    T = tokens.findall(m)
    C = tokens.split(m)


    L = cb.split(T[0])
    format = L[3]

    columns = len(format)
    if border :
        m = "<table border=\"1\" align=center>"
    else :
        m="<table align = center><tr>"
    p=1
    i=0

    
    while T[p-1] != "\\end{tabular}" and T[p-1] != "\\end{btabular}":
        m = m + "<td align="+align[format[i]]+">" + C[p] + "</td>"
        p=p+1
        i=i+1
        if T[p-1]=="\\\\" :
            for i in range (p,columns) :
                m=m+"<td></td>"
            m=m+"</tr><tr>"
            i=0
    m = m+ "</tr></table>"
    return (m)
 



            
        
    

def separatemath(m) :
    mathre = re.compile("\\$.*?\\$"
                   "|\\\\begin\\{equation}.*?\\\\end\\{equation}"
                   "|\\\\\\[.*?\\\\\\]")
    math = mathre.findall(m)
    text = mathre.split(m)
    return(math,text)


def processmath( M ) :
    R = []
    counteq=0
    global ref

    mathdelim = re.compile("\\$"
                           "|\\\\begin\\{equation}"
                           "|\\\\end\\{equation}"
                           "|\\\\\\[|\\\\\\]")
    label = re.compile("\\\\label\\{.*?}")
    
    for m in M :
        md = mathdelim.findall(m)
        mb = mathdelim.split(m)

        """
          In what follows, md[0] contains the initial delimiter,
          which is either \begin{equation}, or $, or \[, and
          mb[1] contains the actual mathematical equation
        """
        
        if md[0] == "$" :
            if HTML :
                m=m.replace("$","")
                m=m.replace("+","%2B") 
                m=m.replace(" ","+")
                m=m.replace("'","&#39;")
                m="<img src=\"http://l.wordpress.com/latex.php?latex=%7B"+m+"%7D"+endlatex+"\">"
            else :
                m="$latex {"+mb[1]+"}"+endlatex+"$"

        else :
            if md[0].find("\\begin") != -1 :
                count["equation"] += 1
                mb[1] = mb[1] + "\\ \\ \\ \\ \\ ("+str(count["equation"])+")"
            if HTML :
                mb[1]=mb[1].replace("+","%2B")
                mb[1]=mb[1].replace("&","%26")
                mb[1]=mb[1].replace(" ","+")
                mb[1]=mb[1].replace("'","&#39;")
                m = "<p align=center><img src=\"http://l.wordpress.com/latex.php?latex=\displaystyle " + mb[1] +endlatex+"\"></p>\n"
            else :
                m = "<p align=center>$latex \displaystyle " + mb[1] +endlatex+"$</p>\n"
            if m.find("\\label") != -1 :
                mnolab = label.split(m)
                mlab = label.findall(m)
                """
                 Now the mathematical equation, which has already
                 been formatted for WordPress, is the union of
                 the strings mnolab[0] and mnolab[1]. The content
                 of the \label{...} command is in mlab[0]
                """
                lab = mlab[0]
                lab=cb.split(lab)[1]
                lab=lab.replace(":","")
                ref[lab]=count["equation"]

                m="<a name=\""+lab+"\">"+mnolab[0]+mnolab[1]+"</a>"

        R= R + [m]
    return R


def convertcolors(m,c) :
    if m.find("begin") != -1 :
        return("<span style=\"color:#"+colors[c]+";\">")
    else :
        return("</span>")


def convertitm(m) :
    if m.find("begin") != -1 :
        return ("\n\n<ul>")
    else :
        return ("\n</ul>\n\n")

def convertenum(m) :
    if m.find("begin") != -1 :
        return ("\n\n<ol>")
    else :
        return ("\n</ol>\n\n")


def convertbeginnamedthm(thname,thm) :
  global inthm

  count[T[thm]] +=1
  inthm = thm
  t = beginnamedthm.replace("_ThmType_",thm.capitalize())
  t = t.replace("_ThmNumb_",str(count[T[thm]]))
  t = t.replace("_ThmName_",thname)
  return(t)


# Evan Chen -- more hacks
def convertbeginthm(thm, nonumber=False) :
  global inthm
  inthm = thm
  t = beginthm.replace("_ThmType_",thm.capitalize())

  if nonumber:
    t = t.replace(" _ThmNumb_", "")
  else:
    count[T[thm]] +=1
    t = t.replace("_ThmNumb_",str(count[T[thm]]))
  return t
 
def convertendthm(thm, nonumber=False) :
  global inthm

  inthm = ""
  return(endthm)


def convertlab(m) :
    global inthm
    global ref

    
    m=cb.split(m)[1]
    m=m.replace(":","")
    if inthm != "" :
        ref[m]=count[T[inthm]]
    else :
        ref[m]=count["section"]
    return("<a name=\""+m+"\"></a>")
        


def convertproof(m) :
    if m.find("begin") != -1 :
        return(beginproof)
    else :
        return(endproof)
    

def convertsection (m) :

 
      L=cb.split(m)

      """
        L[0] contains the \\section or \\section* command, and
        L[1] contains the section name
      """

      if L[0].find("*") == -1 :
          t=section
          count["section"] += 1
          count["subsection"]=0

      else :
          t=sectionstar

      t=t.replace("_SecNumb_",str(count["section"]) )
      t=t.replace("_SecName_",L[1])
      return(t)

def convertsubsection (m) :

      
        L=cb.split(m)

        if L[0].find("*") == -1 :
            t=subsection
        else :
            t=subsectionstar
        
        count["subsection"] += 1
        t=t.replace("_SecNumb_",str(count["section"]) )
        t=t.replace("_SubSecNumb_",str(count["subsection"]) )
        t=t.replace("_SecName_",L[1])     
        return(t)


def converturl (m) :
    L = cb.split(m)
    return ("<a href=\""+L[1]+"\">"+L[3]+"</a>")

def converturlnosnap (m) :
    L = cb.split(m)
    return ("<a class=\"snap_noshots\" href=\""+L[1]+"\">"+L[3]+"</a>")


def convertimage (m) :
    L = cb.split (m)
    return ("<p align=center><img "+L[1] + " src=\""+L[3]
         +"\"></p>")

def convertstrike (m) :
    L=cb.split(m)
    return("<s>"+L[1]+"</s>")

def processtext ( t ) :
        # Evan Chen -- allow stars in env names
        p = re.compile("\\\\begin\\{[\\w*]+}"
                   "|\\\\nbegin\\{\\w+}\\s*\\{.*?}"
                   "|\\\\end\\{[\\w*]+}"
                   "|\\\\item"
                   "|\\\\nitem\\s*\\{.*?}"
                   "|\\\\label\\s*\\{.*?}"
                   "|\\\\section\\s*\\{.*?}"
                   "|\\\\section\\*\\s*\\{.*?}"
                   "|\\\\subsection\\s*\\{.*?}"
                   "|\\\\subsection\\*\\s*\\{.*?}"
                   "|\\\\href\\s*\\{.*?}\\s*\\{.*?}"
                   "|\\\\hrefnosnap\\s*\\{.*?}\\s*\\{.*?}"
                   "|\\\\image\\s*\\{.*?}\\s*\\{.*?}\\s*\\{.*?}"
                   "|\\\\sout\\s*\\{.*?}")


 
        
        for s1, s2 in Mnomath :
            t=t.replace(s1,s2)

        
        ttext = p.split(t)
        tcontrol = p.findall(t)

 
        w = ttext[0]

 
        i=0
        while i < len(tcontrol) :
            if tcontrol[i].find("{itemize}") != -1 :
                w=w+convertitm(tcontrol[i])
            elif tcontrol[i].find("{enumerate}") != -1 :
                w= w+convertenum(tcontrol[i])
            elif tcontrol[i][0:5]=="\\item" :
                w=w+"<li>"
            elif tcontrol[i][0:6]=="\\nitem" :
                    lb = tcontrol[i][7:].replace("{","")
                    lb = lb.replace("}","")
                    w=w+"<li>"+lb
            elif tcontrol[i].find("\\hrefnosnap") != -1 :
                w = w+converturlnosnap(tcontrol[i])
            elif tcontrol[i].find("\\href") != -1 :
                w = w+converturl(tcontrol[i])
            elif tcontrol[i].find("{proof}") != -1 :
                w = w+convertproof(tcontrol[i])
            elif tcontrol[i].find("\\subsection") != -1 :
                w = w+convertsubsection(tcontrol[i])
            elif tcontrol[i].find("\\section") != -1 :
                w = w+convertsection(tcontrol[i])
            elif tcontrol[i].find("\\label") != -1 :
                w=w+convertlab(tcontrol[i])
            elif tcontrol[i].find("\\image") != -1 :
                w = w+convertimage(tcontrol[i])
            elif tcontrol[i].find("\\sout") != -1 :
                w = w+convertstrike(tcontrol[i])
            elif tcontrol[i].find("\\begin") !=-1 and tcontrol[i].find("{center}")!= -1 :
                w = w+"<p align=center>"
            elif tcontrol[i].find("\\end")!= -1  and tcontrol[i].find("{center}") != -1 :
                w = w+"</p>"
            else :
              for clr in colorchoice :
                if tcontrol[i].find("{"+clr+"}") != -1:
                    w=w + convertcolors(tcontrol[i],clr)
              for thm in ThmEnvs :
                if tcontrol[i]=="\\end{"+thm+"}" :
                    w=w+convertendthm(thm)
                elif tcontrol[i]=="\\begin{"+thm+"}":
                    w=w+convertbeginthm(thm)
                elif tcontrol[i].find("\\nbegin{"+thm+"}") != -1:
                    L=cb.split(tcontrol[i])
                    thname=L[3]
                    w=w+convertbeginnamedthm(thname,thm)
                # Evan Chen -- hack to allow starred theorems
                elif tcontrol[i]=="\\end{"+thm+"*}" :
                    w=w+convertendthm(thm, nonumber=True)
                elif tcontrol[i]=="\\begin{"+thm+"*}":
                    w=w+convertbeginthm(thm, nonumber=True)
            w += ttext[i+1]
            i += 1

        return processfontstyle(w)

def processfontstyle(w) :

        close = dict()
        ww = ""
        level = i = 0
        while i < len(w):
          special = False
          for k, v in fontstyle.items():
            l = len(k)
            if w[i:i+l] == k:
              level += 1
              ww += '<' + v + '>'
              close[level] = '</' + v + '>'
              i += l
              special = True
          if not special:
            if w[i] == '{':
              ww += '{'
              level += 1
              close[level] = '}'
            elif w[i] == '}' and level > 0:
              ww += close[level]
              level -= 1
            else:
              ww += w[i]
            i += 1
        return ww
    

def convertref(m) :
    global ref
    
    p=re.compile("\\\\ref\s*\\{.*?}|\\\\eqref\s*\\{.*?}")

    T=p.split(m)
    M=p.findall(m)

    w = T[0]
    for i in range(len(M)) :
        t=M[i]
        lab=cb.split(t)[1]
        lab=lab.replace(":","")
        if t.find("\\eqref") != -1 :
           w=w+"<a href=\"#"+lab+"\">("+str(ref[lab])+")</a>"
        else :
           w=w+"<a href=\"#"+lab+"\">"+str(ref[lab])+"</a>"
        w=w+T[i+1]
    return w

"""
The program makes several passes through the input.

In a first clean-up, all text before \begin{document}
and after \end{document}, if present, is removed,
all double-returns are converted
to <p>, and all remaining returns are converted to
spaces.

The second step implements a few simple macros. The user can
add support for more macros if desired by editing the
convertmacros() procedure.

Then the program separates the mathematical
from the text parts. (It assumes that the document does
not start with a mathematical expression.) 

It makes one pass through the text part, translating
environments such as theorem, lemma, proof, enumerate, itemize,
\em, and \bf. Along the way, it keeps counters for the current
section and subsection and for the current numbered theorem-like
environment, as well as a  flag that tells whether one is
inside a theorem-like environment or not. Every time a \label{xx}
command is encountered, we give ref[xx] the value of the section
in which the command appears, or the number of the theorem-like
environment in which it appears (if applicable). Each appearence
of \label is replace by an html "name" tag, so that later we can
replace \ref commands by clickable html links.

The next step is to make a pass through the mathematical environments.
Displayed equations are numbered and centered, and when a \label{xx}
command is encountered we give ref[xx] the number of the current
equation. 

A final pass replaces \ref{xx} commands by the number in ref[xx],
and a clickable link to the referenced location.
"""


inputfile = "wpress.tex"
outputfile = "wpress.html"
if len(argv) > 1 :
    inputfile = argv[1]
    if len(argv) > 2 :
        outputfile = argv[2]
    else :
        outputfile = inputfile.replace(".tex",".html")
f=open(inputfile)
s=f.read()
f.close()


"""
  extractbody() takes the text between a \begin{document}
  and \end{document}, if present, (otherwise it keeps the
  whole document), normalizes the spacing, and removes comments
"""
s=extractbody(s)

# formats tables
s=converttables(s)

# convert aligns
s=convertaligns(s)

# reformats optional parameters passed in square brackets
s=convertsqb(s)


#implement simple macros
s=convertmacros(s)


# extracts the math parts, and replaces the with placeholders
# processes math and text separately, then puts the processed
# math equations in place of the placeholders

(math,text) = separatemath(s) 


s=text[0]
for i in range(len(math)) :
    s=s+"__math"+str(i)+"__"+text[i+1]
    
s = processtext ( s )
math = processmath ( math )

# converts escape sequences such as \$ to HTML codes
# This must be done after formatting the tables or the '&' in
# the HTML codes will create problems

for e in esc :
    s=s.replace(e[1],e[2])
    for i in range ( len ( math ) ) :
        math[i] = math[i].replace(e[1],e[3])

# puts the math equations back into the text


for i in range(len(math)) :
    s=s.replace("__math"+str(i)+"__",math[i])

# translating the \ref{} commands
s=convertref(s)



if HTML :
    s="<head><style>body{max-width:55em;}a:link{color:#4444aa;}a:visited{color:#4444aa;}a:hover{background-color:#aaaaFF;}</style></head><body>"+s+"</body></html>"

s = s.replace("<p>","\n<p>\n")


f=open(outputfile,"w")
f.write(s)
f.close()
