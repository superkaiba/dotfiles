# Common aliases - loaded on all clusters

# Git shortcuts
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gl='git log --oneline -20'
alias glog='git log --graph --oneline --decorate'

# Navigation
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tmux
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# Python
alias py='python'
alias py3='python3'
alias pip='pip3'
alias venv='python -m venv'
alias activate='source venv/bin/activate'

# Quick edits
alias zshrc='$EDITOR ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias tmuxconf='$EDITOR ~/.tmux.conf'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Disk usage
alias df='df -h'
alias du='du -h'
alias dud='du -d 1 -h'

# Process management
alias psg='ps aux | grep -v grep | grep -i'

# Network
alias myip='curl -s ifconfig.me'

# Misc
alias c='clear'
alias h='history'
alias reload='source ~/.zshrc'
