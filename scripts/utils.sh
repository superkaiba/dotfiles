#!/bin/bash
# Utility functions for dotfiles setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Backup and link a config file
# Usage: link_config <source> <destination>
link_config() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "$src" ]]; then
        print_warning "Source file not found: $src (skipping)"
        return 1
    fi

    # Backup existing file if it exists and is not a symlink
    if [[ -f "$dst" ]] && [[ ! -L "$dst" ]]; then
        local backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $dst to $backup"
        mv "$dst" "$backup"
    elif [[ -L "$dst" ]]; then
        # Remove existing symlink
        rm "$dst"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    # Create symlink
    ln -sf "$src" "$dst"
    print_success "Linked $dst -> $src"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Install oh-my-zsh if not present
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_info "oh-my-zsh already installed"
        return 0
    fi

    print_info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh installed"
}

# Install zsh-autosuggestions plugin
install_zsh_autosuggestions() {
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    if [[ -d "$plugin_dir" ]]; then
        print_info "zsh-autosuggestions already installed"
        return 0
    fi

    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
    print_success "zsh-autosuggestions installed"
}

# Install zsh-syntax-highlighting plugin
install_zsh_syntax_highlighting() {
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    if [[ -d "$plugin_dir" ]]; then
        print_info "zsh-syntax-highlighting already installed"
        return 0
    fi

    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir"
    print_success "zsh-syntax-highlighting installed"
}

# Install Powerlevel10k theme
install_p10k() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ -d "$p10k_dir" ]]; then
        print_info "Powerlevel10k already installed"
        return 0
    fi

    print_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    print_success "Powerlevel10k installed"
}

# Install Claude Code CLI
install_claude_code() {
    if command_exists claude; then
        print_info "Claude Code CLI already installed"
        return 0
    fi

    print_info "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | sh
    print_success "Claude Code CLI installed"
}

# Install all zsh plugins
install_zsh_plugins() {
    install_zsh_autosuggestions
    install_zsh_syntax_highlighting
}
