# Building the workshop materials

## One source, three outputs

Each workshop contains a main markdown file, which pandoc turns into:

- a **reveal.js slide deck** (self-contained HTML; press `s` for speaker notes),
- a **student handout** (PDF and HTML), and
- an **instructor handout** (PDF and HTML), with teaching notes and timing.

The HTML handouts have a copy button on every prompt and command. They are
published, with the decks and PDFs, at <https://luispedro.github.io/vibe-workshops/>
by `.github/workflows/pages.yml` on every push to `main`.

What goes where is marked in the source with fenced Divs (`::: handout`,
`::: instructor`, …). See the README in each workshop for the details.

## Building

Everything the build needs (pandoc, tectonic, Graphviz, Python + matplotlib,
fonts) comes from [pixi](https://pixi.sh), pinned in `pixi.lock`. From the
repository root:

```bash
pixi run build    # both parts: deck + both handouts
pixi run check    # fail if instructor notes leaked into a student handout
pixi run site     # both parts, assembled for GitHub Pages in build/site/
pixi run clean
```

Or build a single workshop, or a single target:

```bash
pixi run make -C 1__intro           # deck + both handouts
pixi run make -C 1__intro slides    # just the deck
pixi run make -C 1__intro handouts  # just the two PDFs
pixi run make -C 1__intro html      # just the two HTML handouts
```

Outputs land in `<workshop>/build/`. Tectonic fetches and caches its LaTeX
packages on first use. Rebuilding the slides requires network access to fetch
reveal.js; the finished deck works offline.

## Layout

```
common/       build machinery shared by both parts
  workshop.mk   the make rules
  site.sh       assembles the GitHub Pages site
  filters/      pandoc Lua filters (audience, cues, Graphviz diagrams)
  style/        reveal.js CSS, LaTeX settings, HTML handout CSS and copy buttons
1__intro/     workshop 1: source, media, pre-workshop checklist
2__science/   workshop 2: source
pixi.toml     build environment (pixi.lock pins it)
```

Conventions for editing the material — the 90-minute budget, what belongs on a
slide versus in the notes, and the markup — are in [`CLAUDE.md`](CLAUDE.md).
