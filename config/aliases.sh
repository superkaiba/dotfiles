# -------------------------------------------------------------------
# personal
# -------------------------------------------------------------------

alias cdg="cd ~/git"
alias zrc="cd $DOT_DIR/zsh"
alias dot="cd $DOT_DIR"
alias jp="jupyter lab"
alias hn="hostname"

# -------------------------------------------------------------------
# general
# -------------------------------------------------------------------

alias cl="clear"

# file and directories
alias rm='rm -i'
alias rmd='rm -rf'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# find/read files
alias h='head'
alias t='tail'
# alias rl="readlink -f"
alias fd='find . -type d -name'
alias ff='find . -type f -name'
alias which='type -a'

# storage
alias du='du -kh' # file space
alias df='df -kTh' # disk space
alias usage='du -sh * 2>/dev/null | sort -rh'
alias dus='du -sckx * | sort -nr'

# add to path
function add_to_path() {
    p=$1
    if [[ "$PATH" != *"$p"* ]]; then
      export PATH="$p:$PATH"
    fi
}

#
#-------------------------------------------------------------
# cd
#-------------------------------------------------------------

alias c='cd'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'
alias /='cd /'

alias d='dirs -v'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'


#-------------------------------------------------------------
# git
#-------------------------------------------------------------

alias g="git"
alias gcl="git clone"
alias ga="git add"
alias gaa="git add ."
alias gau="git add -u"
alias gc="git commit -m"
alias gp="git push"
alias gpf="git push -f"
alias gpo='git push origin $(git_current_branch)'
alias gpp='git push --set-upstream origin $(git_current_branch)'

alias gg='git gui'
alias glog='git log --oneline --all --graph --decorate'

alias gf="git fetch"
alias gl="git pull"

alias grb="git rebase"
alias grbm="git rebase master"
alias grbc="git rebase --continue"
alias grbs="git rebase --skip"
alias grba="git rebase --abort"

alias gd="git diff"
alias gdt="git difftool"
alias gs="git status"

alias gco="git checkout"
alias gcb="git checkout -b"
alias gcm="git checkout master"

alias grhead="git reset HEAD^"
alias grhard="git fetch origin && git reset --hard"

alias gst="git stash"
alias gstp="git stash pop"
alias gsta="git stash apply"
alias gstd="git stash drop"
alias gstc="git stash clear"

alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias gpsup='git push --set-upstream origin $(git_current_branch)'

#-------------------------------------------------------------
# tmux
#-------------------------------------------------------------

alias ta="tmux attach"
alias taa="tmux attach -t"
alias tad="tmux attach -d -t"
alias td="tmux detach"
alias ts="tmux new-session -s"
alias tl="tmux list-sessions"
alias tkill="tmux kill-server"
alias tdel="tmux kill-session -t"

#-------------------------------------------------------------
# ls
#-------------------------------------------------------------

alias l="ls -CF --color=auto"
alias ll="ls -l --group-directories-first"
alias la='ls -Al'         # show hidden files
alias lx='ls -lXB'        # sort by extension
alias lk='ls -lSr'        # sort by size, biggest last
alias lc='ls -ltcr'       # sort by and show change time, most recent last
alias lu='ls -ltur'       # sort by and show access time, most recent last
alias lt='ls -ltr'        # sort by date, most recent last
alias lm='ls -al |more'   # pipe through 'more'
alias lr='ls -lR'         # recursive ls
alias tree='tree -Csu'    # nice alternative to 'recursive ls'

#-------------------------------------------------------------
# chmod
#-------------------------------------------------------------

chw () {
  if [ "$#" -eq 1 ]; then
    chmod a+w $1
  else
    echo "Usage: chw <dir>" >&2
  fi
}
chx () {
  if [ "$#" -eq 1 ]; then
    chmod a+x $1
  else
    echo "Usage: chx <dir>" >&2
  fi
}

