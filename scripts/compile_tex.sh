#! /bin/bash
for x in src/*.rst
do
  pandoc $x -t latex --chapters -o template/latex/$(echo $x | cut -d/ -f2 | cut -d. -f1).tex
done
