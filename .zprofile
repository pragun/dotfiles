#!/bin/zsh
# Loaded before .zshrc for login shells. Right place for PATH/env that the rest
# of shell init depends on — most importantly, brew's shellenv.

# macOS Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# macOS Homebrew (Intel) — kept for completeness, harmless on AS machines
if [[ -x /usr/local/Homebrew/bin/brew ]]; then
    eval "$(/usr/local/Homebrew/bin/brew shellenv)"
fi

# Linuxbrew
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Linuxbrew — single-user install path (used on boxes without sudo)
if [[ -x $HOME/.linuxbrew/bin/brew ]]; then
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi
