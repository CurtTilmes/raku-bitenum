CWD := $(shell pwd)
NAME := $(shell jq -r .name META6.json)
VERSION := $(shell jq -r .version META6.json)
ARCHIVENAME := $(subst ::,-,$(NAME))

check: README.md
	git diff-index --check HEAD
	prove6

README.md: lib/BitEnum.rakumod
	perl6 --doc=Markdown $< > $@

tag:
	git tag $(VERSION)
	git push origin --tags

dist:
	git archive --prefix=$(ARCHIVENAME)-$(VERSION)/ \
		-o ../$(ARCHIVENAME)-$(VERSION).tar.gz $(VERSION)

test:
	docker run --rm -t  \
	  -e RELEASE_TESTING=1 \
	  -v $(CWD):/test \
	  jjmerelo/raku-test
