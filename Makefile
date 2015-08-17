pdf: latex
	bash scripts/run_latex_container.sh

clean:
	find . -regex '.*.\(pdf\|aux\|toc\|lo*\)' -exec rm -v {} \+
	rm -rvf dist/

clean-container:
	docker rm -f thesis

clean-all: clean clean-container

latex:
	mkdir -p dist/
	bash scripts/compile_tex.sh
