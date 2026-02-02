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

# Backup and link a config file or directory
# Usage: link_config <source> <destination>
link_config() {
    local src="$1"
    local dst="$2"

    # Check if source exists (file or directory)
    if [[ ! -e "$src" ]]; then
        print_warning "Source not found: $src (skipping)"
        return 1
    fi

    # Backup existing file/directory if it exists and is not a symlink
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        local backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $dst to $backup"
        mv "$dst" "$backup"
    elif [[ -L "$dst" ]]; then
        # Remove existing symlink
        rm "$dst"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    # Create symlink (-n prevents following existing symlink, -f forces)
    ln -sfn "$src" "$dst"
    print_success "Linked $dst -> $src"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "mac" ;;
        *)       echo "unknown" ;;
    esac
}

# Run command with sudo if available, otherwise without
maybe_sudo() {
    if command_exists sudo; then
        sudo "$@"
    else
        "$@"
    fi
}

# Install a package using the appropriate package manager
install_package() {
    local pkg="$1"
    local os=$(detect_os)

    if [[ "$os" == "linux" ]]; then
        if command_exists apt-get; then
            maybe_sudo apt-get update && maybe_sudo apt-get install -y "$pkg"
        elif command_exists yum; then
            maybe_sudo yum install -y "$pkg"
        elif command_exists dnf; then
            maybe_sudo dnf install -y "$pkg"
        elif command_exists pacman; then
            maybe_sudo pacman -S --noconfirm "$pkg"
        else
            print_error "Could not detect package manager. Please install $pkg manually."
            return 1
        fi
    elif [[ "$os" == "mac" ]]; then
        if command_exists brew; then
            brew install "$pkg"
        else
            print_error "Homebrew not found. Please install $pkg manually."
            return 1
        fi
    else
        print_error "Unsupported OS. Please install $pkg manually."
        return 1
    fi
}

# Install zsh if not present
install_zsh() {
    if command_exists zsh; then
        print_info "zsh already installed"
        return 0
    fi

    print_info "Installing zsh..."
    install_package zsh && print_success "zsh installed"
}

# Install vim if not present
install_vim() {
    if command_exists vim; then
        print_info "vim already installed"
        return 0
    fi

    print_info "Installing vim..."
    install_package vim && print_success "vim installed"
}

# Set zsh as default shell
set_zsh_default() {
    local zsh_path=$(which zsh)
    local current_shell=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || echo "$SHELL")

    if [[ "$current_shell" == "$zsh_path" ]]; then
        print_info "zsh is already the default shell"
        return 0
    fi

    print_info "Setting zsh as default shell..."

    # Ensure zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        echo "$zsh_path" | maybe_sudo tee -a /etc/shells > /dev/null
    fi

    # Change shell
    if chsh -s "$zsh_path"; then
        print_success "zsh set as default shell (restart terminal to apply)"
    else
        print_warning "Could not change shell automatically. Run: chsh -s $zsh_path"
    fi
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
    curl -fsSL https://claude.ai/install.sh | bash
    print_success "Claude Code CLI installed"
}

# Install all zsh plugins
install_zsh_plugins() {
    install_zsh_autosuggestions
    install_zsh_syntax_highlighting
}
