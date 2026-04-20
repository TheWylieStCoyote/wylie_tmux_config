# tmux configuration

A tmux configuration styled to match the [Neovim](../nvim) and [Yazi](../yazi) setups — Monokai Pro (Ristretto filter), rounded borders, Nerd Font icons, and vim-style keybindings throughout.

## Requirements

- tmux ≥ 3.2
- A [Nerd Font](https://www.nerdfonts.com/) terminal font
- [tpm](https://github.com/tmux-plugins/tpm) for plugin management

## Installation

The config lives at `~/.config/tmux/tmux.conf`, which tmux reads automatically from version 3.1+.

**Install tpm:**

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**Install plugins** — start tmux, then:

```
prefix + I
```

**Reload config** without restarting:

```
prefix + r
```

Or from the shell:

```sh
tmux source ~/.config/tmux/tmux.conf
```

## Plugins

| Plugin | Purpose |
|---|---|
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save and restore sessions across reboots |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save resurrect state every 15 minutes |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless `C-h/j/k/l` navigation between Neovim splits and tmux panes |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | Robust system clipboard integration in copy mode |
| [tmux-fzf](https://github.com/sainnhe/tmux-fzf) | Fuzzy-find sessions, windows, panes, and commands |
| [tmux-fingers](https://github.com/Morantron/tmux-fingers) | Hint mode for copying paths, URLs, and git hashes without entering copy mode |

> **vim-tmux-navigator** requires a matching Neovim plugin. Add `{ "christoomey/vim-tmux-navigator" }` to your lazy.nvim plugins.

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
| `C-h/j/k/l` | Navigate panes **or** Neovim splits (vim-tmux-navigator, no prefix) |
| `prefix h/j/k/l` | Navigate panes (prefix fallback) |
| `prefix H/J/K/L` | Resize pane (repeatable, 5 cells) |
| `prefix C-l` | Clear screen (restored — vim-tmux-navigator claims bare `C-l`) |
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
| `prefix M` | Tmuxinator session picker (fzf) |
| `prefix C-f` | tmux-fzf launcher (sessions, windows, panes, commands) |
| `prefix F` | tmux-fingers hint mode (copy paths, URLs, hashes) |
| `prefix C-s` | Save session (tmux-resurrect) |
| `prefix C-r` | Restore session (tmux-resurrect) |

### Copy Mode (vi)

Enter copy mode with `prefix Enter` or `prefix [`.

| Key | Action |
|---|---|
| `v` | Begin selection |
| `C-v` | Toggle rectangle selection |
| `y` | Yank to system clipboard and exit (tmux-yank) |
| `Y` | Yank current line to clipboard (tmux-yank) |
| `Escape` | Cancel |
| `C-d` / `C-u` | Half-page down / up |
| `H` / `L` | Start / end of line |
| `/` / `?` | Search forward / backward |
| `n` / `N` | Next / previous match |

## Tmuxinator

[Tmuxinator](https://github.com/tmuxinator/tmuxinator) manages named session layouts defined as YAML files in `~/.config/tmuxinator/`.

**Install:**

```sh
gem install tmuxinator
```

**Common commands:**

| Command | Action |
|---|---|
| `tmuxinator start <name>` | Start a session |
| `tmuxinator stop <name>` | Stop a session |
| `tmuxinator new <name>` | Create a new session config |
| `tmuxinator edit <name>` | Edit an existing config |
| `tmuxinator list` | List all session configs |
| `prefix M` | fzf picker to start any tmuxinator session |

**Example layout** (`~/.config/tmuxinator/example.yml`):

```yaml
name: example
root: ~/

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim .
        - ""

  - files:
      panes:
        - yazi

  - git:
      panes:
        - lazygit

  - terminal:
      panes:
        - ""
```

Copy and rename `example.yml` for each project, update `root` to the project path, and adjust the panes to taste.

## Settings Reference

| Setting | Value | Notes |
|---|---|---|
| `prefix` | `C-a` | Ergonomic alternative to `C-b` |
| `base-index` | `1` | Windows and panes start at 1 |
| `escape-time` | `0` | No delay for Escape (important for Neovim) |
| `mouse` | `on` | Click to focus, scroll to scroll |
| `history-limit` | `1000000` | Scrollback lines |
| `mode-keys` | `vi` | Copy mode uses vim bindings |
| `focus-events` | `on` | Lets Neovim detect focus for autoread |
| `detach-on-destroy` | `off` | Switch to another session on kill instead of exiting |
| `renumber-windows` | `on` | Gaps close automatically after killing a window |
