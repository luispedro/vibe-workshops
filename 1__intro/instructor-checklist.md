# Coding Agents Workshop: Instructor Checklist

What to do before running Workshop 1. Attendees have their own list,
[`pre-workshop-checklist.md`](pre-workshop-checklist.md); this one is for the
instructor.

## About a week before

- [ ] **Send attendees their checklist**
      (<https://luispedro.github.io/vibe-workshops/>, or link
      `pre-workshop-checklist.md` directly), together with the data (see [the
      draft email](#a-week-before-checklist-and-data)). Emphasize that:
    - a **paid** Claude account: the free plan does not include Claude Code
    - the self-test (TSV → scatter plot → git commit): the workshop does not
      teach the shell or git
    - the workshop will be using Linux, so if they are on Windows they should
      either be proficient with PowerShell and able to work independently, or
      have WSL installed
- [ ] **Point attendees to the data files** on GitHub
      (<https://github.com/luispedro/vibe-workshops/tree/main/1__intro/data>):
      the table and the email with the incomplete notes. Step 4 runs `git add
      data`, so tell attendees to download them in advance, ready to copy into
      a `data/` folder in the project they create in Step 1.
- [ ] Ask attendees to bring a charged laptop (and a charger).

## The day before

- [ ] **Remind attendees** to run their checklist (see [the draft
      email](#the-day-before-reminder)).
- [ ] Remind attendees to bring a charged laptop (and a charger)
- [ ] Remind attendees to not deplete their Claude credits before the workshop!

## Things to bring

- [ ] **Post-its: one green and one red block**. Exact colours are not
  important (e.g., pink is often close enough for _red_).

## In the room, before starting

- [ ] Hand out the post-its.
- [ ] Check that the room network reaches claude.ai, pixi, GitHub and Zenodo (some
      networks block them); have a phone hotspot as a fallback.
- [ ] Terminal: large font, light theme, an empty project folder with `data/`
      ready to copy in.
- [ ] Open the deck and press `s` to check the speaker notes come up.

## Draft emails

Fill in the `[brackets]` before sending.

### A week before: checklist and data

```text
Subject: Coding Agents workshop on [date]: please set up beforehand

Hi all,

The workshop "Coding Agents: an Introduction" is on [date], [time], in [room].
It is hands-on: you will follow along on your own laptop, so please set it up
beforehand.

1. Follow the pre-workshop checklist, at least a day before the workshop:

   https://github.com/luispedro/vibe-workshops/blob/main/1__intro/pre-workshop-checklist.md

   It takes about 15-20 minutes (longer on Windows). By the end, git, pixi and
   claude should all run in a terminal. In particular:

   - You need a *paid* Claude account. The free plan does not include Claude Code.
   - The workshop does not teach the shell or git. If you could not take a TSV
     file, make a scatter plot of one column against another in Python (or R),
     and commit that code to a git repository, the workshop is not suitable for
     you yet. The checklist links to good refreshers if you need them.
   - We work in a Linux-style shell. On Windows, either install WSL (the
     checklist explains how) or be comfortable translating the commands to
     PowerShell on your own.

2. Download the data files (a table and an email) from:

   https://github.com/luispedro/vibe-workshops/tree/main/1__intro/data

   Keep them somewhere you can find them. During the workshop, we will copy
   them into a data/ folder in a new project. This simulates the situation
   where I am your collaborator and I send you some data to work with.

3. Bring your laptop, charged, and its charger.

If something in the checklist does not work, or your laptop is managed by IT
and you cannot install software, you will need to fix this before the workshop.
We will not have time to troubleshoot individual laptops during the workshop.

The slides and notes are at https://luispedro.github.io/vibe-workshops/

See you on [date],
[your name]
```

### The day before: reminder

```text
Subject: Reminder: Coding Agents workshop tomorrow, [time], [room]

Hi all,

A reminder that the workshop "Coding Agents: an Introduction" is tomorrow,
[time], in [room].

- If you have not done the pre-workshop checklist yet, please do it today:
  https://github.com/luispedro/vibe-workshops/blob/main/1__intro/pre-workshop-checklist.md
  If you did it a while ago, run `claude update` to get the latest version.
- Have the data files ready (see the previous email). If you have not
  downloaded them yet, they are at
  https://github.com/luispedro/vibe-workshops/tree/main/1__intro/data
- Bring your laptop, charged, and its charger.
- Paid Claude plans have usage limits. Avoid heavy use of Claude right before
  the workshop, so you do not run out halfway through!

See you tomorrow,
[your name]
```
