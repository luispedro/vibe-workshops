---
title: "Coding Agents: an Introduction"
subtitle: "Workshop 1"
author: "Luis Pedro Coelho"
date: "2026"
---

# Prerequisites & learning goals

## Prerequisites

- You have installed `claude`, & can run it on the terminal
- You have a paid account!
- You know how to use basic git
    - `git init`
    - `git add` / `commit`
    - `git diff`
- Ideally, you know Python
- On Windows: WSL (a Linux shell) is recommended

::: handout
Everything in this workshop assumes a Linux-style shell (macOS and Linux
terminals both qualify). On Windows, use the Windows Subsystem for Linux (WSL)
and follow along in the Ubuntu terminal; the pre-workshop checklist explains
how to set it up.

Using PowerShell instead is fine, but then you are on your own: the examples
are Linux-style, and you are assumed to be comfortable translating them, as I
am not a Windows expert.

In WSL, keep the project in your Linux home folder (`~`); your
Windows files are at `/mnt/c/Users/<your Windows name>/`, and `explorer.exe .`
opens the current folder in Windows Explorer (handy for copying in the data
and for looking at plots).
:::

::: instructor
Ask Windows users to check that they are in the Ubuntu (WSL) terminal now:
`uname` should print `Linux`. Someone who is in PowerShell by accident will hit
a wall at the first `ls -l` or `pixi` command, and it is cheaper to catch it
here. PowerShell by choice is fine, but say plainly that you cannot help with
Windows-specific problems.
:::

## Workshop mechanics

You should have two post-its: one green and one red. Use them to indicate if you are following along or not.

Sometimes, I will explicitly ask whether you are following along. If you are, put the green post-it up. If not, put the red one up.

If you followed this, put the green post-it up!

::: instructor
Hand out the post-its before starting: one green and one red each. The rest of
the preparation is in `instructor-checklist.md`.
:::

## Today: low-risk usage of coding agents

We are going to work on

1. public data
2. code that is, or will soon be, public
3. without any other privacy or data sovereignty concerns

This is the _minimal risk_ scenario

::: handout
Anything Claude reads (files, command output, data) is sent to the model
provider. Today that does not matter much as we are working with publicly
available data and our code can be made public.

However, before using an agent on sensitive data (e.g., medical data), be sure
to check what policies apply to the data and what provisions are in place
(e.g., local or sovereign models).
:::

::: instructor
This sets the question aside as out of scope for the introduction. You can
mention that there are very useful bioinformatics applications where we use
public data and push to GitHub where these questions do not arise, while in
other cases, there are very real concerns about privacy and compliance.

If someone asks about their own sensitive data: everything Claude reads leaves
the machine.
:::

## Learning goals

This is an intro to using coding agents. At the end of the session, you should
know

- how to ask `claude` for code
- what `CLAUDE.md` is (including what `/init` does)
- what "context" is and how to work with it


## A note on this field

::: remember
This is a very fast moving field. Best practices are still evolving. The
models/harnesses are constantly changing.
:::


# Accessing LLMs

## Three ways to use an LLM

1. **Chat.** You probably have used this before.
2. **Auto-complete / basic assistant**. You will see this in a modern IDE or
   even Google Docs or Word if you have the right subscription. You type, the
   model suggests completions.
3. **Full agent use.** An LLM in a loop with tools: it reads files and runs
   commands, sees the results, and decides what to do next, without you typing
   each step.


## Best practices from the old typed code world still apply

::: remember
Best practices that applied to human-written code, also apply to AI-generated
code. If anything, agents make them more powerful.
:::

::: handout
Version control, small commits, tests, clear naming, documented decisions,
reproducible environments...
:::


# Case study

## The task

A few tables → visualization in Python with matplotlib and polars. The tables
are in `data/` and the task is to explore them.

Download them: <https://luispedro.github.io/vibe-workshops/1__intro/data.zip>

::: handout
The data on dogs comes from a real study:

