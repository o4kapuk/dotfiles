#!/bin/bash
set -e

sudo apt update && apt install -y htop mc

curl -sS https://webi.sh/gh | sh

command -v opencode >/dev/null || curl -fsSL https://opencode.ai/install | bash

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
