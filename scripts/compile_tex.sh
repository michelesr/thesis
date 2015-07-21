#! /bin/bash
for x in src/*.md
do
  pandoc $x -t latex --biblatex --chapters -o template/latex/$(echo $x | cut -d/ -f2 | cut -d. -f1).tex
done
find template/latex -type f -exec sed -i 's/textcite/cite/g' {} \;
