# Compute Canada Cluster Aliases

# SLURM shortcuts
alias sq='squeue -u $USER'
alias sqa='squeue'
alias si='sinfo'
alias sc='scancel'
alias sca='scancel -u $USER'

# Interactive GPU sessions (adjust partition as needed)
alias gpu='salloc --gres=gpu:1 --cpus-per-task=4 --mem=32G --time=3:00:00'
alias gpu2='salloc --gres=gpu:2 --cpus-per-task=8 --mem=64G --time=3:00:00'
alias gpua100='salloc --gres=gpu:a100:1 --cpus-per-task=4 --mem=32G --time=3:00:00'

# CPU interactive session
alias cpu='salloc --cpus-per-task=4 --mem=16G --time=3:00:00'

# View job logs
slog() {
    if [[ -n "$1" ]]; then
        cat "slurm-$1.out"
    else
        echo "Usage: slog <job_id>"
    fi
}

# Tail job logs
stail() {
    if [[ -n "$1" ]]; then
        tail -f "slurm-$1.out"
    else
        echo "Usage: stail <job_id>"
    fi
}

# Quick navigation
alias scratch='cd $SCRATCH'
alias project='cd $PROJECT'

# Show GPU usage
alias gpustat='nvidia-smi'
alias gpuwatch='watch -n 1 nvidia-smi'

# Module shortcuts
alias ml='module load'
alias mla='module avail'
alias mll='module list'
alias mlp='module spider python'

# Disk quota
alias quota='diskusage_report'

# Job efficiency
alias eff='seff'

# Create virtualenv with CC best practices
mkvenv() {
    local name="${1:-default}"
    module load python/3.10
    python -m venv "$HOME/envs/$name"
    source "$HOME/envs/$name/bin/activate"
    pip install --upgrade pip
    echo "Created and activated virtualenv: $name"
}
