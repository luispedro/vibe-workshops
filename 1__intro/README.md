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

## Content-type cues

Audience (above) is orthogonal to *what kind of thing* a block is. The second
axis is marked the same way, and renders in all three outputs — see
`filters/cues.lua`. Two families, told apart by shape:

**Things to type** — a solid left bar, no frame, so it reads as a prompt.
Applied automatically from the code fence, so there is usually nothing to mark
up by hand:

| Source                              | Renders as                 |
| ----------------------------------- | -------------------------- |
| ```` ```bash ```` (or `sh`/`shell`/`console`/`zsh`) | ⌨ *Type this in the shell* |
| ```` ```claude ````                 | ✳ *Type this to Claude*    |

**Things to remember** — a closed box, losing weight as the material gets more
optional:

| Source           | Renders as                     | Weight            |
| ---------------- | ------------------------------ | ----------------- |
| `::: remember`   | ★ *Remember*                   | filled, boxed     |
| `::: aside`      | ⊳ *Aside · advanced*           | tinted, thin rule |
| `::: reference`  | ☰ *Reference · for later*      | dashed outline    |

A code block that is *output* or a diagram rather than something to type gets
the escape hatch:

````markdown
```{.no-cue}
        ┌────────────┐
```
````

```markdown
## Step 4: look at the data

```bash
git add data
```

```claude
> Read the files in data/
```

::: remember
The model has no memory between calls.
:::
```

Nesting works as expected: cues inside a `::: handout` or `::: instructor`
block are rendered only where that block survives, because `cues.lua` runs
after the audience filter.

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
filters/cues.lua               content-type cues; runs after the audience filter
style/slides.css               reveal.js tweaks (left-aligned, ASCII diagrams, cues)
style/handout.yaml             shared LaTeX settings for both handout PDFs
style/cues.tex                 tcolorbox definitions behind the cues, for the PDFs
```

The ASCII diagrams in the Interlude only read correctly in a fixed-width font
with box-drawing glyphs, which is why both the CSS and the LaTeX settings pin
DejaVu Sans Mono.
