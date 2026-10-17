.PHONY: help
help:
	@echo 'make check     style check files'

.PHONY: check
check:
	./tools/style-check README.md
