# Coding Agents Workshop: Before You Arrive

Before the workshop, make sure `git`, `pixi` and `claude` all run in a terminal
on your laptop, and that `claude` is logged in to a paid account. This takes
about 15–20 minutes. Please do it at least a day ahead: fixing installs in the
room takes time away from the workshop.

## What you must already know

**The workshop assumes you can already use the shell and git. We will not
teach them.** Everything happens in a terminal, and we commit to git
throughout. If either is new to you, learn the basics before you come.
Otherwise, you will not be able to follow along.

You should be comfortable doing these on your own:

- **Shell:** open a terminal; move between folders (`cd`, `ls`, `pwd`); create
  folders (`mkdir`); run a command and read its output; paste a command from
  this page and run it.
- **Git:** create a repository (`git init`); stage and commit changes
  (`git add`, `git commit -m "..."`); see what changed (`git status`,
  `git diff`); look at history (`git log`).

If you need a refresher, the Software Carpentry lessons are a good place to
start, at roughly 2–3 hours each:

- [The Unix Shell](https://swcarpentry.github.io/shell-novice/)
- [Version Control with Git](https://swcarpentry.github.io/git-novice/)

You will also need:

- [ ] A laptop running macOS, Linux, or Windows, where you can install software
- [ ] A paid Claude account (Pro, Max, Team or Enterprise). The free plan does
      not include Claude Code

Each section below ends with a check command. If every check passes, you are
ready.

## 1. Pixi

Pixi manages the Python environment for the workshop project. Install it with
one command ([official
instructions](https://pixi.prefix.dev/latest/installation/)):

| System               | Install                                                                              |
| -------------------- | ------------------------------------------------------------------------------------ |
| macOS / Linux        | `curl -fsSL https://pixi.sh/install.sh \| sh`                                        |
| macOS with Homebrew  | `brew install pixi`                                                                  |
| Windows (PowerShell) | `powershell -ExecutionPolicy Bypass -c "irm -useb https://pixi.sh/install.ps1 \| iex"` |
| Windows (winget)     | `winget install prefix-dev.pixi`                                                     |

Then **close the terminal and open a new one**, so it picks up the new `PATH`.
If you already had pixi, update it with `pixi self-update` (or
`brew upgrade pixi`).

**Download the workshop packages now.** Pixi keeps one shared download cache,
so this makes the same install in the room near-instant:

```bash
mkdir pixi-test
cd pixi-test
pixi init
pixi add python matplotlib polars
pixi run python -c "import matplotlib, polars; print('pixi OK')"
```

- [ ] `pixi --version` prints a version
- [ ] The last command prints `pixi OK`

Once you have done this, you can delete the `pixi-test` folder if you like; the
download cache stays.

## 2. Claude Code

Install the `claude` command-line tool ([official
instructions](https://code.claude.com/docs/en/setup)). You do not need
administrator rights.

| System               | Install                                           |
| -------------------- | ------------------------------------------------- |
| macOS / Linux / WSL  | `curl -fsSL https://claude.ai/install.sh \| bash` |
| macOS with Homebrew  | `brew install --cask claude-code`                 |
| Windows (PowerShell) | `irm https://claude.ai/install.ps1 \| iex`        |
| Windows (winget)     | `winget install Anthropic.ClaudeCode`             |

The installer shows no progress while it downloads; give it a minute. Then
**open a new terminal**.

**Already have it? Update it.** Claude Code changes quickly and the workshop
assumes a recent version. Run `claude update` (or `brew upgrade claude-code` /
`winget upgrade Anthropic.ClaudeCode`) the day before.

**Log in.** Start Claude Code in any folder and follow the browser prompts.
Choose your paid Claude account:

```bash
claude
```

If it asks whether you trust the folder, say yes. Type `Hello` and wait for a
reply, then type `/exit` to quit.

- [ ] `claude --version` prints a version
- [ ] `claude doctor` reports no errors
- [ ] Claude replied to `Hello` without asking you to log in again

## If something doesn't work

| Symptom                                                           | Fix                                                                                                                       |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `command not found` (or `not recognized`) right after installing  | Open a new terminal. If it persists, the install folder is not on your `PATH`: `~/.local/bin` for `claude`, `~/.pixi/bin` for `pixi` |
| Windows: `The token '&&' is not a valid statement separator`      | You are in PowerShell; use the PowerShell command from the table                                                          |
| Windows: `'irm' is not recognized`                                | You are in CMD; open PowerShell instead                                                                                   |
| Claude says your account has no access                            | The free plan does not include Claude Code. On a Team or Enterprise account, ask your administrator                       |
| Downloads fail or hang on a work network                          | A proxy or firewall may block them; try from home or a phone hotspot                                                      |
