#!/bin/bash
set -e

sudo apt update && sudo apt install -y htop mc tmux stow

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Deploy configs with stow. A pre-existing plain file is moved to .bak,
# otherwise stow would fail on the conflict.
for pkg_dir in "$DOTFILES_DIR"/*/; do
    pkg="$(basename "$pkg_dir")"
    while IFS= read -r -d '' src; do
        target="$HOME/${src#"$DOTFILES_DIR/$pkg/"}"
        mkdir -p "$(dirname "$target")"
        # Anything already there that isn't our own link gets moved aside
        # (numbered backups: .bak, .bak.~1~, ... never overwrite an old one).
        if { [ -e "$target" ] || [ -L "$target" ]; } &&
           [ "$(readlink -f "$target")" != "$(readlink -f "$src")" ]; then
            mv --backup=numbered "$target" "$target.bak"
        fi
    done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)
    stow --no-folding -d "$DOTFILES_DIR" -t "$HOME" -R "$pkg"
done

command -v gh >/dev/null || curl -sS https://webi.sh/gh | sh
command -v opencode >/dev/null || curl -fsSL https://opencode.ai/install | bash
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash
command -v codex >/dev/null || curl -fsSL https://chatgpt.com/codex/install.sh | sh
command -v t3 >/dev/null || curl -fsSL https://t3.codes/install.sh | sh

if [ -d /workspaces ]; then
    OPENCODE_DATA="$HOME/.local/share/opencode"
    OPENCODE_PERSISTENT="/workspaces/.opencode"

    if [ ! -L "$OPENCODE_DATA" ]; then
        mkdir -p "$OPENCODE_PERSISTENT"
        mkdir -p "$(dirname "$OPENCODE_DATA")"

        if [ ! -e "$OPENCODE_DATA" ]; then
            ln -s "$OPENCODE_PERSISTENT" "$OPENCODE_DATA"
        fi
    fi
fi

if ! pgrep -f '[o]pencode serve' >/dev/null; then
    setsid -f ~/.opencode/bin/opencode serve </dev/null >/dev/null 2>&1
fi

if ! pgrep -f 't3 serve' >/dev/null; then
    setsid -f ~/.local/bin/t3 serve </dev/null >/dev/null 2>&1
fi
