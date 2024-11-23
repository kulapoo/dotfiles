#!/usr/bin/env bash

export BASH_IT="$HOME/.bash_it"


source "$BASH_IT/bash_it.sh"

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Load SSH agent if not already running
if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval "$(ssh-agent -s)"
fi

# Load any SSH keys if not already loaded
if [ -f "$HOME/.ssh/id_rsa" ]; then
    if ! ssh-add -l >/dev/null 2>&1; then
        ssh-add "$HOME/.ssh/id_rsa" >/dev/null 2>&1
    fi
fi

# Load custom profile extensions if they exist
if [ -d "$HOME/.profile.d" ]; then
    for file in "$HOME"/.profile.d/*.sh; do
        if [ -r "$file" ]; then
            source "$file"
        fi
    done
fi


. "$HOME/.cargo/env"
