# RunPod Aliases

# GPU monitoring
alias gpustat='nvidia-smi'
alias gpuwatch='watch -n 1 nvidia-smi'
alias gpumem='nvidia-smi --query-gpu=memory.used,memory.total --format=csv'

# Quick navigation
alias workspace='cd $WORKSPACE'
alias volume='cd $RUNPOD_VOLUME'
alias data='cd $PERSISTENT_STORAGE'

# Process management
alias psg='ps aux | grep -v grep | grep -i'
alias killpy='pkill -f python'

# Quick conda environment setup on persistent storage
setup_env() {
    local name="${1:-main}"
    local env_path="$PERSISTENT_STORAGE/envs/$name"

    mkdir -p "$PERSISTENT_STORAGE/envs"
    conda create -p "$env_path" python=3.10 -y
    conda activate "$env_path"
    pip install --upgrade pip
    echo "Created and activated conda env at: $env_path"
}

# Activate persistent env
actenv() {
    local name="${1:-main}"
    local env_path="$PERSISTENT_STORAGE/envs/$name"
    if [[ -d "$env_path" ]]; then
        conda activate "$env_path"
    else
        echo "Environment not found: $env_path"
        echo "Create it with: setup_env $name"
    fi
}

# Download model to persistent storage
download_hf() {
    if [[ -n "$1" ]]; then
        python -c "from huggingface_hub import snapshot_download; snapshot_download('$1')"
    else
        echo "Usage: download_hf <model_name>"
    fi
}

# Quick pip install from requirements
pipr() {
    if [[ -f "requirements.txt" ]]; then
        pip install -r requirements.txt
    else
        echo "No requirements.txt found"
    fi
}

# Sync workspace to volume (backup)
sync_to_volume() {
    rsync -avz --progress "$WORKSPACE/" "$RUNPOD_VOLUME/workspace_backup/"
}
