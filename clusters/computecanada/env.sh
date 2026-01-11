# Compute Canada Cluster Environment Configuration

# Detect which CC cluster we're on
if [[ -n "$CC_CLUSTER" ]]; then
    export CLUSTER_NAME="$CC_CLUSTER"
else
    export CLUSTER_NAME="unknown"
fi

# Scratch directory
export SCRATCH="$SCRATCH"  # CC sets this automatically
export SLURM_TMPDIR="${SLURM_TMPDIR:-/tmp}"

# Project directory
export PROJECT="$PROJECT"  # CC sets this automatically

# Module loads (uncomment as needed)
# module load python/3.10
# module load cuda/12.2
# module load cudnn/8.9

# Virtualenv setup (CC recommends virtualenvs over conda)
# Activate a virtualenv if it exists
if [[ -d "$HOME/envs/default" ]]; then
    source "$HOME/envs/default/bin/activate"
fi

# SLURM account (set your allocation)
# export SLURM_ACCOUNT="def-yourpi"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Weights & Biases cache
export WANDB_CACHE_DIR="$SCRATCH/.cache/wandb"

# Hugging Face cache
export HF_HOME="$SCRATCH/.cache/huggingface"
export TRANSFORMERS_CACHE="$SCRATCH/.cache/huggingface/transformers"

# Disable pip cache to save quota
export PIP_NO_CACHE_DIR=1
