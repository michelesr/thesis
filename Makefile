pdf: latex
	docker run --rm -v $$PWD:/code michelesr/latex /bin/bash scripts/compile_pdf.sh

latex:
	bash scripts/compile_tex.sh
