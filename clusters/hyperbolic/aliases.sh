# Hyperbolic Cluster Aliases

# GPU monitoring
alias gpustat='nvidia-smi'
alias gpuwatch='watch -n 1 nvidia-smi'
alias gpumem='nvidia-smi --query-gpu=memory.used,memory.total --format=csv'

# Quick navigation
alias workspace='cd $WORKSPACE'
alias data='cd $PERSISTENT_STORAGE'

# Process management
alias psg='ps aux | grep -v grep | grep -i'
alias killgpu='pkill -f python'

# Docker (if available)
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'

# Quick environment setup
setup_env() {
    local name="${1:-main}"
    conda create -n "$name" python=3.10 -y
    conda activate "$name"
    pip install --upgrade pip
    echo "Created and activated conda env: $name"
}

# Download model to persistent storage
download_hf() {
    if [[ -n "$1" ]]; then
        python -c "from huggingface_hub import snapshot_download; snapshot_download('$1')"
    else
        echo "Usage: download_hf <model_name>"
    fi
}
