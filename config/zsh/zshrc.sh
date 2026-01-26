# Dotfiles ZSH Configuration
# Auto-loads cluster-specific settings

# Enable Powerlevel10k instant prompt (should stay at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Auto-detect dotfiles location
if [[ -d "$HOME/.dotfiles" ]]; then
    export DOTFILES_DIR="$HOME/.dotfiles"
elif [[ -d "$HOME/dotfiles" ]]; then
    export DOTFILES_DIR="$HOME/dotfiles"
else
    export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
fi

# Detect cluster (if not already set)
if [[ -z "$DOTFILES_CLUSTER" ]]; then
    if [[ -f "$DOTFILES_DIR/scripts/detect_cluster.sh" ]]; then
        source "$DOTFILES_DIR/scripts/detect_cluster.sh"
        export DOTFILES_CLUSTER=$(detect_cluster)
    else
        # Inline detection fallback
        if [[ "$HOSTNAME" == *".server.mila.quebec"* ]] || [[ -d "/network/projects" ]]; then
            export DOTFILES_CLUSTER="mila"
        elif [[ -d "/cvmfs/soft.computecanada.ca" ]] || [[ -n "$CC_CLUSTER" ]]; then
            export DOTFILES_CLUSTER="computecanada"
        elif [[ -n "$HYPERBOLIC_API_KEY" ]]; then
            export DOTFILES_CLUSTER="hyperbolic"
        elif [[ -d "/runpod-volume" ]] || [[ -n "$RUNPOD_POD_ID" ]]; then
            export DOTFILES_CLUSTER="runpod"
        else
            export DOTFILES_CLUSTER="local"
        fi
    fi
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins - only include installed ones
plugins=(git)

# Add optional plugins if installed
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)

# Load oh-my-zsh
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Load Powerlevel10k config if it exists
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Load common aliases
[[ -f "$DOTFILES_DIR/config/zsh/aliases.sh" ]] && source "$DOTFILES_DIR/config/zsh/aliases.sh"

# Load cluster-specific environment
[[ -f "$DOTFILES_DIR/clusters/$DOTFILES_CLUSTER/env.sh" ]] && source "$DOTFILES_DIR/clusters/$DOTFILES_CLUSTER/env.sh"

# Load cluster-specific aliases
[[ -f "$DOTFILES_DIR/clusters/$DOTFILES_CLUSTER/aliases.sh" ]] && source "$DOTFILES_DIR/clusters/$DOTFILES_CLUSTER/aliases.sh"

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

# Source local overrides if they exist
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
