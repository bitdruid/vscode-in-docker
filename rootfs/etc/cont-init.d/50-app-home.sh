#!/bin/sh
# The base image rewrites /etc/passwd on every start, giving 'app' home=/dev/null
# and shell=/sbin/nologin. Fix that and prepare the home directory.

set -eu

usermod -s /usr/bin/zsh -d /home/app app

mkdir -p /home/app/.vscode /home/app/.config /home/app/.local/share /home/app/.local/state /home/app/.cache

# Seed whatever is missing from /etc/skel (dotfiles, .zshrc, oh-my-zsh). Top level
# only and never overwriting, so files the user changed or deleted stay that way.
for f in /etc/skel/.[!.]* /etc/skel/*; do
    [ -e "$f" ] || continue
    [ -e "/home/app/${f##*/}" ] || cp -a "$f" /home/app/
done
# The VS Code settings live below .config, which always exists: seed separately.
[ -e /home/app/.config/Code/User/settings.json ] || {
    mkdir -p /home/app/.config/Code/User
    cp /etc/skel/.config/Code/User/settings.json /home/app/.config/Code/User/
}

# No keyring in the container: store secrets in VS Code's basic store.
printf '{"enable-crash-reporter":false,"password-store":"basic"}\n' > /home/app/.vscode/argv.json

# Only touches files whose owner doesn't match USER_ID/GROUP_ID (cheap on restart).
take-ownership /home/app
