#!/bin/zsh
export TERM=xterm-256color
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export DOTFILES=$HOME/src/dotfiles
ZSH_INIT_PATH=$DOTFILES/zsh

# find source path for symlink ~/.zshrc if it exists
if [[ -L $HOME/.zshrc ]]; then
    ZSH_INIT_PATH=$(dirname $(readlink $HOME/.zshrc))
fi

# Linuxbrew (no-op on macOS / non-linuxbrew machines)
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

source $ZSH_INIT_PATH/zsh/top-level.rc
export PATH="/opt/homebrew/anaconda3/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<Eq

