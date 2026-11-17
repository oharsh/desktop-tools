#!/usr/bin/env bash
# install.sh — symlink this repo's files into place. Safe to re-run.
# Existing real files are moved to <target>.pre-repo once, never overwritten.
set -euo pipefail
repo=$(cd "$(dirname "$(realpath "$0")")" && pwd)
bin=$HOME/.local/bin cfg=${XDG_CONFIG_HOME:-$HOME/.config}

link() {   # link <repo-relative source> <target>
  local src=$repo/$1 dst=$2
  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst && ! -L $dst && ! -e $dst.pre-repo ]]; then mv "$dst" "$dst.pre-repo"; fi
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

for f in file-search app-search lock screensaver niri-run-or-raise toggle-ai toggle-scratchpad; do
  link "bin/$f" "$bin/$f"
done
link quickshell/lock "$cfg/quickshell/lock"
link quickshell/screensaver "$cfg/quickshell/screensaver"
link tmux/tmux.conf "$cfg/tmux/tmux.conf"
link tmux/GUIDE.md "$cfg/tmux/GUIDE.md"
link tmux/scripts "$cfg/tmux/scripts"
