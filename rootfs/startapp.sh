#!/bin/sh

set -eu

export HOME=/home/app
export SHELL=/usr/bin/zsh

mkdir -p "${XDG_RUNTIME_DIR:-/tmp/run/user/app}"

# Stale locks/sockets from an unclean shutdown prevent VS Code from starting.
rm -f "${XDG_CONFIG_HOME:-$HOME/.config}/Code/code.lock" /tmp/vscode-ipc-*.sock

cd "$HOME"

# Run Electron directly (the `code` wrapper detaches, which the supervisor would
# treat as an exit). Without a folder argument VS Code restores the last session,
# and new terminals / file dialogs start in $HOME. Set VSCODE_OPEN to force a folder.
exec /usr/share/code/code \
    --no-sandbox \
    --disable-dev-shm-usage \
    ${VSCODE_OPEN:+--new-window "$VSCODE_OPEN"}
