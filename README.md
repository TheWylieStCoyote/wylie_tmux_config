# tmux configuration

A tmux configuration styled to match the [Neovim](../nvim) and [Yazi](../yazi) setups — Monokai Pro (Ristretto filter), rounded borders, Nerd Font icons, and vim-style keybindings throughout.

## Requirements

- tmux ≥ 3.2
- A [Nerd Font](https://www.nerdfonts.com/) terminal font
- [tpm](https://github.com/tmux-plugins/tpm) for plugin management

## Installation

The config lives at `~/.config/tmux/tmux.conf`, which tmux reads automatically from version 3.1+.

**Install tpm** — it is a git submodule, so either clone this repo with submodules or fetch it afterwards:

```sh
git clone --recurse-submodules <this-repo> ~/.config/tmux
# or, in an existing checkout:
git submodule update --init
```

tpm lives at `~/.config/tmux/plugins/tpm`, and installs the other plugins alongside it in `plugins/` (ignored by git).

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

> **Note:** `tmux source` is a tmux command. Do not `source ~/.config/tmux/tmux.conf` from bash — bash will try to run `set`, `bind`, and `setw` as shell builtins and can break readline keys (`t`, `c`, `k`) in that shell. If that happens, open a new terminal or run `bind '"t": self-insert'` for each affected key.

## Sessions

### Named sessions

| Command | Action |
|---|---|
| `tmux new -s <name>` | Create a new session called `<name>` (fails if it already exists) |
| `tmux attach -t <name>` | Attach to an existing session |
| `tmux new -A -s <name>` | Attach if `<name>` exists, otherwise create it |
| `tmux new -s <name> -c <dir>` | Create a session whose windows start in `<dir>` |
| `tmux ls` | List running sessions |
| `tmux kill-session -t <name>` | Kill a session |

`new` is short for `new-session`. The `-A` form is the one to use in scripts and shell startup files, since it is safe to run repeatedly.

Without `-c`, the session starts in whatever directory you ran the command from. The flags combine, so the one-liner for "open or create my project session in its directory" is:

```sh
tmux new -A -s myproject -c ~/code/myproject
```

`-c` sets the session's working directory, so later windows open there too. This config's `prefix c` binding instead opens new windows at the *current pane's* path, so they follow wherever you have `cd`'d to.

### Start tmux when a terminal opens

Add this to the end of `~/.bashrc`:

```sh
if command -v tmux >/dev/null && [ -z "$TMUX" ] && [ -t 0 ] && [[ $- == *i* ]]; then
  tmux new -A -s main
fi
```

This attaches to a session named `main` if one exists, otherwise creates it. The guards skip auto-start when already inside tmux, in a non-interactive shell, or when there is no tty (e.g. some IDE terminals).

To launch a tmuxinator project instead, replace the `tmux new -A` line with `tmuxinator start <name>`.

### Restore sessions after a reboot

Handled by [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum), which is already enabled in `tmux.conf`:

- State is saved every 15 minutes (`@continuum-save-interval`)
- The last saved state is restored automatically on the first tmux start (`@continuum-restore`)
- Neovim sessions and pane contents are included via tmux-resurrect

The only requirement is that plugins are installed (`prefix + I`). Use `prefix C-s` / `prefix C-r` to save or restore manually.

### Start a session with predefined windows

**Option 1 — tmuxinator (recommended).** Create a layout file per project:

```sh
tmuxinator new myproject
```

This opens `~/.config/tmuxinator/myproject.yml`. Each entry under `windows` is a window; each pane runs the listed command on startup, and `""` gives a plain shell:

```yaml
name: myproject
root: ~/code/myproject

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim .
        - ""
  - git:
      panes:
        - lazygit
  - shell:
      panes:
        - ""
```

Start it with `tmuxinator start myproject`, or pick it from inside tmux with `prefix M`. Tmuxinator attaches to the session if it is already running, so it is safe to use as the terminal auto-start command above:

```sh
if command -v tmux >/dev/null && [ -z "$TMUX" ] && [ -t 0 ] && [[ $- == *i* ]]; then
  tmuxinator start myproject
fi
```

See the [Tmuxinator](#tmuxinator) section below for installation and more commands.

**Option 2 — plain tmux, no extra tool.** The same layout scripted directly, e.g. in `~/.bashrc` or a standalone script:

```sh
if ! tmux has-session -t main 2>/dev/null; then
  tmux new-session -d -s main -n editor -c ~/code/myproject 'nvim .'
  tmux new-window -t main -n git -c ~/code/myproject 'lazygit'
  tmux new-window -t main -n shell -c ~/code/myproject
  tmux select-window -t main:editor
fi
tmux attach -t main
```

Fine for a single fixed layout, but gets verbose compared with the YAML. For a full reusable script with splits, a venv, and a generic launcher that takes a project path, see [docs/sessions-without-tmuxinator.md](docs/sessions-without-tmuxinator.md).

> **Note:** tmux-continuum also restores the last saved session on first start. If you use a scripted layout as your default, set `@continuum-restore 'off'` in `tmux.conf`, otherwise you get the restored session **and** the scripted one.

### Activate a Python venv on session start

**With tmuxinator**, use `pre_window`. It runs in every pane before that pane's own command, so the whole session starts with the venv active (including Neovim, so language servers pick up the right interpreter):

```yaml
name: myproject
root: ~/code/myproject
pre_window: source .venv/bin/activate

windows:
  - editor:
      panes:
        - nvim .
  - shell:
      panes:
        - ""
```

The path is relative to `root`; an absolute path such as `~/.venvs/myproject/bin/activate` also works. To activate only in specific panes, skip `pre_window` and chain it into the pane command instead:

```yaml
  - shell:
      panes:
        - source .venv/bin/activate && python manage.py runserver
```

**With plain tmux**, create the window with a normal shell and type the activation into it with `send-keys`:

```sh
tmux new-session -d -s main -n shell -c ~/code/myproject
tmux send-keys -t main:shell 'source .venv/bin/activate' Enter
tmux attach -t main
```

> **Note:** do not pass `source .venv/bin/activate` as the window's startup command (`tmux new-session ... 'source .venv/bin/activate'`). tmux runs that command *instead of* a shell, so the window closes as soon as it finishes.

## Plugins

| Plugin                                                                  | Purpose                                                                      |
| ----------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)        | Save and restore sessions across reboots                                     |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)        | Auto-save resurrect state every 15 minutes                                   |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless `C-h/j/k/l` navigation between Neovim splits and tmux panes         |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank)                  | Robust system clipboard integration in copy mode                             |
| [tmux-fzf](https://github.com/sainnhe/tmux-fzf)                         | Fuzzy-find sessions, windows, panes, and commands                            |
| [tmux-fingers](https://github.com/Morantron/tmux-fingers)               | Hint mode for copying paths, URLs, and git hashes without entering copy mode |

> **vim-tmux-navigator** requires a matching Neovim plugin. The [Neovim config](../nvim) loads it from `lua/plugins/tmux-navigator.lua`.

## Theme

Colors are taken directly from the **Monokai Pro — Ristretto** palette used in the Neovim config.

| Role                        | Color     |
| --------------------------- | --------- |
| Session pill (purple)       | `#a8a9eb` |
| Active window (yellow)      | `#f9cc6c` |
| Pane border active (blue)   | `#85dacc` |
| Time (blue)                 | `#85dacc` |
| Date (green)                | `#adda78` |
| Inactive / dimmed (grey)    | `#948a8b` |
| Highlight / search (yellow) | `#f9cc6c` |
| Message (yellow)            | `#f9cc6c` |
| Warning (orange)            | `#f38d70` |

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

| Key        | Action                          |
| ---------- | ------------------------------- |
| `C-a`      | Prefix (replaces default `C-b`) |
| `prefix r` | Reload config                   |

### Panes

| Key              | Action                                                              |
| ---------------- | ------------------------------------------------------------------- |
| `prefix \|`      | Split horizontal (preserves cwd)                                    |
| `prefix -`       | Split vertical (preserves cwd)                                      |
| `C-h/j/k/l`      | Navigate panes **or** Neovim splits (vim-tmux-navigator, no prefix) |
| `prefix h/j/k/l` | Navigate panes (prefix fallback)                                    |
| `prefix H/J/K/L` | Resize pane (repeatable, 5 cells)                                   |
| `prefix C-l`     | Clear screen (restored — vim-tmux-navigator claims bare `C-l`)      |
| `prefix x`       | Kill pane                                                           |

### Windows

| Key                     | Action                     |
| ----------------------- | -------------------------- |
| `prefix c`              | New window (preserves cwd) |
| `prefix [` / `prefix ]` | Previous / next window     |
| `prefix Tab`            | Last window                |
| `prefix X`              | Kill window                |

### Sessions

| Key        | Action                      |
| ---------- | --------------------------- |
| `prefix s` | Session/window tree picker  |
| `prefix n` | New session                 |
| `prefix Q` | Kill session (with confirm) |

### Utilities

| Key          | Action                                                 |
| ------------ | ------------------------------------------------------ |
| `prefix ?`   | Help popup — fuzzy-searchable keybinding reference     |
| `prefix t`   | Popup terminal (80% × 75%, at cwd)                     |
| `prefix M`   | Tmuxinator session picker (fzf)                        |
| `prefix C-f` | tmux-fzf launcher (sessions, windows, panes, commands) |
| `prefix F`   | tmux-fingers hint mode (copy paths, URLs, hashes)      |
| `prefix C-s` | Save session (tmux-resurrect)                          |
| `prefix C-r` | Restore session (tmux-resurrect)                       |

### Copy Mode (vi)

Enter copy mode with `prefix Enter` (`prefix [` is rebound to previous window).

| Key           | Action                                        |
| ------------- | --------------------------------------------- |
| `v`           | Begin selection                               |
| `C-v`         | Toggle rectangle selection                    |
| `y`           | Yank to system clipboard and exit (tmux-yank) |
| `Y`           | Yank current line to clipboard (tmux-yank)    |
| `Escape`      | Cancel                                        |
| `C-d` / `C-u` | Half-page down / up                           |
| `H` / `L`     | Start / end of line                           |
| `/` / `?`     | Search forward / backward                     |
| `n` / `N`     | Next / previous match                         |

## Tmuxinator

[Tmuxinator](https://github.com/tmuxinator/tmuxinator) manages named session layouts defined as YAML files in `~/.config/tmuxinator/`.

**Install:**

```sh
gem install tmuxinator
```

**Common commands:**

| Command                   | Action                                     |
| ------------------------- | ------------------------------------------ |
| `tmuxinator start <name>` | Start a session                            |
| `tmuxinator stop <name>`  | Stop a session                             |
| `tmuxinator new <name>`   | Create a new session config                |
| `tmuxinator edit <name>`  | Edit an existing config                    |
| `tmuxinator list`         | List all session configs                   |
| `prefix M`                | fzf picker to start any tmuxinator session |

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

| Setting             | Value     | Notes                                                |
| ------------------- | --------- | ---------------------------------------------------- |
| `prefix`            | `C-a`     | Ergonomic alternative to `C-b`                       |
| `base-index`        | `1`       | Windows and panes start at 1                         |
| `escape-time`       | `0`       | No delay for Escape (important for Neovim)           |
| `mouse`             | `on`      | Click to focus, scroll to scroll                     |
| `history-limit`     | `1000000` | Scrollback lines                                     |
| `mode-keys`         | `vi`      | Copy mode uses vim bindings                          |
| `focus-events`      | `on`      | Lets Neovim detect focus for autoread                |
| `detach-on-destroy` | `off`     | Switch to another session on kill instead of exiting |
| `renumber-windows`  | `on`      | Gaps close automatically after killing a window      |
| `allow-passthrough` | `on`      | Lets yazi/kitty/sixel image previews render inside tmux |
