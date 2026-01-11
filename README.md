# Dotfiles

Personal dotfiles for consistent environment setup across multiple computing clusters.

## Supported Clusters

- **Mila** - Quebec AI Institute cluster
- **Compute Canada** - Narval, Cedar, Graham, etc.
- **Hyperbolic** - Cloud GPU instances
- **RunPod** - Serverless GPU pods
- **Local** - Fallback for local machines

## Quick Start

```bash
git clone https://github.com/USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The setup script will:
1. Auto-detect which cluster you're on
2. Install oh-my-zsh and Powerlevel10k theme
3. Install Claude Code CLI
4. Backup existing configs and create symlinks
5. Apply cluster-specific settings

## What's Included

### Shell (Zsh)
- oh-my-zsh with useful plugins
- Powerlevel10k theme (install [Meslo Nerd Font](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k) for best experience)
- Common aliases for git, navigation, tmux, python
- Cluster-specific SLURM aliases

### Editor (Vim)
- Sensible defaults
- Line numbers, syntax highlighting
- Useful key mappings (space as leader)

### Terminal Multiplexer (Tmux)
- `Ctrl+a` prefix (instead of Ctrl+b)
- Vim-style pane navigation
- Mouse support
- Clean status bar

### Git
- Useful aliases
- Better diff colors
- Default branch: main

### AI Assistant
- Claude Code CLI for AI-assisted coding

## Structure

```
dotfiles/
├── setup.sh              # Main setup script (auto-detects cluster)
├── scripts/
│   ├── detect_cluster.sh # Cluster auto-detection logic
│   └── utils.sh          # Helper functions
├── config/
│   ├── zsh/              # Zsh configuration
│   ├── vim/              # Vim configuration
│   ├── tmux/             # Tmux configuration
│   └── git/              # Git configuration
└── clusters/
    ├── mila/             # Mila-specific configs
    ├── computecanada/    # Compute Canada configs
    ├── hyperbolic/       # Hyperbolic configs
    └── runpod/           # RunPod configs
```

## Cluster-Specific Features

### Mila
- Module load shortcuts (`ml`, `mla`, `mll`)
- SLURM aliases: `sq`, `gpu`, `gpu2`, `slog`, `stail`
- Scratch and project paths: `$SCRATCH`, `$PROJECTS`
- HuggingFace/W&B cache on scratch

### Compute Canada
- Virtualenv helpers following CC best practices (`mkvenv`)
- SLURM aliases with A100 support (`gpua100`)
- Job efficiency checking (`eff`)
- Disk quota monitoring (`quota`)

### Hyperbolic / RunPod
- Persistent storage setup on volumes
- Quick conda environment creation (`setup_env`)
- Model download helpers (`download_hf`)
- GPU monitoring aliases

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Git status |
| `gd` | `git diff` | Git diff |
| `ll` | `ls -la` | List all files |
| `ta` | `tmux attach -t` | Attach to tmux session |
| `sq` | `squeue -u $USER` | Show your SLURM jobs |
| `gpu` | `salloc --gres=gpu:1...` | Request interactive GPU |
| `gpustat` | `nvidia-smi` | Show GPU status |
| `scratch` | `cd $SCRATCH` | Go to scratch directory |

## Customization

### Adding Personal Settings
The zshrc will source `~/.zshrc.local` if it exists - use this for machine-specific settings.

### Modifying Cluster Detection
Edit `scripts/detect_cluster.sh` to add or modify cluster detection markers.

### Adding New Clusters
1. Create a new directory under `clusters/`
2. Add `env.sh` for environment variables
3. Add `aliases.sh` for cluster-specific aliases
4. Update `scripts/detect_cluster.sh` with detection logic

## Updating

```bash
cd ~/.dotfiles
git pull
./setup.sh  # Re-run to apply changes
```

## Legacy Scripts

The original `install.sh` and `deploy.sh` scripts are preserved for compatibility:
- `install.sh --tmux --zsh` - Install specific dependencies
- `deploy.sh --vim --aliases=custom` - Deploy with options

## License

MIT
