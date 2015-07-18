#! /bin/sh

cd template

# in order to parse generated .toc .aux. .lof .lot
# pdflatex needs to be launched twice
pdflatex tesi.tex 
pdflatex tesi.tex

mv tesi.pdf ../dist/
