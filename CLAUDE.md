# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Core Principles

### DO NOT MAKE ASSUMPTIONS

**If something is unclear or ambiguous, ALWAYS ask clarifying questions before proceeding.**

This applies to:
- **Requirements** - Don't guess what the user wants. Ask.
- **Implementation details** - Don't assume the "obvious" approach is correct. Verify.
- **Data formats** - Don't assume structure, types, or edge cases. Clarify.
- **Success criteria** - Don't assume you know what "working" means. Define it explicitly.
- **Scope** - Don't assume what's in/out of scope. Confirm boundaries.

**Wrong approach:**
```
User: "Add caching to the API"
Claude: *implements Redis caching with 1-hour TTL*
```

**Correct approach:**
```
User: "Add caching to the API"
Claude: "Before I implement caching, I have a few questions:
- What should be cached? (responses, database queries, computed values?)
- What cache backend? (in-memory, Redis, file-based?)
- What TTL/invalidation strategy?
- Any endpoints that should NOT be cached?"
```

### When to Ask Questions

**ALWAYS ask when:**
- The task has multiple valid interpretations
- You're about to make a design decision
- You're unsure about edge cases
- The user's intent isn't 100% clear
- You're choosing between approaches
- Something could affect other parts of the system

**It's better to ask a "dumb" question than to make a wrong assumption.**

### For Experiments

Before running ANY experiment:
1. What is the hypothesis?
2. What defines success/failure?
3. What data, model, and baseline?
4. What are the constraints?
5. How will results be used?

See the `experiment-runner` skill for the full question checklist.

### VERIFY NEW FEATURES WITH SUBAGENTS

**After implementing any new feature, verify it actually works using a two-subagent approach:**

**Step 1: Run a minimal test (Subagent 1)**
- Spawn a subagent to execute a minimal test of the feature
- Use the simplest possible input that exercises the feature
- Capture all output, logs, and results

**Step 2: Verify results make sense (Subagent 2)**
- Spawn a SEPARATE, INDEPENDENT subagent to review the results
- This agent checks that output/logs contain what we expect
- It should NOT know implementation details - only expected behavior

**Why two subagents?**
- The implementer is biased toward seeing success
- An independent reviewer catches issues the implementer misses
- Separating execution from verification prevents confirmation bias

**Example workflow:**
```
1. Implement feature X

2. Spawn test runner subagent:
   "Run a minimal test of feature X with input Y.
    Capture all output and logs."

3. Spawn verification subagent:
   "Review these results from feature X.
    Expected behavior: [describe what should happen]
    Check if the output/logs show this actually happened.
    Report any discrepancies or concerns."

4. Only mark complete if verification passes
```

**What the verifier should check:**
- Does output match expected format/values?
- Are there any errors or warnings in logs?
- Did the feature actually run (not silently skip)?
- Are edge cases handled?
- Any unexpected side effects?

---

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

### Skills

Custom Claude Code skills are stored in `config/claude/skills/`. On setup, this directory symlinks to `~/.claude/skills/`.

**Available skills:**
- `code-refactoring` - Systematic code cleanup and refactoring techniques
- `experiment-runner` - ML experiment running, debugging, and unbiased results reporting
- `codebase-debugger` - Intent-first debugging via Socratic questioning and gap analysis
- `independent-reviewer` - Spawn unbiased agent to verify work achieves stated intent

**Adding a new skill:**
1. Create `config/claude/skills/<skill-name>/SKILL.md`
2. Add YAML frontmatter with `name` and `description`
3. Write instructions in markdown body
4. Run `./setup.sh` or manually symlink to apply

### Templates

A CLAUDE.md template for new repos is available at `config/claude/templates/CLAUDE.md`. Copy it to new projects:

```bash
cp ~/.dotfiles/config/claude/templates/CLAUDE.md /path/to/new/repo/CLAUDE.md
```

The template includes the core principles (don't make assumptions, ask clarifying questions) and placeholder sections for project-specific documentation.

## Adding a New Cluster

1. Create `clusters/<name>/env.sh` (environment variables)
2. Create `clusters/<name>/aliases.sh` (cluster-specific aliases)
3. Add detection logic to `scripts/detect_cluster.sh`

## Key Files

- `config/zsh/zshrc.sh` - Main zsh config that orchestrates loading
- `config/aliases.sh` - Common aliases (git, tmux, SLURM, navigation)
- `config/claude/settings.json` - Claude Code model and plugin preferences
- `scripts/utils.sh` - Helper functions for `link_config`, `install_oh_my_zsh`, etc.