> Cuscó A, Duan Y, Gil F, Chklovski A, Kruthi N, Pan S, Forslund S, Lau S,
> Löber U, Zhao X-M, Coelho LP. *Capturing global pet dog gut microbial
> diversity and hundreds of near-finished bacterial genomes by using long-read
> metagenomics in a Shanghai cohort.* bioRxiv (2025).
> <https://doi.org/10.1101/2025.09.17.676595>
:::

## Workshop visual conventions

```bash
ls -l # these are commands you run in the terminal
```

```claude
This is what you type to claude
```

- New line in a prompt without sending it: `\` then Enter
- Or copy & paste from <https://luispedro.github.io/vibe-workshops/>

::: handout
Each box is one prompt: type or paste all of it, then press Enter once.

Pressing Enter sends the prompt, so a prompt that spans several lines needs
`\` then Enter at the end of each line. Shift+Enter also works in many
terminals, and `/terminal-setup` (inside `claude`) enables it in some others.

Pasting several lines at once is safe: Claude Code receives them as a single
prompt. A long paste may be shown collapsed, as `[Pasted text …]`; Claude still
gets all of it.

The web version of these notes, at
<https://luispedro.github.io/vibe-workshops/>, has a copy button on every box.
:::

::: instructor
Copy-pasting the prompts is fine, and saves the room from typos in long
prompts. Encourage people to treat them as a starting point, though: change the
wording, ask for a different plot, follow their own curiosity. Seeing how
Claude reacts to *their* variation teaches more than reproducing mine.
:::

## Step 1: set up basics

```bash
git init
pixi init
git add .
git commit
```

## Introducing pixi

::: aside
Pixi is a declarative package manager

`pixi.toml` + `pixi.lock` completely define the environment. No other state.

This means that if you share with others, they will get the same. With `conda`,
this was very difficult to achieve in a consistent way.
:::

This was good in the typed code era, and even more important in the agent era.

## Step 2: Running claude

```bash
claude
```

```claude
Hello, claude
```

```claude
/model
```

```claude
/usage
```

- plain text → chat with super-powers (we'll see it in a minute)
- `/` → commands for claude code

::: handout
`/model` shows which model you are using and lets you switch (e.g., between
Opus, Sonnet and Haiku). Larger models are better at harder tasks, but use up
your limits faster. `/usage` shows how much of your plan's usage limits you
have used, and when they reset. If you hit a limit mid-workshop, switching to a
smaller model with `/model` is the quickest way to keep going.
:::

## Controlling claude

| Key / command          | What it does                              |
| ---------------------- | ----------------------------------------- |
| Esc                    | **stop claude** mid-task                  |
| Esc Esc / `/rewind`    | go back to an earlier message             |
| Shift+Tab              | cycle permission modes                    |
| `/exit`                | quit (`claude --continue` resumes)        |

::: handout
Esc is the most important key: if Claude is heading in the wrong direction,
stop it and say what you want instead. Nothing is lost, and you can type a
correction straight away.

`/rewind` (or Esc twice) can also undo the file edits Claude made since that
message, but not the effects of commands it ran. Git is the real safety net.

::: reference
| Key / command          | What it does                                      |
| ---------------------- | ------------------------------------------------- |
| ↑                      | previous prompt                                   |
| `!ls`                  | run a shell command without leaving claude        |
| `claude --continue`    | resume the most recent session in this folder     |
| `claude --resume`      | pick an older session to resume                   |
| Ctrl+Z, then `fg`      | suspend claude and bring it back                  |
:::
:::

::: instructor
Demo Esc live: ask for something long ("Write a 1000-word essay about dogs"),
press Esc after a few lines, and point out that the prompt is back and nothing
broke. Do not linger on Shift+Tab: permission modes come up again on the
"Permission prompts" slide.
:::

## Step 3: guidelines

Let's set guidelines for claude

- Use pixi, not system tools
- Use matplotlib and polars
- Commit to main
- Document any decisions

## Two ways to do this

1. Write a `CLAUDE.md` file with the guidelines in a text editor
2. Ask claude to write it for you

```claude
Write a CLAUDE.md file with the following guidelines:
  - Use pixi, not system tools
  - Use matplotlib and polars
  - Commit to main
  - Document any decisions