#-------------------------------------------------------------
# env
#-------------------------------------------------------------
alias sv="source .venv/bin/activate"
alias de="deactivate"
alias ma="micromamba activate"
alias md="micromamba deactivate"

# -------------------------------------------------------------------
# Slurm
# -------------------------------------------------------------------
alias q='squeue -o "%.18i %.9P %.8j %.8u %.2t %.10M %.6D %N %.10b"'
alias qw='watch squeue -o "%.18i %.9P %.8j %.8u %.2t %.10M %.6D %N %.10b"'
alias qq='squeue -u $(whoami) -o "%.18i %.9P %.8j %.8u %.2t %.10M %.6D %N %.10b"'
alias qtop='scontrol top'
alias qdel='scancel'
alias qnode='sinfo -Ne --Format=NodeHost,CPUsState,Gres,GresUsed'
alias qinfo='sinfo'
alias qhost='scontrol show nodes'
# Submit a quick GPU test job
alias qtest='sbatch --gres=gpu:1 --wrap="hostname; nvidia-smi"'
alias qlogin='srun --gres=gpu:1 --pty $SHELL'
# Cancel all your queued jobs
alias qclear='scancel -u $(whoami)'
# Functions to submit quick jobs with varying GPUs
# Usage: qrun 4 script.sh → submits 'script.sh' with 4 GPUs
qrun() {
  sbatch --gres=gpu:"$1" "$2"
}

#-------------------------------------------------------------
# claude code
#-------------------------------------------------------------

# Run claude with --dangerously-skip-permissions via a non-root user.
# Claude Code refuses this flag as root, so we create a dedicated
# unprivileged user and run through it.
cclaude() {
  local user="claudeuser"

  # Create non-root user on first use
  if ! id "$user" &>/dev/null; then
    useradd -m -s /bin/bash "$user"
    echo "Created non-root user: $user"
  fi

  # Resolve the real claude binary path
  local claude_real
  claude_real=$(readlink -f "$(command -v claude 2>/dev/null)")
  if [[ -z "$claude_real" || ! -f "$claude_real" ]]; then
    echo "Error: claude binary not found" >&2
    return 1
  fi

  # Symlink to /usr/local/bin so the non-root user can find it
  ln -sf "$claude_real" /usr/local/bin/claude

  # Make both binary path and working directory traversable
  local cwd dir
  cwd=$(pwd)
  for start_dir in "$(dirname "$claude_real")" "$cwd"; do
    dir="$start_dir"
    while [[ "$dir" != "/" ]]; do
      chmod o+x "$dir" 2>/dev/null
      dir=$(dirname "$dir")
    done
  done

  # Grant read/write access to working directory contents
  if command -v setfacl &>/dev/null; then
    setfacl -R -m "u:${user}:rwX" -m "d:u:${user}:rwX" "$cwd" 2>/dev/null
  else
    chmod -R o+rwX "$cwd"
  fi

  # Copy claude settings to non-root user (first time only)
  local user_home="/home/$user"
  if [[ ! -f "$user_home/.claude/settings.json" ]] && [[ -f /root/.claude/settings.json ]]; then
    mkdir -p "$user_home/.claude"
    cp /root/.claude/settings.json "$user_home/.claude/"
    [[ -d /root/.claude/skills ]] && cp -r /root/.claude/skills "$user_home/.claude/"
    chown -R "$user:$user" "$user_home/.claude"
  fi

  # Build escaped argument string
  local escaped_args=""
  if [[ $# -gt 0 ]]; then
    escaped_args=$(printf ' %q' "$@")
  fi

  # Run claude as non-root user, passing through API key
  su - "$user" -s /bin/bash -c "
    export ANTHROPIC_API_KEY=$(printf '%q' "${ANTHROPIC_API_KEY:-}")
    cd $(printf '%q' "$cwd") && /usr/local/bin/claude --dangerously-skip-permissions${escaped_args}
  "
}
