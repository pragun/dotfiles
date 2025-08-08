
tmux-config(){
  lvim ~/.tmux.conf ~/.tmux/tmux-modal-keybindings.conf
}

bash-config(){
  lvim ~/.bashrc
}

kitty-config(){
  lvim ~/.config/kitty/kitty.conf
}

lvim-config(){
  lvim ~/.config/lvim/config.lua
}


gdiff() {
  preview="git diff $@ --color=always -- {-1}"
  git diff $@ --name-only | fzf -m --ansi --preview "$preview"
}


export PATH=$PATH:~/.local/nvim-linux64/bin
export PATH=$PATH:~/.local/git-fuzzy/bin
export PATH=$PATH:~/.local/fd-v10.1.0-x86_64-unknown-linux-gnu
export PATH=$PATH:~/.local/bat-v0.24.0-x86_64-unknown-linux-gnu
export PATH=$PATH:~/.local/nu-0.93.0-x86_64-linux-gnu-full
export PATH=$PATH:~/.local/atuin-v18.2.0-x86_64-unknown-linux-gnu
export PATH=~/.local/bin:$PATH
export PATH=$PATH:$(go env GOPATH)/bin
export PATH=$PATH:/usr/local/share/dotnet/

source ~/.local/bin/fzf-git.sh
eval "$(fzf --bash)"
