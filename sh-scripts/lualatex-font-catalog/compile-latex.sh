#!/usr/bin/env bash

python make-latex-document.py >samples.tex
latexmk
