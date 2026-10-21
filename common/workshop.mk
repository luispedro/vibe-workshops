# Shared build rules for every workshop in this repo.
#
# Each workshop directory has a three-line Makefile that sets SRC, STEM and
# WORKSHOP and then includes this file:
#
#   SRC      := agents-for-science.md
#   STEM     := workshop2__agents-for-science
#   WORKSHOP := 2
#   include ../common/workshop.mk
#
# One source file, three audiences:
#
#   $(SRC)  --+--> build/$(STEM)__slides.html      (reveal.js)
#             +--> build/$(STEM)__student.{pdf,html}
#             +--> build/$(STEM)__instructor.{pdf,html}
#
# The HTML handouts carry a copy button on every "type this" box, and are what
# `make site` publishes to GitHub Pages (see ../common/site.sh).
#
# Which material lands where is decided by Div/Span classes in the source
# (.instructor / .handout / .slides); see ../common/filters/*.lua.

ifndef SRC
$(error SRC is not set: include this from a workshop Makefile that sets SRC, STEM and WORKSHOP)
endif

BUILD    := build
# Where this file lives, so the workshop Makefiles do not repeat the path.
COMMON   := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
FILTERS  := $(COMMON)/filters
STYLE    := $(COMMON)/style

# cues.lua renders the content-type markers (things to type / to remember);
# it runs after the audience filter so cues inside dropped material never
# reach the output. See common/filters/cues.lua.
CUES_DEPS     := $(FILTERS)/cues.lua
CUES_TEX      := $(STYLE)/cues.tex

# Diagrams: a ```dot code block is drawn by Graphviz at build time (SVG in the
# deck, PDF in the handouts). diagram.lua runs after the audience filter and
# before cues.lua. See common/filters/diagram.lua.
DIAGRAM       := --lua-filter=$(FILTERS)/diagram.lua

