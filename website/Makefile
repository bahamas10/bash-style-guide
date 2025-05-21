# Create, manage, and deploy the YSAP website
#
# Author: Dave Eddy <dave@daveeddy.com>
# Date: April 05, 2025
# License: MIT

# duh
SHELL := bash

.PHONY: help
help:
	@echo 'make build         default target, builds the site into ./_site'
	@echo 'make check-deps    check to ensure needed dependencies are installed'
	@echo 'make check         check tools syntax using shellcheck'
	@echo 'make serve         serve site locally out of ./_site'
	@echo 'make deploy        deploy the site (using rsync)'
	@echo 'make all           build and deploy the site'
	@echo 'make clean         remove any generated files'

.PHONY: build
build: header.txt
	mkdir -p _site _site/static _site/plain _site/md
	# disable indexing for certain dirs
	echo -n > _site/static/index.html
	# copy static files
	cat static/robots.txt > _site/robots.txt
	cat static/style.css > _site/static/style.css
	cat static/ansi.css > _site/static/ansi.css
	# render all available formats
	./make-index-ansi > _site/index.txt
	./make-index-html > _site/index.html
	./make-plain-ansi > _site/plain/index.txt
	./make-plain-html > _site/plain/index.html
	cat ../README.md > _site/md/index.html


header.txt:
	curl ysap.sh | head -8 > $@

.PHONY: all
all: build deploy

.PHONY: serve
serve:
	python3 -mhttp.server -d _site

.PHONY: check-deps
check-deps:
	./check-deps

.PHONY: check
check:
	shellcheck -x check-* tools/*

.PHONY: clean
clean:
	rm -rf _site header.txt

.PHONY: deploy
deploy:
	rsync -avh --delete ./_site/ web:/var/www/style.ysap.sh/
