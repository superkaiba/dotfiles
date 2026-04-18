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
[[ -f "$DOTFILES_DIR/config/aliases.sh" ]] && source "$DOTFILES_DIR/config/aliases.sh"

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

# Claude Code: pin max effort at startup (settings.json env block is applied
# too late — Claude reads effort from shell env before fully merging it).
export CLAUDE_CODE_EFFORT_LEVEL=max

# Claude Code with Max (OAuth) auth — bypasses API key, remote control enabled
alias claude-max='ANTHROPIC_API_KEY="" claude --remote-control'

# Source local overrides if they exist
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
# Auto-wrap `claude` in tmux so the session survives SSH disconnects / laptop close.
# Each invocation spawns its own session named cc-<pwd>-<N> (N = lowest unused),
# so multiple concurrent claudes in the same directory coexist. Reattach with
# `tmux a -t <name>`; list with `claude-ls`.
# Already inside tmux → skip wrapping (no nested tmux).
# Bypass the wrapper with `command claude ...` or `\claude ...` if needed.
claude() {
    if [[ -n "$TMUX" ]]; then
        happy claude --model 'opus[1m]' --effort max "$@"
        return
    fi
    local base="cc-${PWD:t}"
    base="${base//[^A-Za-z0-9_-]/_}"
    local n=1
    while tmux has-session -t "${base}-${n}" 2>/dev/null; do
        ((n++))
    done
    tmux new-session -s "${base}-${n}" "happy claude --model 'opus[1m]' --effort max ${(q)@}"
}

# List running claude tmux sessions.
claude-ls() { tmux ls 2>/dev/null | grep -E '^cc-' || echo "no running claude sessions"; }
