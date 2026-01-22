#!/bin/bash
# Create a new ML project from template
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Prompt for project name
read -p "Project name: " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
    print_error "Project name cannot be empty"
    exit 1
fi

# Prompt for location
read -p "Location [$(pwd)]: " PROJECT_LOCATION
PROJECT_LOCATION="${PROJECT_LOCATION:-$(pwd)}"

# Expand ~ if present
PROJECT_LOCATION="${PROJECT_LOCATION/#\~/$HOME}"

# Full project path
PROJECT_PATH="$PROJECT_LOCATION/$PROJECT_NAME"

if [[ -d "$PROJECT_PATH" ]]; then
    print_error "Directory already exists: $PROJECT_PATH"
    exit 1
fi

# Clone secrets repo if not present
SECRETS_DIR="$HOME/.secrets"
if [[ ! -d "$SECRETS_DIR" ]]; then
    print_info "Cloning secrets repo to $SECRETS_DIR..."
    git clone https://github.com/superkaiba/assignment_2 "$SECRETS_DIR"
    print_success "Secrets repo cloned"
else
    print_info "Secrets repo already present at $SECRETS_DIR"
fi

# Create project directory
print_info "Creating project at $PROJECT_PATH..."
mkdir -p "$PROJECT_PATH"

# Create .gitignore
cat > "$PROJECT_PATH/.gitignore" << 'EOF'
.env
__pycache__/
*.pyc
.venv/
experiments/
wandb/
outputs/
*.pt
*.ckpt
.hydra/
EOF

# Create pyproject.toml
cat > "$PROJECT_PATH/pyproject.toml" << EOF
[project]
name = "$PROJECT_NAME"
version = "0.1.0"
requires-python = ">=3.10"
dependencies = [
    "hydra-core",
    "wandb",
    "torch",
    "python-dotenv",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
EOF

# Create CLAUDE.md
cat > "$PROJECT_PATH/CLAUDE.md" << 'EOF'
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this ML project.

## Sub-Agent Policy

**ONLY spawn Opus 4.5 sub-agents.** Use `model: "opus"` for all Task tool invocations.

## Tools & Stack

- **Package management:** uv (not pip, not conda)
- **Config management:** Hydra
- **Experiment tracking:** Weights & Biases (wandb)
- **Deep learning:** PyTorch

## Repository Structure

Maintain clean, well-documented code organization:

```
src/                  # Library code (importable package)
  __init__.py
  models/
  data/
  training/
  utils/
scripts/              # Thin entry point wrappers
configs/              # Hydra YAML configs
experiments/          # Auto-generated experiment logs (gitignored)
  assets/             # Plots and images
```

**Standards:**
- No loose scripts in root directory
- Scripts are thin wrappers that import from `src/`
- Descriptive file names (not `run.py`, `test2.py`, `final_v3.py`)
- Document module purposes in docstrings
- Keep `src/` importable with proper `__init__.py` files

## Cluster-Aware Execution

Detect cluster via `$DOTFILES_CLUSTER` environment variable.

### Storage Paths

| Cluster | Caches & Results | Notes |
|---------|------------------|-------|
| mila | `$SCRATCH` | Symlink final results to `/network/projects` if needed |
| computecanada | `$SCRATCH` | 60-day purge policy - copy final results to `$PROJECT` |
| hyperbolic | `/runpod-volume` | Persistent across restarts |
| runpod | `/runpod-volume` | Persistent across restarts |
| local | project directory | Check `df -h` before large runs to ensure sufficient space |

Set cache environment variables accordingly:
- `HF_HOME`, `TRANSFORMERS_CACHE` → `$SCRATCH/.cache/huggingface` (or equivalent)
- `WANDB_CACHE_DIR` → `$SCRATCH/.cache/wandb`

### Job Submission

**SLURM clusters (mila, computecanada):**
- Submit jobs via `sbatch` with appropriate `--gres=gpu:N`, `--mem`, `--time`
- Monitor with `squeue -u $USER`
- View logs with `tail -f slurm-<jobid>.out`

**Non-SLURM (hyperbolic, runpod, local):**
- Run with `nohup python scripts/train.py &> logs/run.log &`
- Monitor with `ps aux | grep python`

## Experiment Monitoring

After launching an experiment (SLURM or background):
1. Monitor progress every 15 minutes using a loop with `sleep 900`
2. Check job status, wandb dashboard, and log files
3. Alert if job fails or metrics plateau unexpectedly

## Experiment Logging

After each experiment completes, save results to:
`experiments/YYYY-MM-DD-HH-MM-<experiment-name>.md`

Include in each log:
- Hydra config used (or config overrides)
- Final metrics (loss, accuracy, etc.)
- wandb run link
- Plots/figures (saved to `experiments/assets/`, linked in markdown)
- Observations and next steps

Example:
```
experiments/
  2025-01-22-14-30-baseline-resnet.md
  assets/
    2025-01-22-14-30-baseline-resnet-loss.png
    2025-01-22-14-30-baseline-resnet-accuracy.png
```

## Remote Dashboard Access

To expose a local web dashboard (e.g., TensorBoard, Gradio, Streamlit) remotely:

```bash
ssh -p 443 -R0:localhost:PORT PqpX2ouA826@a.pinggy.io
```

Replace `PORT` with the local port (e.g., 6006 for TensorBoard, 7860 for Gradio).

This provides a public URL to access the dashboard from anywhere.

## Environment

A `.env` file is symlinked with API keys (WANDB_API_KEY, HF_TOKEN, etc.).
Load with `python-dotenv` or `export $(cat .env | xargs)`.
EOF

# Symlink .env
if [[ -f "$SECRETS_DIR/.env" ]]; then
    ln -sf "$SECRETS_DIR/.env" "$PROJECT_PATH/.env"
    print_success "Symlinked .env from secrets repo"
else
    print_info "No .env found in secrets repo - you may need to create one"
fi

# Initialize git repo
cd "$PROJECT_PATH"
git init -q
git add .
git commit -q -m "Initial project setup from ml-project template"

print_success "Project created at $PROJECT_PATH"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_PATH"
echo "  uv venv && source .venv/bin/activate"
echo "  uv pip install -e ."
