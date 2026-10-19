# Scripted sessions without tmuxinator

Everything tmuxinator does can be written as a plain shell script using tmux commands. Use this on machines where tmuxinator is not installed, or when you want zero dependencies beyond tmux itself.

## Building blocks

| Command | Purpose |
|---|---|
| `tmux has-session -t <s>` | Exit 0 if session `<s>` exists (use it to make scripts re-runnable) |
| `tmux new-session -d -s <s> -n <w> -c <dir>` | Create session `<s>` detached, with first window `<w>` starting in `<dir>` |
| `tmux new-window -t <s> -n <w> -c <dir>` | Add window `<w>` to session `<s>` |
| `tmux split-window -t <s>:<w> -h` / `-v` | Split the current pane of window `<w>` horizontally / vertically |
| `tmux send-keys -t <s>:<w>.<n> '<cmd>' Enter` | Type `<cmd>` into pane `<n>` of window `<w>` and press Enter |
| `tmux select-layout -t <s>:<w> <layout>` | Apply a built-in layout: `main-vertical`, `main-horizontal`, `even-horizontal`, `even-vertical`, `tiled` |
| `tmux select-window -t <s>:<w>` | Choose which window is active when you attach |
| `tmux attach -t <s>` | Attach to the finished session |

Panes are addressed as `session:window.index`, where the index starts at 1 (this config sets `pane-base-index 1`).

> **Note:** always start commands with `send-keys` rather than passing them as the window's startup command (`tmux new-window ... 'nvim .'`). tmux runs a startup command *instead of* a shell, so the window closes as soon as the command exits. `send-keys` types into a normal shell, so the pane survives and the shell environment (venv, aliases, etc.) is available.

## Full example: one project

A complete launcher equivalent to the tmuxinator layout in the README — editor split main-vertical, a git window, and a shell window, with a Python venv activated in every pane. Safe to run repeatedly: if the session exists it just attaches.

```sh
#!/usr/bin/env bash
# ~/.config/tmux/scripts/session-myproject.sh
set -euo pipefail

SESSION=myproject
ROOT=~/code/myproject
VENV="$ROOT/.venv/bin/activate"

# If the session already exists, just attach (same as tmux new -A).
if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach -t "$SESSION"
fi

# Window 1: editor, split main-vertical
tmux new-session   -d -s "$SESSION" -n editor -c "$ROOT"
tmux send-keys     -t "$SESSION:editor"   "source $VENV && nvim ." Enter
tmux split-window  -t "$SESSION:editor" -h -c "$ROOT"
tmux send-keys     -t "$SESSION:editor.2" "source $VENV" Enter
tmux select-layout -t "$SESSION:editor" main-vertical

# Window 2: git
tmux new-window    -t "$SESSION" -n git -c "$ROOT"
tmux send-keys     -t "$SESSION:git" "lazygit" Enter

# Window 3: plain shell with venv
tmux new-window    -t "$SESSION" -n shell -c "$ROOT"
tmux send-keys     -t "$SESSION:shell" "source $VENV" Enter

tmux select-window -t "$SESSION:editor"
exec tmux attach   -t "$SESSION"
```

Make it executable and run it directly, or call it from the terminal auto-start block in `~/.bashrc` in place of `tmux new -A -s main`:

```sh
if command -v tmux >/dev/null && [ -z "$TMUX" ] && [ -t 0 ] && [[ $- == *i* ]]; then
  ~/.config/tmux/scripts/session-myproject.sh
fi
```

For several projects, copy the script and change the three variables at the top.

## Generic launcher with arguments

One script that takes the session name and project path, and activates a venv only if one exists (so it works for non-Python projects too):

```sh
#!/usr/bin/env bash
# usage: tmux-project <name> <path>
set -euo pipefail

SESSION=$1
ROOT=$2
VENV="$ROOT/.venv/bin/activate"

tmux has-session -t "$SESSION" 2>/dev/null && exec tmux attach -t "$SESSION"

activate() {
  [ -f "$VENV" ] && tmux send-keys -t "$1" "source $VENV" Enter
}

tmux new-session -d -s "$SESSION" -n editor -c "$ROOT"
activate "$SESSION:editor"
tmux send-keys -t "$SESSION:editor" "nvim ." Enter

tmux new-window -t "$SESSION" -n shell -c "$ROOT"
activate "$SESSION:shell"

tmux select-window -t "$SESSION:editor"
exec tmux attach -t "$SESSION"
```

```sh
tmux-project myproject ~/code/myproject
tmux-project blog      ~/code/blog
```

## Interaction with tmux-continuum

tmux-continuum restores the last saved session on the first tmux start. If a scripted session is your default, set `@continuum-restore 'off'` in `tmux.conf`, otherwise you get the restored session **and** the scripted one.
