#!/bin/bash
# Main setup script for dotfiles
# Auto-detects cluster and configures environment

set -e

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
source "$DOTFILES_DIR/scripts/utils.sh"
source "$DOTFILES_DIR/scripts/detect_cluster.sh"

# Detect which cluster we're on
CLUSTER=$(detect_cluster)
print_info "Detected cluster: $CLUSTER"

echo ""
echo "========================================="
echo "  Dotfiles Setup"
echo "  Cluster: $CLUSTER"
echo "  Location: $DOTFILES_DIR"
echo "========================================="
echo ""

# Phase 1: Install dependencies
print_info "Installing dependencies..."

# Install zsh first (required for oh-my-zsh)
install_zsh

# Install oh-my-zsh
install_oh_my_zsh

# Install zsh plugins
install_zsh_plugins

# Install Powerlevel10k
install_p10k

# Install Claude Code CLI
install_claude_code

echo ""

# Phase 2: Link configuration files
print_info "Linking configuration files..."

# Zsh configuration
link_config "$DOTFILES_DIR/config/zsh/zshrc.sh" "$HOME/.zshrc"

# Vim configuration
link_config "$DOTFILES_DIR/config/vim/vimrc" "$HOME/.vimrc"

# Tmux configuration
link_config "$DOTFILES_DIR/config/tmux/tmux.conf" "$HOME/.tmux.conf"

# Powerlevel10k configuration
link_config "$DOTFILES_DIR/config/zsh/p10k.zsh" "$HOME/.p10k.zsh"

# Git configuration (skip if user has their own)
if [[ ! -f "$HOME/.gitconfig" ]] || [[ -L "$HOME/.gitconfig" ]]; then
    link_config "$DOTFILES_DIR/config/git/gitconfig" "$HOME/.gitconfig"
else
    print_warning "Keeping existing ~/.gitconfig (not a symlink)"
fi

echo ""

# Phase 3: Apply cluster-specific configuration
if [[ -d "$DOTFILES_DIR/clusters/$CLUSTER" ]]; then
    print_info "Applying $CLUSTER-specific configuration..."

    # Source cluster env if it exists (for immediate effect)
    if [[ -f "$DOTFILES_DIR/clusters/$CLUSTER/env.sh" ]]; then
        source "$DOTFILES_DIR/clusters/$CLUSTER/env.sh"
    fi
fi

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
print_success "Dotfiles configured for: $CLUSTER"
print_info "Start a new zsh shell: exec zsh"
echo ""
