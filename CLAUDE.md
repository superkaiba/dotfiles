# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for consistent environment setup across multiple computing clusters (Mila, Compute Canada, Hyperbolic, RunPod, and local machines).

## Setup Commands

```bash
# Full setup (recommended for new machines)
./setup.sh

# Legacy installation workflow
./install.sh [--tmux] [--zsh] [--extras] [--force]
./deploy.sh [--vim] [--aliases=custom,speechmatics]
```

`setup.sh` auto-detects the cluster, installs oh-my-zsh with plugins, installs Claude Code CLI, and symlinks configs.

## Architecture

The system uses automatic cluster detection to apply environment-specific configurations:

1. **Entry point**: `setup.sh` sources `scripts/detect_cluster.sh` which identifies the environment by checking hostnames, paths, and environment variables
2. **Detection markers**:
   - Mila: `*.server.mila.quebec` hostname or `/network/projects`
   - Compute Canada: `/cvmfs/soft.computecanada.ca` or `$CC_CLUSTER`
   - Hyperbolic: `$HYPERBOLIC_API_KEY`
   - RunPod: `/runpod-volume` or `$RUNPOD_POD_ID`
3. **Config loading**: `config/zsh/zshrc.sh` sources cluster-specific `clusters/<cluster>/env.sh` and `aliases.sh`

## Directory Structure

- `config/` - Shell configuration (zsh, vim, tmux, git, claude)
- `clusters/` - Per-cluster environment variables and aliases
- `scripts/` - Setup utilities (`detect_cluster.sh`, `utils.sh`)
- `runpod/` - RunPod-specific setup scripts

## Claude Code Configuration

The `config/claude/settings.json` file contains Claude Code preferences (model, plugins). On setup, it symlinks to `~/.claude/settings.json`.

**Included:** Model preference, enabled plugins
**Not included:** History, cache, project data (machine-specific)

## Adding a New Cluster

1. Create `clusters/<name>/env.sh` (environment variables)
2. Create `clusters/<name>/aliases.sh` (cluster-specific aliases)
3. Add detection logic to `scripts/detect_cluster.sh`

## Key Files

- `config/zsh/zshrc.sh` - Main zsh config that orchestrates loading
- `config/aliases.sh` - Common aliases (git, tmux, SLURM, navigation)
- `config/claude/settings.json` - Claude Code model and plugin preferences
- `scripts/utils.sh` - Helper functions for `link_config`, `install_oh_my_zsh`, etc.
