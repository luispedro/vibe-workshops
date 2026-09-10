# Workshop 1 — Coding Agents: an Introduction

One source file, three audiences.

```
intro-to-coding-agents.md  --+--> build/…__slides.html      reveal.js deck
                             +--> build/…__student.pdf      student handout
                             +--> build/…__instructor.pdf   instructor handout
```

## Building

```bash
make            # deck + both handouts
make slides     # just the deck
make handouts   # just the two PDFs
make check      # assert no instructor material reached the student handout
make clean
```

Optional extras:

```bash
make slides-pdf # beamer PDF of the deck (printable / projector fallback)
make docx       # .docx versions of both handouts, for editing
```

Requires `pandoc`, `xelatex`, and the DejaVu fonts. The first `make slides`
needs network access to fetch reveal.js; after that the deck is a single
self-contained HTML file that works offline.

## How the three outputs are separated

Audience is marked in the source with pandoc fenced Divs (and matching Spans
for inline text). Everything unmarked appears everywhere.

| Marker            | Slides                | Student handout | Instructor handout |
| ----------------- | --------------------- | --------------- | ------------------ |
| *(unmarked)*      | yes                   | yes             | yes                |
| `::: instructor`  | speaker notes (`s`)   | **no**          | yes, set off       |
| `::: handout`     | no                    | yes             | yes                |
| `::: slides`      | yes                   | no              | no                 |

```markdown
## Scheme 2: caching

Providers cache the state, so if you reply fast, you don't pay full price.

::: handout
Longer prose that would not fit on a slide but belongs in the notes.
:::

::: instructor
Teaching note: keep this brief, it is a correction to Scheme 1, not a topic.
:::
```

`::: instructor` is the interesting one: it becomes reveal.js speaker notes in
the deck (press `s` during the talk to open the presenter view), so the same
text serves as both the printed instructor notes and the live prompt on stage.
Beamer has no notes pane, so `make slides-pdf` strips it instead.

`make check` guards the direction that matters — it fails the build if
instructor wording turns up in the student PDF.

## Structure of the source

- `#` headings start a new part (a section slide in the deck)
- `##` headings are one slide each (`--slide-level=2`)

So splitting a slide in two means splitting a `##` section in two.

## Files

```
intro-to-coding-agents.md      the source; edit this
Makefile                       build rules
filters/slides.lua             .instructor -> speaker notes, drop .handout
filters/handout-student.lua    drop .instructor, unwrap .handout
filters/handout-instructor.lua keep .instructor as labelled block quotes
style/slides.css               reveal.js tweaks (left-aligned, ASCII diagrams)
style/handout.yaml             shared LaTeX settings for both handout PDFs
```

The ASCII diagrams in the Interlude only read correctly in a fixed-width font
with box-drawing glyphs, which is why both the CSS and the LaTeX settings pin
DejaVu Sans Mono.
