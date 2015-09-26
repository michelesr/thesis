# Michele Sorcinelli Thesis

This is the repository for my Thesis: *Development, Testing, and Continuous
Integration of Containerized Web Applications*.

This thesis can be easily compiled using [Pandoc](http://pandoc.org) and
[Docker](https://www.docker.com) in combination with the
[michelesr/latex](https://hub.docker.com/r/michelesr/latex/) image.

To compile the thesis using Docker and Pandoc:

    $ make

To compile the thesis using Docker and LaTeX:

    $ make latex
    $ cd template/
    $ pdflatex thesis.tex

A prebuilt version of the document is available
[here](https://michelesr.github.io/thesis/dist/thesis.pdf).

This thesis is licensed under a [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license.

© 2015 Michele Sorcinelli
