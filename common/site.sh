#!/usr/bin/env bash
# Assemble the GitHub Pages site in build/site/: every workshop's deck and
# handouts (via `make site` in each workshop directory) plus an index page.
#
#   pixi run site        # from the repo root
#
# .github/workflows/pages.yml runs this on every push to main.

set -euo pipefail

cd "$(dirname "$0")/.."
SITE=build/site
REPO=https://github.com/luispedro/vibe-workshops

rm -rf "$SITE"
mkdir -p "$SITE"

# The title of each workshop comes from its source's YAML header.
title_tpl=$(mktemp)
trap 'rm -f "$title_tpl"' EXIT
echo '$title$' > "$title_tpl"

{
  printf -- '---\ntitle: "Vibe Sciencing Workshops"\nsubtitle: "Hands-on workshops on coding agents, by Luis Pedro Coelho"\n---\n\n'
  printf 'Source, and how to build it yourself: <%s>\n\n' "$REPO"

  for mk in [0-9]__*/Makefile; do
    dir=$(dirname "$mk")
    make -s -C "$dir" site SITE="$PWD/$SITE"
    src=$(make -s -C "$dir" --eval='print-%: ; @echo $($*)' print-SRC)
    stem=$(make -s -C "$dir" --eval='print-%: ; @echo $($*)' print-STEM)
    title=$(pandoc -t plain --template="$title_tpl" "$dir/$src")

    printf '## %s\n\n' "$title"
    if [ -f "$dir/pre-workshop-checklist.md" ]; then
      printf -- '- **Before the workshop:** [pre-workshop checklist](%s/blob/main/%s/pre-workshop-checklist.md)\n' "$REPO" "$dir"
    fi
    printf -- '- **Notes, with copy buttons:** [web](%s/%s__student.html) · [PDF](%s/%s__student.pdf)\n' "$dir" "$stem" "$dir" "$stem"
    printf -- '- **Slides:** [deck](%s/%s__slides.html)\n' "$dir" "$stem"
    printf -- '- **Instructor notes:** [web](%s/%s__instructor.html) · [PDF](%s/%s__instructor.pdf)\n\n' "$dir" "$stem" "$dir" "$stem"
  done
} | pandoc -s -t html5 --embed-resources \
      --css=common/style/handout.css \
      -o "$SITE/index.html"

echo "Site assembled in $SITE/"
