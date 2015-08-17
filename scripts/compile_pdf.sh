#! /bin/sh

cd template

# in order to parse generated .toc .aux. .lof .lot
# pdflatex needs to be launched twice
pdflatex thesis.tex
pdflatex thesis.tex

mv thesis.pdf ../dist/