```

::: remember
`CLAUDE.md` is read at the start of every session in this folder, so what it
says applies to every conversation in the project.
:::

::: handout
`CLAUDE.md` is a plain text file that Claude Code loads into the context at the
start of every session, so its contents apply to every conversation in that
project. You can edit it with any text editor, at any time.

Once Claude has written it, open it and read it. Claude often writes more than
you asked for. Reading what the agent wrote, and trimming it, is a good first
habit. Then commit it:

```bash
git add CLAUDE.md
git commit -m 'Add CLAUDE.md'
```

::: remember
`CLAUDE.md` is written for Claude, not for people. Edit it for content (is
anything wrong, missing or superfluous?), not for style. Polishing the prose is
wasted effort.
:::
:::

::: instructor
First multi-line prompt: remind the room that Enter sends, so either `\` then
Enter at the end of each line, or paste it from the web handout.

Once Claude is done, open `CLAUDE.md` on screen and read it with the room. Point
out anything Claude added that was not asked for, and trim it live. Then
commit. Trim for content only: the file is for Claude, not for humans, so
clunky wording is fine. Say plainly what the file is: it is loaded at the start of every
session. The Scheme 3 diagram comes back to it.
:::

## Step 4: look at the data

::: handout
If you have not downloaded the data yet, fetch it into `data/` from the shell
(the same files as in `data.zip`, without needing `unzip`):

```bash
mkdir -p data
cd data
curl -LO https://luispedro.github.io/vibe-workshops/1__intro/data/SHD_bins_MIMAG_report.csv
curl -LO https://luispedro.github.io/vibe-workshops/1__intro/data/dataset_email.txt
cd ..
```
:::

```bash
git add data
git commit -m 'DAT add data from dogs'
```

::: instructor
Inspect the data by _eye_ first.
:::

```claude
Read the files in data/

There is a table & an email from Luis with some incomplete notes

Write a document called data.md with the structure of the data
```

## Step 5: basic plots

```claude
Plot the data.
I want to see a stacked bar plot of different qulity categories.
```

Fairly specific: we name the plot type, but leave out columns and style.

::: handout
First example, a fairly specific request: we specify the type of plot we want,
but we still leave out a lot of details. This includes column names (which the
model should be able to figure out reliably), but also style choices.
:::

::: remember
The process is not deterministic. We will have different plots.
:::

::: instructor
The typo ("qulity") is deliberate: type it as written. Point out that Claude
does not care: typos and sloppy phrasing in prompts are fine, no need to go
back and fix them.
:::

If Claude does not commit to main, you can ask it to do so:

```claude
Commit to main
```

::: instructor
Once the plot exists, look at the code with the room, interactively: this is
not on the slide. Run `git log --oneline` and `git show` on screen, open the
script Claude wrote, and ask Claude to explain it, e.g. "Show me the code that
made the stacked bar plot and explain it briefly." Keep it short (2–3 min):
the point is the habit of looking at what the agent did, which part 2 covers in
depth.
:::

## Permission prompts

Claude may ask for permission to run commands. This is a safety feature.

Depending on the permission mode, Claude either asks you or lets an internal
safety classifier decide whether to allow the command.

This has changed fast, and will likely change again. Other harnesses may
handle permissions quite differently.

::: handout
When Claude asks, you will typically see three choices:

1. **Yes**: run this once.
2. **Yes, and don't ask again**: allow this kind of command from now on, in
   this project.
3. **No**: refuse, and tell Claude what to do differently instead.

Read the command before saying yes. Shift+Tab cycles the permission modes, for
example one that accepts file edits without asking.
:::

# Interlude: tokens, context, and what is actually happening

## Building up a picture

Let's start with a simple (in fact, oversimplified) scheme and slowly build up
towards a more accurate picture.

::: handout
Four schemes, each correcting the previous one:

1. You talk directly to the model
2. …with caching
3. …except you talk to a *harness*, which runs tools in a loop
4. …and the model also talks to itself before answering you
:::

## What is a token?

1. word
2. partial word, elements like punctuation

Different systems use different tokenizations too.

For our purposes, if you think that a token is a word/punctuation, you're
probably in the right ballpark.

## Scheme 1: talking directly to the model

You type

"Good morning, Claude, let's work on bioinformatics!"

↓

[`Good` `morning` `,` `Claude` `,` `let` `'s` `work` `on` `bio` `informatics` `!`]{.tokens} → 12 tokens

