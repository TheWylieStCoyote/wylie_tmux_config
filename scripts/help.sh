#!/usr/bin/env bash

# Monokai Pro Ristretto — ANSI true-colour
GREY="\e[38;2;148;138;139m"
YELLOW="\e[38;2;249;204;108m"
WHITE="\e[38;2;255;241;243m"
RESET="\e[0m"

row() {
  printf "${GREY}%-14s${RESET}  ${YELLOW}%-22s${RESET}  ${WHITE}%s${RESET}\n" "$1" "$2" "$3"
}

{
  row "Prefix"     "C-a"              "Prefix key"
  row "General"    "prefix r"         "Reload config"
  echo ""
  row "Panes"      "prefix |"         "Split horizontal (preserves cwd)"
  row "Panes"      "prefix -"         "Split vertical (preserves cwd)"
  row "Panes"      "C-h/j/k/l"        "Navigate panes / Neovim splits (no prefix)"
  row "Panes"      "prefix h/j/k/l"   "Navigate panes (fallback)"
  row "Panes"      "prefix H/J/K/L"   "Resize pane (repeatable, 5 cells)"
  row "Panes"      "prefix C-l"       "Clear screen"
  row "Panes"      "prefix x"         "Kill pane"
  echo ""
  row "Windows"    "prefix c"         "New window (preserves cwd)"
  row "Windows"    "prefix ["         "Previous window"
  row "Windows"    "prefix ]"         "Next window"
  row "Windows"    "prefix Tab"       "Last window"
  row "Windows"    "prefix X"         "Kill window"
  echo ""
  row "Sessions"   "prefix s"         "Session / window tree picker"
  row "Sessions"   "prefix n"         "New session"
  row "Sessions"   "prefix \$"        "Rename session"
  row "Sessions"   "prefix Q"         "Kill session (with confirm)"
  row "Sessions"   "prefix C-s"       "Save session (resurrect)"
  row "Sessions"   "prefix C-r"       "Restore session (resurrect)"
  echo ""
  row "Utilities"  "prefix t"         "Popup terminal (80% × 75%, at cwd)"
  row "Utilities"  "prefix M"         "Tmuxinator session picker (fzf)"
  row "Utilities"  "prefix C-f"       "tmux-fzf launcher"
  row "Utilities"  "prefix F"         "tmux-fingers hint mode"
  row "Utilities"  "prefix ?"         "This help popup"
  echo ""
  row "Copy Mode"  "prefix Enter"     "Enter copy mode"
  row "Copy Mode"  "v"                "Begin selection"
  row "Copy Mode"  "C-v"              "Rectangle selection"
  row "Copy Mode"  "y"                "Yank to clipboard and exit"
  row "Copy Mode"  "Y"                "Yank current line to clipboard"
  row "Copy Mode"  "C-d / C-u"        "Half-page down / up"
  row "Copy Mode"  "H / L"            "Start / end of line"
  row "Copy Mode"  "/ ?"              "Search forward / backward"
  row "Copy Mode"  "n / N"            "Next / previous match"
  row "Copy Mode"  "Escape"           "Cancel"
} | fzf \
  --ansi \
  --no-sort \
  --layout=reverse \
  --border=rounded \
  --header=" tmux keybindings  ·  type to filter  ·  esc to close" \
  --header-first \
  --prompt="   " \
  --pointer="▶" \
  --color="bg:#2c2525,bg+:#3a2f2f,fg:#fff1f3,fg+:#fff1f3,\
hl:#f9cc6c,hl+:#f9cc6c,\
prompt:#a8a9eb,pointer:#fd6883,\
marker:#adda78,border:#948a8b,\
header:#85dacc,info:#948a8b,\
gutter:#2c2525" \
  --bind="enter:ignore" \
  --bind="esc:abort" \
  --no-info \
  --margin=1,2
