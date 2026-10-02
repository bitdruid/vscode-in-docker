#!/bin/sh
# Update VS Code before it starts. Never blocks startup: on
# failure the installed version is used.

set -u

if is-bool-val-false "${AUTO_UPDATE:-1}"; then
    echo "Auto-update disabled."
    exit 0
fi

timeout 600 vscode-update || echo "VS Code auto-update failed, starting installed version."
exit 0
