#!/bin/zsh

export DOTFILES=$HOME/Projects/dotfiles
ZSH_INIT_PATH=$DOTFILES/zsh

# find source path for symlink ~/.zshrc if it exists
if [[ -L $HOME/.zshrc ]]; then
    ZSH_INIT_PATH=$(dirname $(readlink $HOME/.zshrc))
fi

source $ZSH_INIT_PATH/zsh/top-level.rc
