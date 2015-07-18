pdf: latex
	docker run --rm -v $$PWD:/code michelesr/latex /bin/bash scripts/compile.sh

latex:
	pandoc src/protractor.rst -t latex --chapters -o template/latex/protractor.tex
