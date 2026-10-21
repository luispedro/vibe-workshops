# vibe-workshops

Teaching material for a hands-on workshop on coding agents, given by Luis Pedro
Coelho. Source is markdown; pandoc builds a reveal.js deck and two handouts
(student and instructor), each as PDF and as HTML, from the *same* file. The
HTML handouts carry a copy button on every prompt, and everything is published
to GitHub Pages (<https://luispedro.github.io/vibe-workshops/>) on each push to
`main`.

## Structure: two parts, 90 minutes each

```
common/       shared build machinery — Makefile rules, pandoc filters, styles
1__intro/     Workshop 1 — Coding Agents: an Introduction
2__science/   Workshop 2 — Coding Agents for Science (case study; scaffold only)
```

Each workshop directory holds only its own source markdown, a README, and a
three-line `Makefile` that sets `SRC`/`STEM`/`WORKSHOP` and includes
`../common/workshop.mk`. Nothing in `common/` is copied per workshop — fix it
once and every part gets the fix.

- **`1__intro`** is the completely introductory session: what a coding agent is,
  how to ask Claude for code, `CLAUDE.md` and `/init`, and what "context" is and
  how to manage it (`/clear`, `/compact`, compaction, caching, the tool loop).
  Assumes only basic git, some Python, and a paid Claude account.
- **`2__science`** is the follow-up: a longer case study, focused on using Claude
  Code for scientific exploration — data analysis, plotting, iterating on an
  analysis, checking what the agent actually did. It builds on part 1 and does
  not re-teach the basics.

**Each part targets 90 minutes.** This is the hard budget when adding material:
if a section grows, something else has to shrink. Roughly, plan for slides to be
short and the typing to take the time — attendees are following along on their
own machines.

## It is hands-on, so slides are deliberately thin

The workshop is performed live: the instructor types, the room types along. Many
points are meant to be **demonstrated rather than spelled out on a slide** — the
slide is a cue and a landmark, not the explanation.

Practical consequences when editing:

- Do not turn a slide into prose. If something needs a paragraph, it belongs in
  `::: handout` (student notes) or `::: instructor` (speaker notes).
- Teaching notes, timing hints, "what to say here", answers to questions you
  plan to ask the room, and things that will go wrong live all go in
  `::: instructor`. That material is instructor-only and must never leak into
  the student handout — `make check` enforces this.
- Prefer showing a command or a prompt over describing it. Code fences are
  auto-labelled as things to type (see cues below).

## Markdown machinery: tagging sections

Both parts share one build (`common/workshop.mk`, `common/filters/`,
`common/style/`). Two orthogonal axes of tagging, both with pandoc fenced Divs
(`:::`), and matching Spans for inline text. **Unmarked content appears
everywhere.**

### Axis 1 — audience

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

`::: instructor` becomes reveal.js speaker notes in the HTML deck (press `s`
live), so the same text is both the printed instructor notes and the on-stage
prompt. Beamer has no notes pane, so `make slides-pdf` strips it.

### Axis 2 — content-type cues

What *kind* of thing a block is. Renders in all three outputs; see
`common/filters/cues.lua`.

**Things to type** — solid left bar, applied automatically from the code fence,
so there is usually nothing to mark up by hand:

| Source                                             | Renders as                 |
| -------------------------------------------------- | -------------------------- |
| ```` ```bash ```` (or `sh`/`shell`/`console`/`zsh`) | ⌨ *Type this in the shell* |
| ```` ```claude ````                                | ✳ *Type this to Claude*    |
| ```` ```powershell ````                            | ⌨ *Type this in PowerShell* |

**One prompt per ```` ```claude ```` fence, with no `>` or other prompt
marker.** The box label already says what to do, a `>` gets typed literally,
and the HTML handout's copy button copies the whole fence as one prompt. Two
prompts (or `/model` and `/usage`) are two fences. A multi-line prompt is fine
inside one fence: it is pasted as a unit, and the conventions slide teaches
`\` then Enter for typing one.

**Things to remember** — a closed box, lighter as the material gets more
optional:

| Source           | Renders as                | Weight            |
| ---------------- | ------------------------- | ----------------- |
| `::: remember`   | ★ *Remember*              | filled, boxed     |
| `::: aside`      | ⊳ *Aside · advanced*      | tinted, thin rule |
| `::: reference`  | ☰ *Reference · for later* | dashed outline    |

**Things for some readers only** — a blue box, so everyone else can skip it:
`::: windows` renders as ⊞ *Windows only*.

A code block that is *output*, not something to type, opts out with
`{.no-cue}`:

````markdown
```{.no-cue}
total 8
-rw-r--r-- 1 you you 4096 data.csv
```
````

Cues nest inside audience Divs as expected: `cues.lua` runs *after* the audience
filter, so a cue inside a dropped block is never rendered.

### Diagrams and figures

Do not draw diagrams in ASCII. Two mechanisms, both rendered at build time:

- **Diagrams** (boxes and arrows): a ```` ```dot ```` code block is drawn by
  Graphviz through `common/filters/diagram.lua` (vendored pandoc-ext/diagram):
  SVG in the deck, PDF in the handouts. Size it with an attribute,
  ```` ```{.dot width=85%} ````. Reuse the deck palette: `#d97757` (Claude
  orange) for the model, `#37474f` for the harness/shell, DejaVu Sans.
- **Plots** (actual data): a script `media/NAME.py` that writes the figure to
  the path given as its first argument; the build runs it into
  `build/media/NAME.{svg,pdf,png}`. Reference it *without* an extension,
  `![caption](media/NAME){width=80%}`, and each output picks its own format.

Check the result on the slide, not just in the handout: the deck is 1280×800
and a figure plus a heading and a line of text fills it.

### Heading levels

- `#` starts a new part (a section slide in the deck)
- `##` is exactly one slide (`--slide-level=2`)

Splitting a slide in two means splitting a `##` section in two.

## Building

From inside a workshop directory (`1__intro/` or `2__science/`), or with
`make -C 1__intro`:

```bash
make            # deck + both handouts, as PDF and HTML
make slides     # just the reveal.js deck
make handouts   # student + instructor PDFs
make html       # student + instructor HTML, with copy buttons
make check      # fails if instructor material reached a student handout
make slides-pdf # beamer fallback deck
make docx       # .docx handouts, for editing
make clean
```

Run these inside the pixi environment (`pixi shell`, or prefix with
`pixi run`): `pixi.toml` at the repo root provides pandoc, tectonic (the PDF
engine, a self-contained XeTeX), DejaVu fonts, poppler, make, Graphviz and
Python with matplotlib, pinned by `pixi.lock`. Do not rely on system tools. From the root, `pixi run build` /
`check` / `clean` cover both workshops, and `pixi run site` assembles the GitHub
Pages site in `build/site/` (`common/site.sh`; a workshop's `data/` is published
both as-is and as `data.zip`, and its `pre-workshop-checklist.md` as an HTML
page styled like the handouts; the workflow in
`.github/workflows/pages.yml` runs `check` and `site`). The first PDF build needs network for
tectonic to fetch LaTeX packages. First `make slides` needs network
to fetch reveal.js; the result is self-contained and works offline. `build/` is
gitignored repo-wide.

Run `make check` before committing changes that touch `::: instructor` blocks.

## Working in this repo

- **Commit updates to `main`.** No feature branches for content edits; this is a
  single-author teaching repo and the deck should always build from `main`.
- Edit the source markdown, not anything in `build/`.
- Machinery changes go in `common/` and affect both parts, so rebuild both
  (`pixi run check`, from the repo root) before committing one.
