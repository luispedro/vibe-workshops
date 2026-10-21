# Coding Agents Workshop: Before You Arrive

Before the workshop, make sure `git`, `pixi` and `claude` all run in a terminal
on your laptop, and that `claude` is logged in to a paid account. This takes
about 15–20 minutes (longer on Windows, which first needs WSL; see section 0).
Please do it at least a day ahead: fixing installs in the room takes time away
from the workshop.

**On Windows, we recommend the Windows Subsystem for Linux (WSL).** The
workshop is done in a Linux-style shell, and every command here and in the
workshop assumes one. WSL gives you a real Linux (Ubuntu) terminal on your
Windows laptop, so you can follow along exactly as written.

You can use PowerShell instead if you prefer, but then we assume you are
comfortable translating Linux-style commands to Windows on your own: all the
examples are Linux-style, and the instructor does not know Windows well enough
to help with Windows-specific problems. In that case, skip section 0 and use
the Windows instructions on the official install pages linked below.

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

**Python** is useful. The examples are in Python and use the `matplotlib` and
`polars` libraries. You can follow along without knowing Python, but it will be
easier if you do.

**A quick self-test:** if you would not be able to take a TSV file and use
Python (or R) to generate a scatter plot of one column against another and
then commit that code to a git repository, this workshop is not suitable for
you (at least, not yet).

You will also need:

- [ ] A laptop running macOS, Linux, or Windows with WSL, where you can install
      software
- [ ] A paid Claude account (Pro, Max, Team or Enterprise). The free plan does
      not include Claude Code

Each section below ends with a check command. If every check passes, you are
ready.

## 0. Windows only: WSL

Skip this section on macOS and Linux (and on Windows if you have chosen to use
PowerShell).

Install WSL ([official
instructions](https://learn.microsoft.com/en-us/windows/wsl/install)). Open
PowerShell **as administrator** (right-click → *Run as administrator*) and run:

```powershell
wsl --install
```

This installs Ubuntu. **Restart the computer** when it asks. Then open
**Ubuntu** from the Start menu; the first time, it asks you to pick a Linux
username and password (they do not need to match your Windows ones).

From here on, **do everything in the Ubuntu terminal**, both for the rest of
this page and in the workshop. Use the macOS / Linux commands below.

```bash
uname
git --version
```

- [ ] `uname` prints `Linux`
- [ ] `git --version` prints a version (if not: `sudo apt update && sudo apt
      install git`)

Work in your Linux home folder (`cd ~`), not under `/mnt/c/`: it is much
faster. Your Windows files are still reachable at `/mnt/c/Users/<your Windows
name>/`, and `explorer.exe .` opens the current folder in Windows Explorer.

Installing WSL needs administrator rights, and a hardware setting
(virtualization) that is usually on. If your laptop is managed by IT and you
cannot install it, contact the instructor before the workshop.

## 1. Pixi

Pixi manages the Python environment for the workshop project. Install it with
one command ([official
instructions](https://pixi.prefix.dev/latest/installation/)):

| System               | Install                                       |
| -------------------- | --------------------------------------------- |
| macOS / Linux / WSL  | `curl -fsSL https://pixi.sh/install.sh \| sh` |
| macOS with Homebrew  | `brew install pixi`                           |

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

The installer shows no progress while it downloads; give it a minute. Then
**open a new terminal**.

**Already have it? Update it.** Claude Code changes quickly and the workshop
assumes a recent version. Run `claude update` (or `brew upgrade claude-code`)
the day before.

**Log in.** Start Claude Code in any folder and follow the browser prompts.
Choose your paid Claude account. (In WSL, if no browser opens, copy the
link that Claude prints into your Windows browser.)

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
| Windows: `'curl' is not recognized`, or `The token '&&' is not a valid statement separator` | You are in PowerShell or CMD, not WSL; open **Ubuntu** from the Start menu and run the command there (or, if you chose PowerShell, use the Windows instructions on the official page) |
| Windows: `wsl --install` fails, or mentions virtualization        | Run PowerShell as administrator; if it still fails, virtualization may be off in the BIOS. Contact the instructor ahead of time |
| Claude says your account has no access                            | The free plan does not include Claude Code. On a Team or Enterprise account, ask your administrator                       |
| Downloads fail or hang on a work network                          | A proxy or firewall may block them; try from home or a phone hotspot                                                      |
