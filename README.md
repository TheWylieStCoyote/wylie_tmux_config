# tmux configuration

A tmux configuration styled to match the [Neovim](../nvim) and [Yazi](../yazi) setups — Monokai Pro (Ristretto filter), rounded borders, Nerd Font icons, and vim-style keybindings throughout.

## Requirements

- tmux ≥ 3.2
- A [Nerd Font](https://www.nerdfonts.com/) terminal font
- One of `wl-copy`, `xclip`, or `xsel` for clipboard integration

## Installation

The config lives at `~/.config/tmux/tmux.conf`, which tmux reads automatically from version 3.1+. To reload without restarting:

```
prefix + r
```

Or from the shell:

```sh
tmux source ~/.config/tmux/tmux.conf
```

## Theme

Colors are taken directly from the **Monokai Pro — Ristretto** palette used in the Neovim config.

| Role | Color |
|---|---|
| Session pill (purple) | `#a8a9eb` |
| Active window (yellow) | `#f9cc6c` |
| Pane border active (blue) | `#85dacc` |
| Time (blue) | `#85dacc` |
| Date (green) | `#adda78` |
| Inactive / dimmed (grey) | `#948a8b` |
| Highlight / search (yellow) | `#f9cc6c` |
| Message (yellow) | `#f9cc6c` |
| Warning (orange) | `#f38d70` |

All backgrounds use `bg=default` to support terminal transparency.

## Status Bar

```
 󰡷 session   1  window   2  other        branch   HH:MM  │  DD Mon YYYY
```

- **Left** — session name in a purple pill
- **Middle** — window list; active window highlighted in yellow
- **Right** — current pane's git branch, time, date

Window names auto-rename to the basename of the current path.

## Key Bindings

### Prefix

| Key | Action |
|---|---|
| `C-a` | Prefix (replaces default `C-b`) |
| `prefix r` | Reload config |

### Panes

| Key | Action |
|---|---|
| `prefix \|` | Split horizontal (preserves cwd) |
| `prefix -` | Split vertical (preserves cwd) |
| `prefix h/j/k/l` | Navigate panes (vim-style) |
| `prefix H/J/K/L` | Resize pane (repeatable, 5 cells) |
| `prefix x` | Kill pane |

### Windows

| Key | Action |
|---|---|
| `prefix c` | New window (preserves cwd) |
| `prefix [` / `prefix ]` | Previous / next window |
| `prefix Tab` | Last window |
| `prefix X` | Kill window |

### Sessions

| Key | Action |
|---|---|
| `prefix s` | Session/window tree picker |
| `prefix n` | New session |
| `prefix Q` | Kill session (with confirm) |

### Utilities

| Key | Action |
|---|---|
| `prefix t` | Popup terminal (80% × 75%, at cwd) |

### Copy Mode (vi)

Enter copy mode with `prefix Enter` or `prefix [`.

| Key | Action |
|---|---|
| `v` | Begin selection |
| `C-v` | Toggle rectangle selection |
| `y` | Yank to system clipboard and exit |
| `Escape` | Cancel |
| `C-d` / `C-u` | Half-page down / up |
| `H` / `L` | Start / end of line |
| `/` / `?` | Search forward / backward |
| `n` / `N` | Next / previous match |

Clipboard priority: `wl-copy` (Wayland) → `xclip` → `xsel`.

## Settings Reference

| Setting | Value | Notes |
|---|---|---|
| `prefix` | `C-a` | Ergonomic alternative to `C-b` |
| `base-index` | `1` | Windows and panes start at 1 |
| `escape-time` | `0` | No delay for Escape (important for Neovim) |
| `mouse` | `on` | Click to focus, scroll to scroll |
| `history-limit` | `50000` | Scrollback lines |
| `mode-keys` | `vi` | Copy mode uses vim bindings |
| `focus-events` | `on` | Lets Neovim detect focus for autoread |
| `detach-on-destroy` | `off` | Switch to another session on kill instead of exiting |
| `renumber-windows` | `on` | Gaps close automatically after killing a window |
