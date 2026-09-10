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
#             +--> build/$(STEM)__student.pdf
#             +--> build/$(STEM)__instructor.pdf
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

SLIDE_DEPS    := $(SRC) $(FILTERS)/slides.lua $(STYLE)/slides.css $(CUES_DEPS)
STUDENT_DEPS  := $(SRC) $(FILTERS)/handout-student.lua $(STYLE)/handout.yaml \
                 $(CUES_DEPS) $(CUES_TEX)
INSTR_DEPS    := $(SRC) $(FILTERS)/handout-instructor.lua $(STYLE)/handout.yaml \
                 $(CUES_DEPS) $(CUES_TEX)

PANDOC := pandoc

# pandoc 3.8 renamed --highlight-style to --syntax-highlighting and warns on the
# old spelling; older pandoc does not know the new one. Ask this pandoc which it
# takes, so the same Makefile is quiet on both.
HIGHLIGHT := $(shell $(PANDOC) --syntax-highlighting=tango -t html </dev/null \
                 >/dev/null 2>&1 && echo --syntax-highlighting=tango \
                 || echo --highlight-style=tango)

# --embed-resources inlines reveal.js itself, so the deck is a single file that
# works with no network at presentation time. It does need network at *build*
# time, the first time, to fetch reveal.js.
SLIDE_OPTS := -t revealjs -s --embed-resources \
              --slide-level=2 \
              $(HIGHLIGHT) \
              --css=$(STYLE)/slides.css \
              -V theme=white -V transition=none -V hash=true \
              -V width=1280 -V height=800 \
              --lua-filter=$(FILTERS)/slides.lua \
              --lua-filter=$(FILTERS)/cues.lua

HANDOUT_OPTS := --pdf-engine=xelatex \
                --metadata-file=$(STYLE)/handout.yaml \
                -H $(CUES_TEX) \
                $(HIGHLIGHT) \
                -V documentclass=article

STUDENT_SUB := Workshop $(WORKSHOP) — student notes
INSTR_SUB   := Workshop $(WORKSHOP) — instructor notes (do not distribute)

.PHONY: all slides handouts student instructor slides-pdf docx clean

all: slides handouts

slides:    $(BUILD)/$(STEM)__slides.html
handouts:  student instructor
student:   $(BUILD)/$(STEM)__student.pdf
instructor:$(BUILD)/$(STEM)__instructor.pdf

# Optional extras: a printable/offline-safe deck, and Word versions of the
# handouts for anyone who needs to edit them.
slides-pdf: $(BUILD)/$(STEM)__slides.pdf
docx:       $(BUILD)/$(STEM)__student.docx $(BUILD)/$(STEM)__instructor.docx

$(BUILD):
	mkdir -p $(BUILD)

# --- slides ------------------------------------------------------------------

# Instructor material becomes reveal.js speaker notes: press "s" in the deck.
$(BUILD)/$(STEM)__slides.html: $(SLIDE_DEPS) | $(BUILD)
	$(PANDOC) $(SLIDE_OPTS) -o $@ $(SRC)

# Beamer has no speaker-notes pane, so drop_notes strips the instructor
# material rather than printing it onto the slides.
$(BUILD)/$(STEM)__slides.pdf: $(SLIDE_DEPS) | $(BUILD)
	$(PANDOC) -t beamer -o $@ \
	    --slide-level=2 $(HIGHLIGHT) \
	    --pdf-engine=xelatex \
	    -V mainfont="DejaVu Sans" -V sansfont="DejaVu Sans" \
	    -V monofont="DejaVu Sans Mono" \
	    -V theme=metropolis -V fontsize=9pt \
	    -M drop_notes=true \
	    -H $(CUES_TEX) \
	    --lua-filter=$(FILTERS)/slides.lua \
	    --lua-filter=$(FILTERS)/cues.lua \
	    $(SRC)

# --- handouts ----------------------------------------------------------------

$(BUILD)/$(STEM)__student.pdf: $(STUDENT_DEPS) | $(BUILD)
	$(PANDOC) $(HANDOUT_OPTS) \
	    -M subtitle="$(STUDENT_SUB)" \
	    --lua-filter=$(FILTERS)/handout-student.lua \
	    --lua-filter=$(FILTERS)/cues.lua \
	    -o $@ $(SRC)

$(BUILD)/$(STEM)__instructor.pdf: $(INSTR_DEPS) | $(BUILD)
	$(PANDOC) $(HANDOUT_OPTS) \
	    -M subtitle="$(INSTR_SUB)" \
	    --lua-filter=$(FILTERS)/handout-instructor.lua \
	    --lua-filter=$(FILTERS)/cues.lua \
	    -o $@ $(SRC)

$(BUILD)/$(STEM)__student.docx: $(STUDENT_DEPS) | $(BUILD)
	$(PANDOC) -M subtitle="$(STUDENT_SUB)" \
	    --toc --lua-filter=$(FILTERS)/handout-student.lua \
	    --lua-filter=$(FILTERS)/cues.lua -o $@ $(SRC)

$(BUILD)/$(STEM)__instructor.docx: $(INSTR_DEPS) | $(BUILD)
	$(PANDOC) -M subtitle="$(INSTR_SUB)" \
	    --toc --lua-filter=$(FILTERS)/handout-instructor.lua \
	    --lua-filter=$(FILTERS)/cues.lua -o $@ $(SRC)

# --- checks ------------------------------------------------------------------

# Fails if any instructor-only wording survives into a student-facing build.
.PHONY: check
check: student slides
	@! pdftotext $(BUILD)/$(STEM)__student.pdf - | grep -qi "instructor" \
	    || { echo "FAIL: instructor material in the student handout"; exit 1; }
	@echo "OK: no instructor material leaked into the student handout"

clean:
	rm -rf $(BUILD)
