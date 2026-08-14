#!/usr/bin/env bash

/usr/bin/python3 make-latex-document.py >samples.tex
latexmk
