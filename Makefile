pdf: latex
	docker run --rm -v $$PWD:/code michelesr/latex /bin/bash scripts/compile_pdf.sh

clean:
	find . -regex '.*.\(pdf\|aux\|toc\|lo*\)' -exec rm -v {} \+
	rm -rvf dist/

latex:
	mkdir -p dist/
	bash scripts/compile_tex.sh
