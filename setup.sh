#!/bin/bash
# Setup for this dotfiles repo. Idempotent — safe to re-run.
# Supports macOS and Linux (apt or dnf — auto-detected).

set -euo pipefail

# The manual steps this script does NOT do for you. Printed on completion, and
# on --help so you can look them up again without re-running the install.
next_steps() {
    cat <<'EOF'
Next steps (this script does not do these for you):

  ln -sf "$PWD/.zshrc"    ~/.zshrc
  ln -sf "$PWD/.zprofile" ~/.zprofile

  Start a new shell (Linux: log out and back in for zsh as login shell).

Both symlinks matter. ~/.zprofile is where brew's shellenv is eval'd, so
without it brew, atuin, fzf and lazygit stay off your PATH even though they
are installed.
EOF
}

usage() {
    cat <<'EOF'
Usage: ./setup.sh [--help]

Installs the dependencies for this dotfiles repo: zsh, wezterm, Oh My Zsh, and
the brew CLI tools (fzf, atuin, yazi, lazygit, lazydocker). Idempotent — safe
to re-run.

  -h, --help   Show this message and the post-install steps, then exit without
               changing anything.

EOF
    next_steps
}

case "${1-}" in
    -h|--help) usage; exit 0 ;;
    "")        ;;
    *)         echo "Unknown argument: $1" >&2; echo >&2; usage >&2; exit 1 ;;
esac

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
        sudo dnf install -y zsh curl git gcc make file procps-ng dnf-plugins-core
        if ! command -v wezterm &> /dev/null; then
            # COPR target repo name differs by distro. Fedora's autodetect works;
            # Rocky/RHEL/Alma get autodetected as epel-9 which the wezterm COPR
            # doesn't publish to — force rhel-9 instead.
            . /etc/os-release
            case "$ID" in
                rocky|rhel|almalinux) copr_repo="rhel-${VERSION_ID%%.*}-$(uname -m)" ;;
                *)                    copr_repo="" ;;
            esac
            sudo dnf copr enable -y wezfurlong/wezterm-nightly $copr_repo
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

echo
echo "Done."
echo
next_steps
