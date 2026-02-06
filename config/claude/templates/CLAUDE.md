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
- Meaningful names that reveal intent
- Small functions that do one thing
- Comments explain "why", not "what"

**Small PRs**
- Keep pull requests under 200-400 lines
- Easier to review, fewer bugs slip through
- One logical change per PR

**Testing**
- Write tests before or alongside code
- Test behavior, not implementation
- Aim for fast, reliable tests

### Security

- Never commit secrets (API keys, passwords, credentials)
- Validate all external input
- Use parameterized queries (prevent SQL injection)
- Escape output (prevent XSS)
- Principle of least privilege

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
- Plain SQL over complex ORMs
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
