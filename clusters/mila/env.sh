# Mila Cluster Environment Configuration

# Scratch directory
export SCRATCH="/network/scratch/$USER"
export SLURM_TMPDIR="${SLURM_TMPDIR:-/tmp}"

# Projects directory
export PROJECTS="/network/projects"

# Module loads (uncomment as needed)
# module load python/3.10
# module load cuda/12.1
# module load cudnn/8.9

# Conda setup (if using conda)
if [[ -d "$HOME/miniconda3" ]]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [[ -d "$HOME/anaconda3" ]]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
fi

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# CUDA paths (if CUDA is loaded)
if [[ -n "$CUDA_HOME" ]]; then
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
fi

# Weights & Biases cache
export WANDB_CACHE_DIR="$SCRATCH/.cache/wandb"

# Hugging Face cache
export HF_HOME="$SCRATCH/.cache/huggingface"
export TRANSFORMERS_CACHE="$SCRATCH/.cache/huggingface/transformers"
