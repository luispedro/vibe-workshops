# Coding Agents Introduction

## Prerequisites & learning goals

- You have installed claude, & can run it on the terminal
- You have a paid account!
- You know how to use basic git
    - `git init`
    - `git add` / `commit`
    - `git diff`
- Ideally, you know Python
- You know the basic concept of conda/pixi

This is an intro to using coding agents. At the end of the session, you should know

- how to ask claude for code
- what CLAUDE.md is (including what `/init` does)
- what "context" is and how to work with it

## Note

This is a very fast moving field. Best practices are still evolving. The models/harnesses are constantly changing.

## Accessing LLMs

1. Chat. You probably know this
2. Auto-complete / basic assistant
3. Full agent use. The agent runs commands and re-evaluates afterwards, potentially then running further commands without further requests or asks for clarification.

## Best practices from the old typed code world still apply

Best practices that applied to human readable code, also apply to AI-generated code. If anything, agents make them more powerful.

## Case study

A few MAGs + tables → visualization in Python with Pyodide

## Step 1: set up basics

```
git init
pixi init
git add .
git commit
```

### Aside: introducing pixi

Pixi is a declarative package manager

`pixi.toml` + `pixi.lock` completely define the environment. No other state.

This means that if you share with others, they will get the same. With conda, this was very difficult

## Step 2: Running claude

```
$ claude

> Hello, claude

> /model

> /usage
```

- `>` … → chat with super-powers (we'll see it in a minute)
- `/` → commands for claude code

## Step 3: guidelines

Let's set guidelines for claude

- Use pixi, not system tools
- Use matplotlib and polars
- Commit to main
- Document any decisions

## Step 4: look at data

```
git add data
git commit -m 'DAT add data from urban soil'
```

> **[Claude]** Read the files in data/
>
> Check all the columns.
> Write a document called data.md with the structure of the data.
> Is Luis's email accurate?
> Finally, write a Python script that prints the basic stats.

I would sometimes type this out, but often it would be based on multi-turn talking.

## Step 5: basic plots

> **[Claude]** Plot the data

Deliberately underspecified!

## Interlude: tokens, context, and what is actually happening

Let's start with a simple <u>oversimplified</u> schemes and slowly build up towards a more accurate picture.

### What is a token?

1. word
2. partial word, elements like punctuation

Different systems use different tokenizations, so it's not always one-to-one.

For our purposes, if you think that a token is a word/punctuation, you're probably in the right ballpark.

### Scheme 1: directly interacting with the model

You type

"Good morning, claude!"

↓

`Good` `morn` `ing` `,` `claude` `!` → 6 tokens

⟿ *Magic* ⟿

→ `Good` … `, Luis!` ⟵ 6 tokens

*(Diagram: input text is tokenised into ~6 tokens, goes through the model ("magic"), and comes back as ~6 output tokens.)*

"How are you today?"

↓ → tokens **+ context!**

The model has no memory between calls. The *entire* conversation is re-sent every single turn. This one fact explains almost everything else in this section.


#### Pricing

Two basic models:

1. Per token (typically, slightly different for input vs output)
2. Subscription with usage limits

Either way, using fewer tokens is better. If paying per-token, it's a direct linear relationship; if on a subscription, you want to avoid usage limits.

### Scheme 2: caching

Providers cache the state, so if you reply fast, you don't pay full price for the previous bits of conversation.

### Scheme 3: there is a harness

You are **not** talking to the model
You are talking to a harness

This is true even on the web but the code harness does a lot more

1. Reads files (CLAUDE.md)
2. Executes commands

You type

"Look at the files in data/"

↓ tokenised → 8 tokens
↓ harness

```
"In the project        ⟵ CLAUDE.md
                       ⟵ "memories"
CLAUDE.md: ...
User typed: ..."
```

→ Run `ls` ⟵

*(Diagram: the harness runs `ls` in its own box and feeds the output back:)* `ls output: ...`

### Scheme 3b: the loop

Scheme 3 showed one command. The important part is that it does not stop at one:

```
        ┌──────────────────────────────────────┐
        │                                      │
   you type ──→ [ model ] ──→ tool call ──→ [ harness runs it ]
                    ↑                              │
                    │                              │
                    └───── output appended ────────┘
                           to the context
                    │
                    └──→ (decides it is done) ──→ text for you
```

Each time round: the model emits a tool call, the harness runs it, **the output is appended to the context**, and the model can decide what to do next until it eventually decides to output text for you.

### Scheme 4: models talk to themselves

Reasoning traces

The model will output tokens that it then uses to output more tokens before finally deciding to output user-visible tokens.


### Bottom line

- the token count is also not what you see on screen.
- every message includes all previous messages
- you type a tiny fraction of the tokens
- caching changes things

Limiting context size

1. because you pay for it (money, or rate limits)
2. **because models do worse as context grows**

Tools:

- `/clear`: wipe the conversation. Equivalent to exiting and starting a new session.
- `/compact`: summarise the conversation and continue from the summary.

Before you `/clear`, you can get the durable part out of the conversation and into something permanent:

- Saving to CLAUDE.md (conventions, decisions, how to run things)
- Saving to other files (`data.md`, notes, docstrings)
- Committing to git

### Aside: subagents

We have left out subagents and other advanced features, which further complicate the picture.

## Step 6: exploration

Some potential prompts

- Plot α-diversity by city
- Plot a pcoa, coloured by city

