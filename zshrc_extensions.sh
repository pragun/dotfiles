export MITHRIL_BASE=/home/pragun/src/mithril_workspace/

tmux-config(){
  lvim ~/.tmux.conf ~/.tmux/tmux-modal-keybindings.conf
}

bash-config(){
  lvim ~/.bashrc
}

zsh-config(){
  lvim ~/dotfiles/zshrc_extensions.sh ~/.zshrc
}

kitty-config(){
  lvim ~/.config/kitty/kitty.conf
}

lvim-config(){
  lvim ~/.config/lvim/config.lua
}

dotfiles-config(){
  lvim ~/dotfiles
}



export PATH=$PATH:~/.local/nvim-linux64/bin
export PATH=$PATH:~/.local/git-fuzzy/bin
export PATH=$PATH:~/.local/fd-v10.1.0-x86_64-unknown-linux-gnu
export PATH=$PATH:~/.local/bat-v0.24.0-x86_64-unknown-linux-gnu
export PATH=$PATH:~/.local/nu-0.93.0-x86_64-linux-gnu-full
export PATH=$PATH:~/.local/atuin-v18.2.0-x86_64-unknown-linux-gnu
export PATH=$PATH:~/.local/fmz
export PATH=$PATH:~/.local/broot-1.39.0/x86_64-linux
export PATH=~/.local/bin:$PATH
export PATH=$PATH:~/miniforge3/bin
export PATH=$PATH:/home/pragun/bin
export PATH=$PATH:/usr/lib/go-1.21/bin
export PATH=$PATH:$(go env GOPATH)/bin

source ~/.local/bin/fzf-git.sh

FZF_ALT_C_COMMAND= 
FZF_CTRL_T_COMMAND=
FZF_CTRL_R_COMMAND=
eval "$(fzf --zsh)"


# Remove bindings for ctrl+s, ctrl+r
bindkey -M emacs -r '^s'
bindkey -M vicmd -r '^s'
bindkey -M viins -r '^s'

bindkey -M emacs -r '^r'
bindkey -M vicmd -r '^r'
bindkey -M viins -r '^r'

# Add bindings for reverse search
bindkey -M emacs '^sr' fzf-history-widget
bindkey -M vicmd '^sr' fzf-history-widget
bindkey -M viins '^sr' fzf-history-widget

# set less mode
export LESS=FRX
## From https://stackoverflow.com/questions/69091601/git-branch-displays-my-branch-names-in-a-vim-window-instead-of-in-my-current-it

source ~/dotfiles/fzf_completions.zsh
source ~/dotfiles/fzf_keybindings.zsh
source ~/dotfiles/fzf-git.sh/fzf-git.sh
source ~/dotfiles/fzf-docker/fzf-docker.plugin.zsh
source ~/dotfiles/fzf-tab-completion/zsh/fzf-zsh-completion.sh

export FZF_COMPLETION_TRIGGER=','
export FZF_DEFAULT_COMMAND='fd --type f'
source /home/pragun/.config/broot/launcher/bash/br

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/pragun/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/pragun/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/pragun/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/pragun/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
conda deactivate 

function brg {
    br --conf ~/.config/broot/git-diff-conf.toml --git-status
}

function lg {
	lazygit
}

function kssh {
  kitten ssh $@
}

function src {
  cd ~/src
}

source ~/src/gimli-rcs/pragun.zshrc
source ~/dotfiles/docker_aliases.sh