⟿ *Magic* ⟿

→ [`Good` … `, Luis!`]{.tokens} ⟵ 6 tokens

::: handout
::: aside
Tokenization is a bit more complicated than "a word or a piece of a word".
Tokens are learned from how often pieces of text appear in the training data,
not from a dictionary, so:

- **The same word can cost different amounts.** In every tokenizer we checked,
  `Claude` is one token, but lowercase `claude` is two:
  [`cla` `ude`]{.tokens} (or [`cl` `aude`]{.tokens}).
- **Common words are one token; rarer ones split.** `quality` is one token, but
  the typo `qulity` is two or three: [`qul` `ity`]{.tokens}, or
  [`q` `ul` `ity`]{.tokens}. `bioinformatics` is
  [`bio` `informatics`]{.tokens}, but `bioinformatic` (without the *s*) is
  three: [`bio` `inform` `atic`]{.tokens}. `metagenomics` is
  [`met` `agen` `omics`]{.tokens}.
- **Different tokenizers disagree.** The sentence on this slide is 12 tokens
  in most tokenizers, but 11 in OpenAI's newer ones, which keep `let's`
  whole. `Enterobacteriaceae` is anything from 3 to 6 tokens. One tokenizer
  (DeepSeek-V3) has the whole of `Bioinformatics`, capitalised, as a single
  token.

Checked with open tokenizers: OpenAI `o200k_base` and `cl100k_base`, Qwen3,
DeepSeek-V3, gpt-oss and Mistral-Nemo. Claude's tokenizer is not public, so its
exact splits may differ, but the pattern is the same.
:::
:::

::: instructor
Keep this simple on stage: a token is roughly a word, and long or rare words
split. The 12 is from open tokenizers (OpenAI's newer ones give 11, and
Claude's tokenizer is not public), so do not defend the exact number.

If someone asks, or the room is ahead of time: lowercase `claude` is two
tokens (`cla` `ude`) while `Claude` is one, and the Step 5 typo `qulity` splits
while `quality` does not. Details are in the handout aside.
:::

## Scheme 1, second turn

"How are you today?"

↓

tokens **+ context!**

::: remember
The model has no memory between calls. The *entire* conversation is re-sent
every single turn.
:::

## Pricing

Two pricing schemes:

1. Per token (typically, different for input vs output)
2. Subscription with usage limits

Current API prices: <https://claude.com/pricing#api>

::: instructor
Open the pricing page live rather than quoting numbers: prices change, and the
page shows input, output and cache-read prices side by side, which sets up
Scheme 2 (caching).
:::

::: remember
Either way, using fewer tokens is better. If paying per-token, it's a direct
linear relationship; if on a subscription, you want to avoid usage limits.
:::

## Scheme 2: caching

Providers cache the state, so if you reply within a few minutes, you don't pay
full price for the previous bits of conversation.

![Toy numbers: 20 tokens typed and 200 answered per turn.](media/token-growth){width=80%}

::: handout
Because every turn re-sends the whole conversation, the total sent grows with
the *square* of the number of turns. With caching, the part the provider has
already seen is billed at a fraction of the normal price (about 10% for a cache
read at Anthropic), which flattens the curve but does not make it go away. The
cache expires after a few minutes of inactivity, after which the next turn pays
full price again.
:::

## Scheme 3: there is a harness

::: remember
You are **not** talking to the model.\
You are talking to a **harness**.
:::

This is true even on the web, but the code harness does a lot more:

1. Reads files (`CLAUDE.md`)
2. Executes commands

## Scheme 3: what actually gets sent

```{.dot width=100%}
digraph sent {
  rankdir=LR; bgcolor=transparent; nodesep=0.3; ranksep=0.45;
  node [fontname="DejaVu Sans", fontsize=16, shape=box, style="rounded,filled",
        fillcolor=white, color="#37474f", fontcolor="#263238", penwidth=1.5, margin="0.18,0.1"];
  edge [fontname="DejaVu Sans", fontsize=13, color="#37474f", fontcolor="#37474f", penwidth=1.5, arrowsize=0.8];

  you     [label="you type\n“Look at the files in data/”\n≈ 8 tokens", style="", shape=plain];
  harness [label="harness", fillcolor="#37474f", fontcolor=white];
  request [shape=plain, style="", label=<
    <table border="1" color="#37474f" cellborder="0" cellspacing="0" cellpadding="7">
      <tr><td align="left"><b>what is sent to the model</b><br align="left"/><font point-size="13">thousands of tokens</font><br align="left"/></td></tr>
      <tr><td align="left" bgcolor="#eceff1">system prompt</td></tr>
      <tr><td align="left" bgcolor="#eceff1">tool definitions</td></tr>
      <tr><td align="left" bgcolor="#eceff1">CLAUDE.md</td></tr>
      <tr><td align="left" bgcolor="#eceff1">memories</td></tr>
      <tr><td align="left" bgcolor="#eceff1">conversation so far</td></tr>
      <tr><td align="left" bgcolor="#f6d9cd"><i>“Look at the files in data/”</i>  <font point-size="13">← your 8</font></td></tr>
    </table>>];
  model   [label="model", fillcolor="#d97757", fontcolor=white, color="#d97757"];
  call    [label="tool call:\nrun ls", fontname="DejaVu Sans Mono"];

  you -> harness -> request -> model -> call;
}
```

::: handout
Your 8 typed tokens have become a much larger request containing `CLAUDE.md`,
any stored memories, the conversation so far, and the tool definitions. Then the
`ls` output is appended and the whole thing is sent *again*.
:::

## Scheme 3b: the loop

Scheme 3 showed one command. The important part is that it does not stop at
one. This is the "LLM in a loop with tools" from the start:

```{.dot width=75%}
digraph loop {
  rankdir=LR; bgcolor=transparent; nodesep=0.7; ranksep=0.7;
  node [fontname="DejaVu Sans", fontsize=16, shape=box, style="rounded,filled",
        fillcolor=white, color="#37474f", fontcolor="#263238", penwidth=1.5, margin="0.18,0.1"];
  edge [fontname="DejaVu Sans", fontsize=13, color="#37474f", fontcolor="#37474f", penwidth=1.5, arrowsize=0.8];

  you     [label="you type", shape=plain, style=""];
  context [label="context\n(everything so far)"];
  model   [label="model", fillcolor="#d97757", fontcolor=white, color="#d97757"];
  harness [label="harness\nruns the tool", fillcolor="#37474f", fontcolor=white];
  done    [label="text for you", shape=plain, style=""];

  you -> context;
  context -> model [label="sent"];
  model -> harness [xlabel="tool call  "];
  harness -> context [label="output\nappended"];
  model -> done [label="decides\nit is done", style=dashed];
  {rank=same; model; harness}
}
```

Each time round: the model emits a tool call, the harness runs it, **the output
is appended to the context**, and the model can decide what to do next until it
eventually decides to output text for you.

## Scheme 4: Reasoning models

[Like people](https://www.nature.com/articles/s41598-025-22647-2), models talk
to themselves.

The model will output tokens that it then uses to output more tokens before
finally deciding to output user-visible tokens.

::: handout
Reasoning tokens are output tokens: they are billed at the (more expensive)
output price and count against your usage limits, even though you mostly do
not see them. More reasoning helps on hard problems, but it is slower and
costs more.
:::

## Bottom line

::: remember
- the token count is not what you see on screen
- every message includes all previous messages
- you type a tiny fraction of the tokens
- caching helps
:::

## Limiting context size

Two reasons:

::: remember
1. because you pay for it (money, or rate limits)
2. **because models do worse as context grows**
:::

## Tools: `/clear` and `/compact`

::: remember
- `/clear`: wipe the conversation. Equivalent to exiting and starting a new
  session.
- `/compact`: summarise the conversation and continue from the summary.
:::

## Before you `/clear`

::: remember
Get the durable part out of the conversation and into something permanent:

- Saving to `CLAUDE.md` (conventions, decisions, how to run things)
- Saving to other files (`data.md`, notes, docstrings, etc.)
- Committing to git
:::

## Aside: subagents

::: aside
We have left out subagents and other advanced features, which further complicate
the picture.
:::

::: reference
Subagents, hooks, MCP servers, output styles and custom slash commands are all
worth reading about once the basics are comfortable. We will not cover them.
:::

# Back to the case study

## Clean up the session

```claude
/context
```

```claude
/exit
```

We should see a session ID that lets us resume the session later.

Alternatively, we can just `/clear` and start a new session:

```claude
/clear
```

## Step 6: exploration {.shrink}

Some potential prompts

```claude
Plot the distribution of quality categories by taxonomy.
```

```claude
Do it for family and genus as well.
```

```claude
Plot the quality score (completeness - 5 * contamination)
against genome size.
```

```claude
Download this file and match it against the MAGs:
https://zenodo.org/records/16356977/files/SHD1_ARGs_MAGs.csv.gz?download=1
Plot the number of ARGs vs. the quality score.
```

::: handout
This part is open exploration, discussed live as a demo. The results will be
different for everyone: each Claude makes its own choices of plot, taxonomic
level and wording, and comments on the results in its own way. Interpreting
and checking results like these is what Workshop 2 is about.
:::

## Claude commentary

![](media/claude-comment-arg.png)

This will likely be different for you (the results are not deterministic).

## Follow-up questions

You can ask follow-up questions, for example

```claude
why does it matter that it is part of their normal genomes
and not acquired resistance?
```

Again, the answer will likely be different for you, but for me the answers were
quite good!

## Creating a CLAUDE.md file from the project

We created a `CLAUDE.md` file with the guidelines, but we can also ask claude to create
one for us based on the project so far. This is useful if you have a
pre-existing project and want to start using claude.

```claude
/init
```

::: handout
Here a `CLAUDE.md` already exists, so `/init` updates it. Compare your
hand-made version with the generated one:

```bash
git diff CLAUDE.md
```

Edit it down to what is useful and commit, or run `git checkout CLAUDE.md` to
go back to your own version.
:::

::: instructor
Run `git diff CLAUDE.md` live and go through it with the room: what did `/init`
keep from our guidelines, what did it add from looking at the project (`pixi`
commands, the data layout from `data.md`)? Ask whether anything should go.
:::

## Wrap-up

You should now know

- how to ask `claude` for code
- what `CLAUDE.md` is (including what `/init` does)
- what "context" is and how to work with it

## Other coding agents

Claude Code is not the only one:

- Codex (OpenAI)
- Gemini CLI (Google)
- opencode (open source, works with many models)

At the level we worked at today, the concepts are the same.

::: handout
Tokens, context, a harness running tools in a loop, a project file of
guidelines (`AGENTS.md`, `GEMINI.md`, or `CLAUDE.md`): all of today's ideas
carry over to the other agents. The commands and keys differ, and so do the
details of permissions and pricing. Which one you end up using is mostly a
matter of personal preference and of what your institution makes available.
:::

## Discussion. Q&A

Questions?
