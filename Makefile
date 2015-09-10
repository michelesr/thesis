
pdf: latex
	bash scripts/run_latex_container.sh

clean:
	find . -regex '.*.\(aux\|toc\|lot\|lof\|log\)' -exec rm -v {} \+
	find . -name *converted* -exec rm -v {} \+
	rm -rvf dist/ template/chapters/

clean-container:
	docker rm -f thesis

clean-all: clean clean-container

latex:
	mkdir -p dist/
	bash scripts/compile_tex.sh

IMG=src/images

dot: 
	dot -Tpdf $(IMG)/dot/gf-components.dot -o $(IMG)/pdf/gf-components.pdf
	dot -Tpdf $(IMG)/dot/gf-containers.dot -o $(IMG)/pdf/gf-containers.pdf
	dot -Tpdf $(IMG)/dot/protractor-selenium.dot -o $(IMG)/pdf/protractor-selenium.pdf
	dot -Tpdf $(IMG)/dot/test-containers.dot -o $(IMG)/pdf/test-containers.pdf
