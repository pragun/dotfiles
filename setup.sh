#!/bin/bash
# Setup for this dotfiles repo. Idempotent — safe to re-run.
# Supports macOS and Linux (apt or dnf — auto-detected).

set -euo pipefail

case "$OSTYPE" in
  darwin*)
    # macOS: brew handles everything including the wezterm cask.
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    brew install --cask wezterm
    brew install gawk grep  # GNU versions for fzf-tab-completion
    ;;

  linux*)
    # Linux: system package manager for zsh/wezterm/build deps, linuxbrew for the rest.
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y zsh curl git build-essential procps file
        if ! command -v wezterm &> /dev/null; then
            curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" | sudo tee /etc/apt/sources.list.d/wezterm.list
            sudo apt update
            sudo apt install -y wezterm
        fi
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zsh curl git gcc make file procps-ng
        if ! command -v wezterm &> /dev/null; then
            sudo dnf copr enable -y wezfurlong/wezterm-nightly
            sudo dnf install -y wezterm
        fi
    else
        echo "No supported package manager found (need apt or dnf)" >&2
        exit 1
    fi

    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    ;;

  *)
    echo "Unsupported OS: $OSTYPE" >&2
    exit 1
    ;;
esac

# Shared: CLI tools via brew (works on both Mac and Linux).
brew install fzf atuin yazi lazygit lazydocker

# Shared: Oh My Zsh.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Linux-only: make zsh the login shell.
if [[ "$OSTYPE" == linux* ]] && [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

cat <<EOF

Done. Next steps:
  ln -sf "\$PWD/.zshrc"    ~/.zshrc
  ln -sf "\$PWD/.zprofile" ~/.zprofile
  Start a new shell (Linux: log out and back in for zsh as login shell).
EOF
