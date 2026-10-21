#!/usr/bin/env bash
# Launch (or attach to) a preconfigured tmux session for a project.
#
#   session.sh [path] [name]
#
#   path  project directory         (default: current directory)
#   name  session name              (default: basename of path)
#
# Layout:
#   editor  nvim, split main-vertical with a shell beside it
#   git     lazygit (if installed)
#   shell   plain shell
#
# If <path>/.venv/bin/activate exists it is sourced in every pane.
# Safe to re-run: an existing session is attached/switched to, not recreated.

set -euo pipefail

ROOT=$(realpath "${1:-$PWD}")
SESSION=${2:-$(basename "$ROOT")}
SESSION=${SESSION//[.:]/_}        # tmux disallows . and : in session names
VENV="$ROOT/.venv/bin/activate"

[ -d "$ROOT" ] || { echo "session.sh: no such directory: $ROOT" >&2; exit 1; }

attach() {
  if [ -n "${TMUX:-}" ]; then
    exec tmux switch-client -t "$SESSION"
  else
    exec tmux attach -t "$SESSION"
  fi
}

# Type a command into a pane; prefix with venv activation when available.
run_in() {
  local target=$1 cmd=$2
  if [ -f "$VENV" ]; then
    tmux send-keys -t "$target" "source '$VENV'${cmd:+ && $cmd}" Enter
  elif [ -n "$cmd" ]; then
    tmux send-keys -t "$target" "$cmd" Enter
  fi
}

tmux has-session -t "=$SESSION" 2>/dev/null && attach

# editor: nvim | shell
tmux new-session -d -s "$SESSION" -n editor -c "$ROOT"
run_in "$SESSION:editor" "nvim ."
tmux split-window -t "$SESSION:editor" -h -c "$ROOT"
run_in "$SESSION:editor.2" ""
tmux select-layout -t "$SESSION:editor" main-vertical
tmux select-pane -t "$SESSION:editor.1"

# git
if command -v lazygit >/dev/null; then
  tmux new-window -t "$SESSION" -n git -c "$ROOT"
  run_in "$SESSION:git" "lazygit"
fi

# shell
tmux new-window -t "$SESSION" -n shell -c "$ROOT"
run_in "$SESSION:shell" ""

tmux select-window -t "$SESSION:editor"
attach
