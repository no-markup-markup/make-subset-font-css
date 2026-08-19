SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -O globstar -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.PHONY: clean test install

bin/make-subset-font-css: src/make-subset-font-css.sh
	mkdir -p bin
	cp src/make-subset-font-css.sh bin/make-subset-font-css
	chmod +x bin/make-subset-font-css

test: bin/make-subset-font-css
	cd tests
	bash test.sh
	cd -

clean:
	git clean -fdX

README.md: bin/make-subset-font-css
	echo '# make-subset-font-css' > README.md
	echo '```' >> README.md
	bin/make-subset-font-css --help >> README.md
	echo '```' >> README.md

install: test
	mkdir -p ~/bin
	cp bin/make-subset-font-css ~/bin/

