# TODO: bibliography file
# pandoc --filter pandoc-citeproc $< --biblio BIBLIOFILE
PANDOC:=pandoc --standalone
PANDOC_TEX=--include-in-header header.sty --variable=geometry:margin=1in

SOURCES:=README.md system.md
AUXIL:=$(wildcard *.sty) Makefile
OUTPUTS=$(SOURCES:.md=.pdf) $(SOURCES:.md=.tex) $(SOURCES:.md=.html)

.PHONY: all watch
all: system.pdf
watch: all
	@while inotifywait -e modify $(SOURCES) $(AUXIL); do make all; done

%.pdf: %.md $(AUXIL)
	$(PANDOC) $(PANDOC_TEX) $< -o $@

%.tex: %.md $(AUXIL)
	$(PANDOC) $(PANDOC_TEX) $< -o $@

%.html: %.md
	$(PANDOC) $< -o $@

clean:
	rm -f $(OUTPUTS)