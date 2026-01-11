# Hyperbolic Cluster Environment Configuration

# API key should be set in environment or .env file
# export HYPERBOLIC_API_KEY="your-api-key"

# Persistent storage path (adjust based on your setup)
export PERSISTENT_STORAGE="${PERSISTENT_STORAGE:-/data}"
export WORKSPACE="${WORKSPACE:-/workspace}"

# Conda setup
if [[ -d "$HOME/miniconda3" ]]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [[ -d "/opt/conda" ]]; then
    source "/opt/conda/etc/profile.d/conda.sh"
fi

# CUDA setup
if [[ -d "/usr/local/cuda" ]]; then
    export CUDA_HOME="/usr/local/cuda"
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
fi

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Cache directories on persistent storage
if [[ -d "$PERSISTENT_STORAGE" ]]; then
    export WANDB_CACHE_DIR="$PERSISTENT_STORAGE/.cache/wandb"
    export HF_HOME="$PERSISTENT_STORAGE/.cache/huggingface"
    export TRANSFORMERS_CACHE="$PERSISTENT_STORAGE/.cache/huggingface/transformers"
    export PIP_CACHE_DIR="$PERSISTENT_STORAGE/.cache/pip"
fi
