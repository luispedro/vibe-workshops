---
title: "Coding Agents for Science"
subtitle: "Workshop 2"
author: "Luis Pedro Coelho"
date: "2026"
---

# Prerequisites & learning goals

## Prerequisites

- You did Workshop 1 (or are comfortable with everything in it)
- `claude` installed and working, paid account
- Basic git, basic Python, conda/pixi

## Learning goals

::: instructor
Fill in once the case study is chosen. Keep to three bullets, and repeat them
verbatim in the Wrap-up so the session closes on the same three.
:::


## Structure of the session

1. Using `claude` for longer-term projects
2. Case study


# Using `claude` for longer-term projects

1. Create a `PLAN.md` file.
2. Repeatedly ask `claude` to continue working on the plan until it is complete.

It's Markdown all the way down.

## Create a PLAN.md


```claude
I would like to do ...
```

This can be built up over a conversation, but you want to design a spec for the project:

- goals and non-goals
- technological choices (_e.g._., Python 3.15, using pixi for environment management)
- important steps, milestones, and deliverables (`claude` will often provide these)

## Example PLAN.md: NGLess, Haskell → Rust

[The plan: `rust-migration.md`](https://github.com/ngless-toolkit/ngless/blob/e5393c800cc342e1cbf67ae280bc80e8bcf182aa/rust-migration.md)

- 168 lines, 10 milestones
- Old: ~13.7k lines of Haskell (+ C/C++ FFI)
- Each milestone *gated* by the existing 112 functional tests
- Plan's own estimate: **6–12 months**
- Actual: Haskell removed after **9 days** (104 commits); v1.6.0 six weeks later
- New: ~25k lines of Rust, 300 unit tests

::: handout
[NGLess](https://github.com/ngless-toolkit/ngless) is a domain-specific
language for NGS (metagenomics) processing, written in Haskell since 2012. The
rewrite started on 22 June 2026 with a single commit containing the plan
(`rust-migration.md`; the file name does not matter) and a scaffold that did
nothing but print `--version`. The link above is to the plan as it was first
committed.

The plan recorded *why* (build and maintenance pain, not performance), the
scope decision (only scripts declaring `ngless "1.5"` or newer would be
supported), what was cheap to port and what was genuinely hard (streaming,
feature counting), and a crate for every Haskell library. Most importantly, it
made the existing functional test suite (112 scripts with expected outputs,
driven by `run-tests.sh`) the definition of done: the first milestone was
making the test runner accept any binary, before writing any interpreter
code.

- 22 June: plan + scaffold (milestone 1)
- 1 July: Haskell implementation deleted; v1.6.0-beta1 released (104 commits)
- 4 August: v1.6.0 released (162 commits since the start)

The plan's estimate for this was "6–12 months of focused work for a small
team". Today, `rust-migration.md` is 14 lines: it turned from a plan into a
list of the remaining known gaps.
:::

::: instructor
Click through to the plan and scroll it live: the milestones list, with a
"Gate:" on each, is the part to show.

The key point is the test oracle, not the speed. The agent could move fast
because "done" was mechanically checkable: same outputs as the Haskell binary
on the existing suite. Without that, 9 days of commits would have been 9 days
of unverified code. Ask the room: what is the equivalent of `tests/` for your
analysis?
:::

## More examples: luish and geniza

- [luish](https://github.com/luispedro/luish/blob/bdb9f18b5152b7db354e280b4339342d475a926d/PLAN.md):
  a shell from scratch, in Rust. 349 commits in a month
- [geniza](https://github.com/luispedro/geniza/blob/6174d7d1363206d7c57baef0a5d5fbc558407c7c/PLAN.md):
  a mail archiver, in Python. `DESIGN.md` first; 62 commits in 5 days

::: handout
Both links are to the plan as it was first committed.

**luish.** [luish](https://github.com/luispedro/luish) is a POSIX shell written
in Rust. There was no old code to port, so the plan (700 lines, written on 26
September 2026) had to supply what the NGLess test suite supplied:

- goals: POSIX conformance; as fast as `dash`; plugins in Python, at no cost
  unless loaded; arguments, variables and filenames as arbitrary bytes;
- *non-goals*: no bash arrays, no `[[ ]]`, no Windows, at least initially;
- a table of key design decisions with their rationale (raw
  `fork()`/`execve()` because subshells need a fork without an exec;
  `Vec<u8>` throughout because POSIX data is bytes);
- a repository layout;
- a reference implementation to settle ambiguities: "when the spec is
  ambiguous, match `dash`".

The core (parser, expansion, executor, built-ins) was committed on the same day
as the plan, and v0.1.0 was tagged the next day; v0.7.1 came three weeks
later. Three weeks in, the Oils shell spec tests were added as an external
check. After one month: 349 commits and ~53k lines of Rust, and luish has
replaced zsh as my default shell.

As the project matured, the plan shrank (700 → 228 lines) and the goals moved
to a separate, human-written `GOALS.md`. Some of the original non-goals (arrays,
`[[ ]]`) are now features: the plan is a starting point, not a contract.

**geniza.** [geniza](https://github.com/luispedro/geniza) is a one-way mail
archiver (Python 3.15, pixi). Here the specification was written first, as a
separate `DESIGN.md` (now ~1,500 lines) built up over a conversation. The plan
(261 lines) was then derived from it, and a `CLAUDE.md` recorded the project
conventions and the invariants that must never be broken (*e.g.*, the server
is never modified). All three were committed on 24 October 2026, before any
code.

The plan is split into milestones M0–M10, and every milestone ends in
something you can run, with a **Done when**:

```markdown
### M0 — Project skeleton

- `pyproject.toml` with `[tool.pixi.*]`, `pixi.lock`, the `src/` layout,
  an argparse CLI with no-op subcommands, and the pixi tasks.
- `tests/corpus/`: synthetic messages covering every case the design names
  [...]

**Done when:** `pixi run test` and `pixi run lint` pass on a fresh clone.
```

Two more features of this plan are worth copying:

- **Gates.** The first milestones need no network and write nothing; they
  produce statistics on real mail. The plan says to stop after M3 and look,
  because those numbers set defaults that the design deliberately left open.
  This is where the human decides, not the agent.
- **Status at the top.** Each milestone is marked done (and how it was
  verified) as it is completed, so `PLAN.md` doubles as the project's progress
  report. Day-to-day state goes into `working-memory.md` (next slide).

By 28 October (5 days, 62 commits): milestones M0–M7 done, M8 (JMAP sync) in
progress, with ~9.7k lines of Python and slightly more (~10.1k) lines of tests.
:::

::: instructor
Common thread across all three: the plan defines how "done" is checked (test
suite, spec + reference implementation, "done when" + gates). That is the part
to emphasize for science: the analysis equivalent is a sanity check, a known
result to reproduce, or a stopping point where you look at the data yourself.
:::

## Use a `working-memory.md` file


```claude
See 'working-memory.md' for context. Continue working until you have made a self contained change and then commit. Update 'working-memory.md' so that a new session will be able to pick up where you left off. Print a summary of the status for the user.
```

Let it run, use `/clear` to clear the context, and repeat until you are finished.

## Keep `working-memory.md` out of git

This is a matter of personal preference, but I keep `working-memory.md` out of git because it is scratch state for the agent, not part of the project history.

```bash
echo 'working-memory.md' >> .git/info/exclude
```

## Clean up the working memory

Every so often, you can ask `claude` to clean up the `working-memory.md` file.

```claude
Please clean up the 'working-memory.md' file to remove any information that is no longer relevant to the current state of the project. Make sure it only contains context that will help a new session pick up where we left off.
```

## Similar structure for reviewing projects

```claude
Please review this project, focusing on the code and write a list of all the issues to a file called 'review.md'. Be exhaustive and include any potential improvements, bugs, or areas that need clarification. Make sure to provide clear explanations for each issue you identify.
```

or

```claude
Please review this project, focusing on the documentation and text and write a list of all the issues to a file called 'review-docs.md'. Be exhaustive and include any potential improvements, bugs, or areas that need clarification. Make sure to provide clear explanations for each issue you identify.
```

```bash
echo 'review.md' >> .git/info/exclude
echo 'review-docs.md' >> .git/info/exclude
```

## Fix issues from the review

```claude
See 'review.md' for context. When fixing issues, completely remove them from 'review.md' (do not just mark them as fixed). Fix #8
```

Obviously, you can review the issues first or add more information:

```claude
See 'review-docs.md' for context. When fixing issues, completely remove them from 'review.md' (do not just mark them as fixed). Fix #9 by changing the code to match what the documentation promised.
```

NB: The numbers `#8` and `#9` refer to the issue numbers in the review files and will be different for each project.

:::instructor
Make a note that claude will often categorize issues into groups, so there may be numbers and letters or hierarchical numbering. The important thing is that the user can find the issue in the review file and remove it when fixed.
:::

# The case study

## The dataset

::: instructor
90 minutes total. Budget: ~15 min setup, ~55 min case study, ~20 min the
non-case-study material and wrap-up. Slides stay thin — this is typed live.
:::

## The question

# Exploration

## Step 1

```bash
```

```claude

```

# Wrap-up

## What we did

## Where to go next

::: reference
:::
