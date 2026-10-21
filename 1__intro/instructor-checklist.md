# Coding Agents Workshop: Instructor Checklist

What to do before running Workshop 1. Attendees have their own list,
[`pre-workshop-checklist.md`](pre-workshop-checklist.md); this one is for the
instructor.

## About a week before

- [ ] **Send attendees their checklist**
      (<https://luispedro.github.io/vibe-workshops/>, or link
      `pre-workshop-checklist.md` directly). Ask them to do it **at least a day
      before**, and point out the parts people skip:
    - a **paid** Claude account: the free plan does not include Claude Code
    - the self-test (TSV → scatter plot → git commit): the workshop does not
      teach the shell or git
    - on Windows, install WSL now; anyone on a laptop managed by IT who cannot
      install it should contact you before the day
- [ ] **Send out the data files**: the table and the email with the incomplete
      notes. Step 4 runs `git add data`, so tell attendees to have them ready to
      copy into a `data/` folder in the project they create in Step 1.
- [ ] Ask attendees to bring a charged laptop (and a charger).

## The day before

- [ ] **Remind attendees** to run their checklist, if they have not, and to run
      `claude update`.
- [ ] Update your own `claude` and run through the whole workshop once on it.
      Claude Code changes fast: check that the slash commands, the permission
      prompts and the Step 6 prompts still behave as the slides say.
- [ ] Check that the Zenodo file in Step 6 still downloads.
- [ ] Check `/usage` on your own account: you will use a lot of it live.
- [ ] Build and check the materials from the repo root:
      `pixi run check` and `pixi run build`. Keep a local copy of the deck
      (`1__intro/build/…__slides.html`); it works offline.
- [ ] Check that <https://luispedro.github.io/vibe-workshops/> is up to date:
      people will copy prompts from it.

## Things to bring

- [ ] **Post-its: one green and one red per attendee**, plus spares (see the
      "Workshop mechanics" slide).
- [ ] The data files on a USB stick, or a link you can write on the board, for
      anyone who did not get them.
- [ ] Laptop adapter for the projector, and a charger.

## In the room, before starting

- [ ] Hand out the post-its.
- [ ] Decide what you will do when red post-its go up: is there a helper who
      can walk over, or do you carry on and come back at the next checkpoint?
- [ ] Check that the room network reaches claude.ai, pixi and Zenodo (some
      networks block them); have a phone hotspot as a fallback.
- [ ] Terminal: large font, light theme, an empty project folder with `data/`
      ready to copy in.
- [ ] Open the deck and press `s` to check the speaker notes come up.
