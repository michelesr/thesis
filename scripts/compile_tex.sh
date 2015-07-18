#! /bin/bash
for x in src/*.md
do
  pandoc $x -t latex --chapters -o template/latex/$(echo $x | cut -d/ -f2 | cut -d. -f1).tex
done
