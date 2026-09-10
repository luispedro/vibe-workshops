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
- what "context" is and how to work with it
- what CLAUDE.md is

## Note

This is a very fast moving field. Best practices are still evolving. The models/harnesses are constantly changing.

## Accessing LLMs

1. Chat. You probably know this
2. Auto-complete / basic assistant
3. Full agent use. The agent runs commands and re-evaluates afterwards

## Best Practices from the old typed code world still apply

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

### Tokens, context, and costs

Let's start with a simple <u>oversimplified</u> model and slowly build up

① (Text → tokens) ⟶ message
response ⟵ (Text ⟵ Tokens)

What is a token?

1. word
2. partial word, elements like punctuation

Different systems use different tokenizations, so it's not always one-to-one.

For our purposes, if you think that a token is a word/punctuation, you're probably in the right ballpark.

### Model ①

You type

"Good morning, claude!"

↓

`Good` `morn` `ing` `,` `claude` `!` → 6 tokens

⟿ *Magic* ⟿

→ `Good` … `, Luis!` ⟵ 6 tokens

*(Diagram: input text is tokenised into ~6 tokens, goes through the model ("magic"), and comes back as ~6 output tokens.)*

"How are you today?"

↓ → tokens **+ context!**

The models sees the whole conversation at every step. Context adds up!

### Model 2: caching

Providers cache the state, so if you reply fast, you don't pay for the previous conversation.

### Model 3: there is a harness

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

### Model 4: Models talk to themselves

Reasoning traces

The model will output tokens that it then uses to output more tokens before finally deciding to output user-visible tokens

We have left out subagents &c

Bottom line:

- every message includes all previous messages
- you type a tiny fraction of the tokens
- caching changes things

Limiting context size

1. because you pay for it
2. models do worse as context grows

- `/clear`
- `/compact`

Saving to CLAUDE.md
Saving to other files
Committing to git

## Step 6: exploration

Some potential prompts

- Plot α-diversity by city
- Plot a pcoa, coloured by city