# Figures: each media/NAME.py is a script that writes the figure to the path
# it is given, so $(BUILD)/media/NAME.{svg,pdf,png} are regenerated whenever
# the script changes. The source refers to it with no extension,
# ![](media/NAME), and each target picks its format with
# --default-image-extension; --resource-path finds it under $(BUILD).
PYTHON        := python
FIG_SCRIPTS   := $(wildcard media/*.py)
FIGS_SVG      := $(FIG_SCRIPTS:%.py=$(BUILD)/%.svg)
FIGS_PDF      := $(FIG_SCRIPTS:%.py=$(BUILD)/%.pdf)
FIGS_PNG      := $(FIG_SCRIPTS:%.py=$(BUILD)/%.png)
RESOURCES     := --resource-path=.:$(BUILD)

SLIDE_DEPS    := $(SRC) $(FILTERS)/slides.lua $(STYLE)/slides.css $(CUES_DEPS) \
                 $(FILTERS)/diagram.lua
STUDENT_DEPS  := $(SRC) $(FILTERS)/handout-student.lua $(STYLE)/handout.yaml \
                 $(CUES_DEPS) $(CUES_TEX) $(FILTERS)/diagram.lua
INSTR_DEPS    := $(SRC) $(FILTERS)/handout-instructor.lua $(STYLE)/handout.yaml \
                 $(CUES_DEPS) $(CUES_TEX) $(FILTERS)/diagram.lua
HTML_DEPS     := $(STYLE)/handout.css $(STYLE)/copy-buttons.html

PANDOC := pandoc

# tectonic is a self-contained XeTeX, installed by ../pixi.toml along with
# pandoc; it fetches LaTeX packages on first use. Outside pixi, a system TeX
# Live works too: make PDF_ENGINE=xelatex
PDF_ENGINE ?= tectonic

# pandoc 3.8 renamed --highlight-style to --syntax-highlighting and warns on the
# old spelling; older pandoc does not know the new one. Ask this pandoc which it
# takes, so the same Makefile is quiet on both.
HIGHLIGHT := $(shell $(PANDOC) --syntax-highlighting=tango -t html </dev/null \
                 >/dev/null 2>&1 && echo --syntax-highlighting=tango \
                 || echo --highlight-style=tango)

# --embed-resources inlines reveal.js itself, so the deck is a single file that
# works with no network at presentation time. It does need network at *build*
# time, the first time, to fetch reveal.js.
#
# Pin an exact reveal.js URL: pandoc's default (unpkg, reveal.js@^4) answers
# with a relative redirect that pandoc 3.11 mis-resolves, and --embed-resources
# then silently inlines "Not found" in place of reveal.js.
REVEALJS_URL ?= https://cdn.jsdelivr.net/npm/reveal.js@5.1.0
SLIDE_OPTS := -t revealjs -s --embed-resources \
              -V revealjs-url=$(REVEALJS_URL) \
              --slide-level=2 \
              $(HIGHLIGHT) \
              --css=$(STYLE)/slides.css \
              -V theme=white -V transition=none -V hash=true \
              -V width=1280 -V height=800 \
              $(RESOURCES) --default-image-extension=svg \
              --lua-filter=$(FILTERS)/slides.lua \
              $(DIAGRAM) \
              --lua-filter=$(FILTERS)/cues.lua

HANDOUT_OPTS := --pdf-engine=$(PDF_ENGINE) \
                $(RESOURCES) --default-image-extension=pdf \
                --metadata-file=$(STYLE)/handout.yaml \
                -H $(CUES_TEX) \
                $(HIGHLIGHT) \
                -V documentclass=article

# Single self-contained files (figures and diagrams inlined), so the same file
# works from GitHub Pages or opened from disk.
HTML_OPTS := -t html5 -s --embed-resources \
             --toc --toc-depth=2 \
             $(RESOURCES) --default-image-extension=svg \
             $(HIGHLIGHT) \
             --css=$(STYLE)/handout.css \
             --include-after-body=$(STYLE)/copy-buttons.html

STUDENT_SUB := Workshop $(WORKSHOP) — student notes
INSTR_SUB   := Workshop $(WORKSHOP) — instructor notes

.PHONY: all slides handouts student instructor html slides-pdf docx site clean

all: slides handouts html

slides:    $(BUILD)/$(STEM)__slides.html
handouts:  student instructor
student:   $(BUILD)/$(STEM)__student.pdf
instructor:$(BUILD)/$(STEM)__instructor.pdf
html:      $(BUILD)/$(STEM)__student.html $(BUILD)/$(STEM)__instructor.html

# Optional extras: a printable/offline-safe deck, and Word versions of the
# handouts for anyone who needs to edit them.
slides-pdf: $(BUILD)/$(STEM)__slides.pdf
docx:       $(BUILD)/$(STEM)__student.docx $(BUILD)/$(STEM)__instructor.docx

$(BUILD):
	mkdir -p $(BUILD)

# --- figures -----------------------------------------------------------------

# One rule per format: a single rule listing all three targets would tell make
# that one run of the script writes all of them.
$(BUILD)/media/%.svg: media/%.py
	@mkdir -p $(dir $@)
	$(PYTHON) $< $@
$(BUILD)/media/%.pdf: media/%.py
	@mkdir -p $(dir $@)
	$(PYTHON) $< $@
$(BUILD)/media/%.png: media/%.py
	@mkdir -p $(dir $@)
	$(PYTHON) $< $@

# --- slides ------------------------------------------------------------------

# Instructor material becomes reveal.js speaker notes: press "s" in the deck.
$(BUILD)/$(STEM)__slides.html: $(SLIDE_DEPS) $(FIGS_SVG) | $(BUILD)
	$(PANDOC) $(SLIDE_OPTS) -o $@ $(SRC)

# Beamer has no speaker-notes pane, so drop_notes strips the instructor
# material rather than printing it onto the slides.
$(BUILD)/$(STEM)__slides.pdf: $(SLIDE_DEPS) $(CUES_TEX) $(FIGS_PDF) | $(BUILD)
	$(PANDOC) -t beamer -o $@ \
	    --slide-level=2 $(HIGHLIGHT) \
	    $(RESOURCES) --default-image-extension=pdf \
	    --pdf-engine=$(PDF_ENGINE) \
	    -V mainfont="DejaVu Sans" -V sansfont="DejaVu Sans" \
	    -V monofont="DejaVu Sans Mono" \
	    -V theme=metropolis -V fontsize=9pt \
	    -M drop_notes=true \
	    -H $(CUES_TEX) \
	    --lua-filter=$(FILTERS)/slides.lua \
	    $(DIAGRAM) \
	    --lua-filter=$(FILTERS)/cues.lua \
	    $(SRC)

# --- handouts ----------------------------------------------------------------

$(BUILD)/$(STEM)__student.pdf: $(STUDENT_DEPS) $(FIGS_PDF) | $(BUILD)
	$(PANDOC) $(HANDOUT_OPTS) \
	    -M subtitle="$(STUDENT_SUB)" \
	    --lua-filter=$(FILTERS)/handout-student.lua \
	    $(DIAGRAM) \
	    --lua-filter=$(FILTERS)/cues.lua \
	    -o $@ $(SRC)

$(BUILD)/$(STEM)__instructor.pdf: $(INSTR_DEPS) $(FIGS_PDF) | $(BUILD)
	$(PANDOC) $(HANDOUT_OPTS) \
	    -M subtitle="$(INSTR_SUB)" \
	    --lua-filter=$(FILTERS)/handout-instructor.lua \
	    $(DIAGRAM) \
	    --lua-filter=$(FILTERS)/cues.lua \
	    -o $@ $(SRC)

$(BUILD)/$(STEM)__student.html: $(STUDENT_DEPS) $(HTML_DEPS) $(FIGS_SVG) | $(BUILD)
	$(PANDOC) $(HTML_OPTS) \
	    -M subtitle="$(STUDENT_SUB)" \
	    --lua-filter=$(FILTERS)/handout-student.lua \
	    $(DIAGRAM) \
	    --lua-filter=$(FILTERS)/cues.lua \
	    -o $@ $(SRC)

$(BUILD)/$(STEM)__instructor.html: $(INSTR_DEPS) $(HTML_DEPS) $(FIGS_SVG) | $(BUILD)
	$(PANDOC) $(HTML_OPTS) \
	    -M subtitle="$(INSTR_SUB)" \
	    --lua-filter=$(FILTERS)/handout-instructor.lua \
	    $(DIAGRAM) \
	    --lua-filter=$(FILTERS)/cues.lua \
	    -o $@ $(SRC)

$(BUILD)/$(STEM)__student.docx: $(STUDENT_DEPS) $(FIGS_PNG) | $(BUILD)
	$(PANDOC) -M subtitle="$(STUDENT_SUB)" \
	    $(RESOURCES) --default-image-extension=png \
	    --toc --lua-filter=$(FILTERS)/handout-student.lua \
	    $(DIAGRAM) --lua-filter=$(FILTERS)/cues.lua -o $@ $(SRC)

$(BUILD)/$(STEM)__instructor.docx: $(INSTR_DEPS) $(FIGS_PNG) | $(BUILD)
	$(PANDOC) -M subtitle="$(INSTR_SUB)" \
	    $(RESOURCES) --default-image-extension=png \
	    --toc --lua-filter=$(FILTERS)/handout-instructor.lua \
	    $(DIAGRAM) --lua-filter=$(FILTERS)/cues.lua -o $@ $(SRC)

# --- checks ------------------------------------------------------------------

# Fails if any instructor-only wording survives into a student-facing build.
# The HTML handout is read back through pandoc so that only its text is
# searched, not the inlined CSS and scripts.
.PHONY: check
check: student slides $(BUILD)/$(STEM)__student.html
	@! pdftotext $(BUILD)/$(STEM)__student.pdf - | grep -qi "instructor" \
	    || { echo "FAIL: instructor material in the student handout"; exit 1; }
	@! $(PANDOC) -f html -t plain $(BUILD)/$(STEM)__student.html | grep -qi "instructor" \
	    || { echo "FAIL: instructor material in the student HTML handout"; exit 1; }
	@! grep -q 'Not%20found' $(BUILD)/$(STEM)__slides.html \
	    || { echo "FAIL: reveal.js was not embedded in the slides"; exit 1; }
	@echo "OK: no instructor material leaked into the student handout"

# --- GitHub Pages ------------------------------------------------------------

# Copy this workshop's outputs into the site tree; ../common/site.sh runs this
# for every workshop and writes the index page.
SITE     ?= ../build/site
SITE_DIR := $(SITE)/$(notdir $(CURDIR))
SITE_FILES := $(BUILD)/$(STEM)__slides.html \
              $(BUILD)/$(STEM)__student.html $(BUILD)/$(STEM)__student.pdf \
              $(BUILD)/$(STEM)__instructor.html $(BUILD)/$(STEM)__instructor.pdf

site: $(SITE_FILES)
	mkdir -p $(SITE_DIR)
	cp $(SITE_FILES) $(SITE_DIR)/

clean:
	rm -rf $(BUILD)
