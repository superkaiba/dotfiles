# Dotfiles ZSH Configuration
# Auto-loads cluster-specific settings

# Path to dotfiles
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Detect cluster (if not already set)
if [[ -z "$DOTFILES_CLUSTER" ]]; then
    source "$DOTFILES_DIR/scripts/detect_cluster.sh"
    export DOTFILES_CLUSTER=$(detect_cluster)
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    kubectl
    tmux
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k config if it exists
[[ -f "$DOTFILES_DIR/config/zsh/p10k.zsh" ]] && source "$DOTFILES_DIR/config/zsh/p10k.zsh"

# Load common aliases
[[ -f "$DOTFILES_DIR/config/zsh/aliases.sh" ]] && source "$DOTFILES_DIR/config/zsh/aliases.sh"

# Load cluster-specific environment
if [[ -f "$DOTFILES_DIR/clusters/$DOTFILES_CLUSTER/env.sh" ]]; then
    source "$DOTFILES_DIR/clusters/$DOTFILES_CLUSTER/env.sh"
fi

# Load cluster-specific aliases
if [[ -f "$DOTFILES_DIR/clusters/$DOTFILES_CLUSTER/aliases.sh" ]]; then
    source "$DOTFILES_DIR/clusters/$DOTFILES_CLUSTER/aliases.sh"
fi

# User configuration
export EDITOR='vim'
export VISUAL='vim'

# History configuration
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Better directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Completion
autoload -Uz compinit && compinit

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
