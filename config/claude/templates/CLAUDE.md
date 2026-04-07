# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

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

### NEVER TAKE SHORTCUTS

**If something is not working, ASK THE USER.** Do not:
- Silently skip a failing step
- Disable a feature to make the error go away
- Hardcode values to work around a bug
- Delete or comment out code that's causing problems
- Add `try/except: pass` to suppress errors
- Use `--no-verify`, `--force`, or equivalent flags to bypass checks

**The fix for "it doesn't work" is never "make it stop complaining."** Diagnose the root cause. If you can't, ask.

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

## Coding Best Practices

### Design Principles

**Reuse Aggressively**
- Before writing new code, check if a library already does it (`uv add` it)
- Check if the current codebase already has utilities or patterns that can be reused
- Check if you already wrote this in another project — if so, extract to a shared package
- Propose candidate options with pros/cons and let the user choose
- Only build from scratch when existing solutions don't fit or add unnecessary complexity
- But don't create your own abstractions prematurely — wait for 3+ occurrences

**KISS (Keep It Simple, Stupid)**
- Choose the simplest solution that works
- Avoid over-engineering with fancy patterns
- Do the dumbest possible thing that will work

**YAGNI (You Ain't Gonna Need It)**
- Only build what's necessary now
- Don't add features "just in case"
- Avoid speculative generality

**DRY (Don't Repeat Yourself)**
- Every piece of knowledge should have a single, authoritative representation
- But don't abstract prematurely - wait for 3+ occurrences

**SOLID Principles**
- Single Responsibility: One reason to change per class/function
- Open/Closed: Open for extension, closed for modification
- Liskov Substitution: Subtypes must be substitutable
- Interface Segregation: Many specific interfaces over one general
- Dependency Inversion: Depend on abstractions, not concretions

### Code Quality

**Clean Code**
- Readable and self-documenting
- Meaningful names that reveal intent — no magic numbers, use named constants
- Small, single-purpose functions and modules — one file = one concern
- Comments explain "why", not "what" (document interfaces and reasons, not implementations)

**Small PRs**
- Keep pull requests under 200-400 lines
- Easier to review, fewer bugs slip through
- One logical change per PR

**Never Silently Fail**
- Raise errors loudly and immediately — never swallow exceptions or return default values on failure
- If something goes wrong, the caller must know about it
- Prefer crashing over silently producing wrong results

**Testing**
- Write tests before or alongside code
- Test behavior, not implementation
- Aim for fast, reliable tests

**Linting and Formatting: Ruff**
- One tool for linting and formatting — replaces flake8 + isort + black
- Run `uv run ruff check .` and `uv run ruff format .` before every commit
- Configure in `pyproject.toml`:

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP"]
```

### Security

- Never commit secrets (API keys, passwords, credentials)
- Validate all external input
- Use parameterized queries (prevent SQL injection)
- Escape output (prevent XSS)
- Principle of least privilege

---

## Foundational Tooling

### Package Management: `uv`

**Always use `uv` for every project. No exceptions.** (not pip, not conda)

```bash
uv init my-project         # initialize project with pyproject.toml
uv python pin 3.11         # pin Python version
uv add torch wandb hydra-core  # add dependencies
uv add --dev pytest ruff   # add dev dependencies
uv run python train.py     # run inside managed environment
uv sync                    # collaborators run this to reproduce
```

Every project gets a `pyproject.toml` (single source of truth) and a `uv.lock` (reproducibility guarantee). Commit both. For GPU/CUDA packages, conda/mamba for the base environment + `uv` for the Python layer compose cleanly.

### Configuration: Hydra + OmegaConf

**Always use Hydra for experiment configuration. Never use argparse for research code.**

Compose hierarchical YAML configs, override from CLI, auto-save resolved config per run.

```
configs/
├── config.yaml          # defaults list
├── model/
│   ├── gpt2.yaml
│   └── llama3.yaml
├── dataset/
│   ├── openwebtext.yaml
│   └── ultrachat.yaml
├── training/
│   ├── sft.yaml
│   └── dpo.yaml
└── experiment/
    └── sft_llama3_ultrachat.yaml   # overrides for a specific run
```

Minimal entrypoint:

```python
import hydra
from omegaconf import DictConfig

@hydra.main(config_path="configs", config_name="config", version_base="1.3")
def main(cfg: DictConfig):
    trainer = build_trainer(cfg)
    trainer.run()

if __name__ == "__main__":
    main()
```

```bash
# Override from CLI
uv run python train.py model=llama3 training.lr=1e-5

# Sweep hyperparameters
uv run python train.py --multirun training.lr=1e-4,1e-5,3e-5
```

**Use `_target_` for instantiation** to eliminate if/else trees:

```yaml
# configs/model/gpt2.yaml
_target_: transformers.AutoModelForCausalLM.from_pretrained
pretrained_model_name_or_path: gpt2
torch_dtype: float16
```

```python
model = hydra.utils.instantiate(cfg.model)
```

### Experiment Tracking: Weights & Biases

**Use `wandb` for every run.** Log configs, metrics, system utilization, and artifacts.

```python
import wandb
from omegaconf import OmegaConf

def init_wandb(cfg):
    wandb.init(
        project=cfg.project_name,
        config=OmegaConf.to_container(cfg, resolve=True),
        tags=cfg.get("tags", []),
    )
```

**Log everything by default** — it's cheaper to store than to re-run.

**Every run must capture:**
- **Hyperparameters** — log the full Hydra config as the wandb config (every param is searchable)
- **Metrics** — loss, accuracy/F1/perplexity via `wandb.log()`, per step/epoch (not just final values)
- **Artifacts** — model checkpoints, generated outputs via `wandb.Artifact`
- **Data version** — dataset version/split used, preprocessing applied
- **Code version** — git commit hash tied to the run
- **Environment** — Python version, package versions, GPU type, random seeds
- **System metrics** — GPU utilization, memory usage, training time (wandb logs these automatically)
- **Tags** — use aggressively (e.g., `["sft", "llama3", "ablation"]`) for filtering

**Practices:**
- Tag every run with its objective and what changed vs. the previous run
- Organize experiments by objective, not chronologically
- Every run must be fully reproducible from its logged metadata alone
- Compare runs side-by-side using W&B dashboards — don't eyeball logs

### Model and Data Versioning: HuggingFace Hub

**Use `huggingface_hub` for model and dataset versioning.** Git-based repos with version tracking.

```python
from huggingface_hub import HfApi

api = HfApi()
api.upload_folder(folder_path="./my_model", repo_id="username/my-model")
api.hf_hub_download("meta-llama/Llama-3-8B", filename="config.json")
```

For private research, create a private repo on the Hub. Checkpoints and datasets must be versioned and discoverable, not scattered across random cluster directories.

---

## Research Project Structure

```
my-research-project/
├── pyproject.toml        # metadata + dependencies (uv manages this)
├── uv.lock               # deterministic lockfile
├── configs/              # Hydra YAML configs (checked into git)
│   ├── config.yaml
│   ├── model/
│   ├── dataset/
│   ├── training/
│   └── experiment/
├── src/
│   └── my_project/
│       ├── __init__.py
│       ├── data.py       # dataset loading, preprocessing, collators
│       ├── model.py      # model construction, custom heads, wrappers
│       ├── train.py      # training loops or trainer configuration
│       ├── evaluate.py   # evaluation and metrics
│       └── utils.py      # shared helpers (seeding, logging, I/O)
├── scripts/
│   ├── train.py          # Hydra entrypoint for training
│   ├── eval.py           # Hydra entrypoint for evaluation
│   └── run_api_experiment.py
├── notebooks/            # exploration only — never production code
├── tests/
├── docs/
│   ├── TODO.md           # project todos and next steps
│   └── meetings/         # meeting notes (one file per meeting)
├── research_log/         # experiment write-ups and running LOG.md
├── slurm/                # cluster job scripts (.sbatch)
├── outputs/              # Hydra auto-creates this per run
├── .env.example          # template with placeholder keys (checked into git)
├── .env                  # actual secrets (gitignored)
└── README.md
```

**The rule:** `src/` holds reusable library code. `scripts/` holds entrypoints. `configs/` holds parameters. Everything else is ancillary.

**Setup:**
- Include a `.env.example` with all required keys as placeholders
- `.env` must be in `.gitignore` — never commit secrets
- On project setup, copy `.env.example` to `.env` and prompt the user to fill in their keys
- **Running experiments must be zero-friction** — entrypoints should automatically load `.env`, set cache directories, and configure the environment so `uv run python scripts/train.py` just works with no manual exports

**Environment bootstrap** — every entrypoint should handle this at the top:

```python
from dotenv import load_dotenv
load_dotenv()  # auto-load .env (API keys, tokens)

import os

# Set HF cache to persistent storage (not /root which is ephemeral on RunPod)
if os.path.exists("/workspace"):
    os.environ.setdefault("HF_HOME", "/workspace/.cache/huggingface")
elif os.path.exists("/network/projects"):  # Mila
    os.environ.setdefault("HF_HOME", os.path.expanduser("~/scratch/.cache/huggingface"))
```

Put this in `src/my_project/utils.py` as a `setup_env()` function and call it at the top of every script. All environment setup lives in code — **you should never need to manually export variables or prepend env vars to commands.** Running an experiment should always be just:

```bash
nohup uv run python scripts/train.py &
```

Never this:
```bash
# WRONG — all of this should be handled by setup_env()
PYTHONPATH=/workspace/pip_packages:/root/projects/my_project \
HF_HOME=/workspace/cache/huggingface \
WANDB_MODE=disabled nohup python3 scripts/train.py &
```

**Entry points:**
- Single entry-point scripts — `uv run python scripts/train.py` — not scattered one-off scripts
- All config via Hydra YAML — no hardcoded values, no argparse
- Bash scripts for orchestration only — launching sweeps, submitting SLURM jobs — not for logic
- **Always run experiments with `nohup`** so they survive SSH disconnections: `nohup uv run python scripts/train.py &`

**What to avoid:**
- Notebooks as production code — use `.py` files for anything that runs repeatedly
- Multiple ways to run the same thing — one canonical way per task
- Hardcoded paths or magic numbers — everything in config or named constants
- Untracked dependencies or data
- Copy-pasting between projects — extract to a shared package instead

### Reproducibility

- **Set random seeds explicitly** — write a `seed_everything(seed)` covering `random`, `numpy`, `torch`, `torch.cuda`. Store the seed in Hydra config.
- **Pin all dependencies** — `uv.lock` committed to git
- **Version everything** — code (git), data and models (HuggingFace Hub), configs (checked into repo)
- **Every run is self-contained** — Hydra auto-saves resolved config, logs, and outputs per run
- **Containerize** (Docker) for cross-machine reproducibility: install `uv`, copy `pyproject.toml` + `uv.lock`, run `uv sync`

### SLURM / Cluster

Keep `.sbatch` scripts in `slurm/`. Job scripts call `uv run python scripts/train.py` with config overrides. Hydra composes cleanly with SLURM.

### Research Log

Keep a `research_log/` directory to document experiment results:

```
research_log/
├── LOG.md                          # running log with TLDRs linking to details
├── 2026-04-03_sft_llama3.md        # detailed write-up per experiment
├── 2026-04-02_dpo_ablation.md
└── ...
```

**`LOG.md`** — a running log, newest entries first. Each entry is a one-liner TLDR linking to the detailed write-up:

```markdown
# Research Log

- **2026-04-03** — SFT on Llama3 with UltraChat converges in 3 epochs, beats baseline by 4.2% on MT-Bench. [Details](2026-04-03_sft_llama3.md)
- **2026-04-02** — DPO ablation: beta=0.1 best, beta=0.5 collapses. [Details](2026-04-02_dpo_ablation.md)
```

**Per-experiment markdown** — one file per experiment containing:
- **Goal** — what you were testing and why
- **Setup** — model, dataset, key hyperparameters, git hash
- **Results** — metrics, plots (embed images or link to W&B)
- **Interpretation** — what the results mean, what surprised you, what to try next

---

## Reuse Checklist

Before writing any code for a new project:

- [ ] **Can I `uv add` a library that does this?** Check PyPI, HuggingFace, GitHub first.
- [ ] **Did I already write this in another project?** Extract to shared package.
- [ ] **Am I copy-pasting a config pattern?** Make it a Hydra config template.
- [ ] **Am I writing a training loop from scratch?** Use TRL's trainers or HF Trainer.
- [ ] **Am I writing evaluation code from scratch?** Check if `inspect_evals` already has it.
- [ ] **Am I parsing CLI arguments?** Stop. Use Hydra.
- [ ] **Am I writing a custom data loader?** Check if `datasets` supports your format.

---

## ML Libraries Reference

### Training & Fine-Tuning

| Library | Purpose |
|---|---|
| `trl` | SFTTrainer, DPOTrainer, GRPOTrainer, PPOTrainer — all post-training methods |
| `transformers` | Model architectures, tokenizers, base Trainer |
| `datasets` | Load, process, stream 500K+ datasets from HF Hub |
| `accelerate` | Multi-GPU, DeepSpeed, FSDP with minimal code changes |
| `peft` | LoRA, QLoRA — train billion-parameter models on consumer GPUs |
| `bitsandbytes` | 4-bit/8-bit quantization for training on modest hardware |
| `unsloth` | 2x faster SFT/DPO training, 70% less VRAM |
| `vllm` | High-throughput inference, used by TRL for online RL generation |
| `flash-attn` | Memory-efficient attention |
| `liger-kernel` | Optimized Triton kernels for transformer training |

### Mechanistic Interpretability

| Library | Purpose |
|---|---|
| `transformer_lens` | HookPoints on every activation, 50+ models. Best for circuit discovery, activation patching. |
| `nnsight` + `nnterp` | Wraps original HF models (exact numerics), 16+ architecture families, remote execution via NDIF |
| `sae_lens` | Train, load, and analyze sparse autoencoders |
| `circuitsvis` | Visualize attention patterns and circuits |
| `pyvene` | Declarative framework for causal interventions |

### Evaluation & API Research

| Library | Purpose |
|---|---|
| `inspect-ai` | Composable eval framework, 100+ pre-built benchmarks (UK AISI) |
| `anthropic` | Official SDK for Claude models |
| `openai` | Official SDK for GPT models |
| `litellm` | Single interface to 100+ LLM providers |
| `instructor` | Structured output extraction from LLM responses |

### Data & Model Management

| Library | Purpose |
|---|---|
| `datasets` | Load, process, stream datasets from HF Hub |
| `huggingface_hub` | Push/pull models and datasets, Git-based versioning |

---

## Recipes by Research Scenario

### Fine-tuning with SFT
**Stack:** `uv` + `hydra` + `wandb` + `trl` (SFTTrainer) + `datasets` + `peft` + `accelerate`

### RLHF / Preference Optimization
**Stack:** `uv` + `hydra` + `wandb` + `trl` (GRPOTrainer or DPOTrainer) + `datasets` + `peft` + `vllm`

### Mechanistic Interpretability
**Stack:** `uv` + `hydra` + `wandb` + `transformer_lens` or `nnsight`/`nnterp` + `sae_lens` + `circuitsvis`

Use TransformerLens for GPT-2 scale (most ergonomic hook interface). Use nnsight/nnterp for exact HF behavior or newer architectures.

### Evaluations on Frontier Models via API
**Stack:** `uv` + `hydra` + `wandb` + `inspect-ai` + `anthropic`/`openai`/`litellm` + `datasets`

### Building a New Benchmark or Dataset
**Stack:** `uv` + `datasets` + `huggingface_hub`

Build as `datasets.Dataset`, validate, write a dataset card, push to Hub.

---

## Agentic Coding Best Practices

### Effective Prompting

**Be specific about approach, not just goal**
```
# Bad
"Add unit tests"

# Good
"Add unit tests for the UserService class covering:
- Happy path for createUser
- Validation errors for invalid email
- Database connection failure handling
Mock the database layer, use pytest"
```

**Provide context upfront**
- Reference relevant files and directories
- Mention key components involved
- Explain constraints and requirements
- Share relevant documentation

**Break tasks into phases**
```
1. Plan: Outline the approach, get approval
2. Implement: Write the code
3. Test: Verify it works
4. Review: Check for issues
```

### Working with Agents

**Plan before implementing**
- Discuss approach before writing code
- Outline the solution first
- Get confirmation on the plan

**Use defensive prompting**
- Anticipate where confusion might arise
- Preemptively clarify edge cases
- Think like you're briefing a new team member

**Provide feedback mechanisms**
- Give access to tests, types, linters
- Let agents catch their own errors
- Typed languages improve outcomes

**Cut losses early**
- If agent keeps going off track, start fresh
- New session with complete instructions beats iterating through mess
- Expect ~80% automation, not 100%

### Code Structure for Agents

**Prefer simplicity**
- Longer descriptive names over clever abstractions
- Explicit over implicit
- Local logic over hidden configuration

**Fast feedback loops**
- Quick compilation/test cycles
- Clear error messages
- Log everything for diagnostics

**Stable dependencies**
- Avoid libraries with frequent breaking changes
- Document versions explicitly
- Keep ecosystem churn low

---

## Project Overview

<!-- Describe your project here -->

## Tech Stack

<!-- List key technologies, frameworks, versions -->

## Directory Structure

<!-- Explain the codebase layout -->

## Common Commands

```bash
# Build
# Test
# Run
# Deploy
```

## Architecture Notes

<!-- Key architectural decisions, patterns used -->

## Gotchas / Known Issues

<!-- Things that might trip someone up -->

---

## Sources

- [Zencoder - Software Engineering Best Practices 2025](https://zencoder.ai/blog/software-engineering-best-practices)
- [DataCamp - Coding Best Practices](https://www.datacamp.com/tutorial/coding-best-practices-and-guidelines)
- [Armin Ronacher - Agentic Coding Recommendations](https://lucumr.pocoo.org/2025/6/12/agentic-coding/)
- [Augment Code - Best Practices for AI Coding Agents](https://www.augmentcode.com/blog/best-practices-for-using-ai-coding-agents)
- [Devin - Coding Agents 101](https://devin.ai/agents101)
- [Google Cloud - Five Best Practices for AI Coding Assistants](https://cloud.google.com/blog/topics/developers-practitioners/five-best-practices-for-using-ai-coding-assistants)
- [Utrecht University - Best Practices for Writing Reproducible Code](https://www.uu.nl/en/research/research-data-management/best-practices-for-writing-reproducible-code)
- [Emergent Mind - Research as Code](https://www.emergentmind.com/topics/research-as-code)
- [Neptune.ai - ML Experiment Management](https://neptune.ai/blog/experiment-management)
- [Towards Data Science - SE Best Practices for Maintainable ML Code](https://towardsdatascience.com/software-engineering-best-practices-for-writing-maintainable-ml-code-717934bd5590/)
- [arxiv - Best Practices for Scientific Computing](https://ar5iv.labs.arxiv.org/html/1210.0530)
- [Berkeley Stat243 - Good Practices for Reproducible Research](https://stat243.berkeley.edu/fall-2024/units/unit4-goodPractices.html)
