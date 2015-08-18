
pdf: latex
	bash scripts/run_latex_container.sh

clean:
	find . -regex '.*.\(pdf\|aux\|toc\|lot\|lof\|log\)' -exec rm -v {} \+
	rm -rvf dist/

clean-container:
	docker rm -f thesis

clean-all: clean clean-container

latex:
	mkdir -p dist/
	bash scripts/compile_tex.sh

IMG='src/images'

dot: 
	dot -Teps $(IMG)/dot/gf-components.dot -o $(IMG)/gf-components.eps
	dot -Teps $(IMG)/dot/gf-containers.dot -o $(IMG)/gf-containers.eps
	dot -Teps $(IMG)/dot/protractor-selenium.dot -o $(IMG)/protractor-selenium.eps
