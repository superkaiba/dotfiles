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

Before running ANY experiment, clarify:
1. What is the hypothesis?
2. What defines success/failure?
3. What data, model, and baseline?
4. What are the constraints?
5. How will results be used?

### VERIFY NEW FEATURES WITH SUBAGENTS

**After implementing any new feature, verify it works using two subagents:**

1. **Subagent 1 (Test Runner):** Run a minimal test of the feature, capture output/logs
2. **Subagent 2 (Verifier):** Independently review results to confirm they contain what's expected

**Why two subagents?**
- The implementer is biased toward seeing success
- An independent reviewer catches issues the implementer misses
- Separating execution from verification prevents confirmation bias

**The verifier should check:**
- Does output match expected format/values?
- Any errors or warnings in logs?
- Did the feature actually run (not silently skip)?
- Any unexpected side effects?

**Only mark a feature complete after independent verification passes.**

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
