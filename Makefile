pdf: latex
	docker run --rm -v $$PWD:/code michelesr/latex /bin/bash scripts/compile_pdf.sh

latex:
	mkdir -p dist/
	bash scripts/compile_tex.sh
