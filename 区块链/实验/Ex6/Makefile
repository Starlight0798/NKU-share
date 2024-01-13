clean: clean-npm clean-doc
	echo "Done"

clean-npm:
	rm -rf node_modules

clean-doc:
	cd doc && latexmk -C; cd -

bundle: clean
	rm -f project.zip && zip -r project.zip package.json src test circuits artifacts doc Makefile
