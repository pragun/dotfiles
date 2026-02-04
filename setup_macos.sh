#!/bin/bash

# macOS setup script for dotfiles
# This script installs necessary packages via Homebrew

set -e  # Exit on any error

echo "🍺 Installing Homebrew packages..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Install packages
echo "📦 Installing terminal and utilities..."
brew install --cask wezterm
brew install atuin

echo "📦 Installing fzf tab completion dependencies..."
# These packages are required for fzf-tab-completion to work properly
brew install fzf    # Fuzzy finder
brew install gawk   # GNU awk (needed for fzf-tab-completion)
brew install grep   # GNU grep (provides ggrep, needed for fzf-tab-completion)

echo "🎨 Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ""
else
    echo "   Oh My Zsh already installed, skipping..."
fi

echo "✅ All packages installed successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Symlink your .zshrc: ln -sf \$PWD/.zshrc ~/.zshrc"
echo "   2. Source your new config: source ~/.zshrc"
echo "   3. Initialize atuin: atuin init"
echo "   4. Test fzf tab completion by typing 'ls ' and pressing Tab"