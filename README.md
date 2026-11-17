# desktop-tools

My Niri desktop setup: floating fuzzy launchers, lock screen and screensaver.

| Path | Installed to | What |
|---|---|---|
| `bin/file-search` | `~/.local/bin` | Floating fuzzy file finder (`Mod+/`). Type `pdf:name`, `img:`, `dir:` … to filter by kind. |
| `bin/app-search` | `~/.local/bin` | Floating fuzzy app launcher (`Mod+Y`) |
| `bin/lock`, `bin/screensaver` | `~/.local/bin` | Quickshell lock screen (`Mod+'`) and screensaver |
| `bin/niri-run-or-raise`, `bin/toggle-ai` | `~/.local/bin` | Focus-or-launch, scratchpad helpers |
| `quickshell/*` | `~/.config/quickshell/` | Lock + screensaver QML |
| `tmux/*` | `~/.config/tmux/` | tmux config, guide, sessionizer |

Needs: `fzf`, `fd`, `kitty`, `niri`, `quickshell`, `tmux`, `wl-clipboard`, `python3`.

## Install
    git clone <url> ~/.local/src/desktop-tools
    ~/.local/src/desktop-tools/install.sh

Files are symlinked, so edit them here (or via their installed path — same file) and commit.
`docs/CHANGES.md` is the running change log.
