#!/bin/bash

# Install the following using brew:
brew install aider
brew install eza bat tree
brew install dust
brew install fd fzf ripgrep
brew install git git-delta lazygit
brew install neovim luarocks tree-sitter-cli
brew install stow
brew install wezterm tmux
brew install zsh zsh-completions
brew install gs

# Install zsh-autosuggestions & zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
