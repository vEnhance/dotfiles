#!/bin/bash

python make-latex-document.py >samples.tex
latexmk
