# RunPod Environment Configuration

# RunPod environment variables
export RUNPOD_POD_ID="${RUNPOD_POD_ID:-}"

# Workspace and volume paths
export WORKSPACE="/workspace"
export RUNPOD_VOLUME="/runpod-volume"

# Use runpod-volume for persistent storage if available
if [[ -d "$RUNPOD_VOLUME" ]]; then
    export PERSISTENT_STORAGE="$RUNPOD_VOLUME"
else
    export PERSISTENT_STORAGE="$WORKSPACE"
fi

# Conda setup - RunPod often has conda pre-installed
if [[ -d "/opt/conda" ]]; then
    source "/opt/conda/etc/profile.d/conda.sh"
elif [[ -d "$HOME/miniconda3" ]]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
fi

# CUDA setup
if [[ -d "/usr/local/cuda" ]]; then
    export CUDA_HOME="/usr/local/cuda"
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
fi

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$WORKSPACE/.local/bin:$PATH"

# Cache directories on persistent storage
export WANDB_CACHE_DIR="$PERSISTENT_STORAGE/.cache/wandb"
export HF_HOME="$PERSISTENT_STORAGE/.cache/huggingface"
export TRANSFORMERS_CACHE="$PERSISTENT_STORAGE/.cache/huggingface/transformers"
export PIP_CACHE_DIR="$PERSISTENT_STORAGE/.cache/pip"

# Torch settings
export TORCH_HOME="$PERSISTENT_STORAGE/.cache/torch"
