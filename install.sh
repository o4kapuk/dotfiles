#!/bin/bash
set -e

sudo apt update && sudo apt install -y htop mc tmux

curl -sS https://webi.sh/gh | sh

command -v opencode >/dev/null || curl -fsSL https://opencode.ai/install | bash
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash

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

command -v openspec >/dev/null && openspec init --tools claude,opencode,agents --no-animation

if ! pgrep -f '[o]pencode web' >/dev/null; then
    setsid -f ~/.opencode/bin/opencode web </dev/null >/dev/null 2>&1
fi
