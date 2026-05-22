---
name: humanize
version: 2.0.0
description: |
  Canonical skill for removing AI-generated writing patterns. Routes to one of
  two modes: (1) quick — pattern scrubbing against Wikipedia's "Signs of AI
  writing" catalog; default for emails, blog posts, drafts, general prose.
  (2) academic — adapted catalog for medical/scientific manuscripts with
  em-dash zero-tolerance, copula avoidance, classical academic terms
  restoration, hedging discipline. Both modes run a hostile critic subagent
  loop by default: revise → spawn critic with fresh context → iterate up to 3
  rounds until normalized score ≤ 0.20. The critic scores across 6 categories
  (vocabulary, structure, rhythm, voice, interpretation honesty, results-
  writing discipline) and conditionally fires the last two based on detected
  text type. Replaces and absorbs the retired /humanizer, /humanizer_academic,
  and /ai-critic-loop skills.
license: MIT
compatibility: claude-code opencode
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - Agent
---

# Humanize: the dedicated humanizing skill

This is the single canonical skill for making writing sound less AI-generated.
It replaces three earlier skills (`humanizer`, `humanizer_academic`,
`ai-critic-loop`) by routing to whichever mode fits the text. Always use this
skill instead of looking for those three.

## Modes

| Mode | Use for | Pattern catalog |
|---|---|---|
| **quick** | General prose: emails, blog posts, posts, drafts, marketing copy | `patterns_general.md` |
| **academic** | Medical / scientific / academic manuscripts | `patterns_academic.md` |

**Both modes run a critic-subagent loop by default.** After the initial
pattern-based revision, a hostile critic with fresh context (see
`critic_loop.md`) scores the draft across 6 categories and flags issues;
you revise and re-spawn until the critic returns PASS (normalized score
≤ 0.20) or you hit 3 iterations. The critic is unbiased in that it has no
exposure to your drafting reasoning. Same default model — independence
comes from the adversarial framing in the prompt plus the fresh context.

## Mode selection

1. **If the user named a mode** (`/humanize academic`, `/humanize quick`),
   use it. No further questions.
2. **Auto-detect** from the text:
   - **academic** if the text reads as a scientific/medical manuscript:
     statistics, named trials, hazard ratios, p-values, "patients with",
     "primary endpoint", formal methods register.
   - **quick** otherwise.
3. **Ask only when genuinely ambiguous** (e.g., a results writeup that
   could plausibly be quick or academic register). One `AskUserQuestion`
   with the detected candidates; never more than that.

State the chosen mode in one line at the top of your response: `Mode:
<quick|academic>` so the user can override.

## Execution

For either mode, the full procedure is:

1. **Read the pattern catalog** (`patterns_general.md` for quick,
   `patterns_academic.md` for academic). Apply the catalog: identify AI
   patterns and revise into an initial draft.
2. **Spawn the critic subagent** per `critic_loop.md`. Pass the draft.
   Read the verdict, normalized score, and flagged issues.
3. **If PASS** (normalized score ≤ 0.20) and the hard gate (below)
   passes, present the text.
4. **If FAIL**, revise addressing every flagged issue (restructure
   sentences, vary rhythm, fix content overclaims, do not just swap
   synonyms), then loop back to step 2. Maximum 3 critic iterations.
5. **If still FAIL after 3 iterations**, present the best version with
   honest disclosure of the remaining flagged issues and their normalized
   score. Do not silently accept a FAIL.

Both modes share the critic procedure described in `critic_loop.md` —
the catalogs differ (general prose patterns vs medical/scientific
register patterns), but the post-revision critic loop is identical and
the critic itself auto-detects text type (prose / interpretation /
results-writeup) to fire the right scoring categories.

## Research/technical text — phantom vocabulary is the priority pattern

If the input is a research proposal, project narrative, results writeup, or
any text describing experiments or training procedures, **pattern 30
(phantom technical vocabulary) is the highest-priority tell.** Other prose
patterns make text feel slightly off; phantom vocabulary lets undue certainty
ride through the document on coined nouns ("verification key", "the install",
"the X signal") and anthropomorphic methodology verbs ("install", "fires",
"deploys"). Do a dedicated final pass that looks at nothing but pattern 30
before spawning the critic. See `patterns_general.md` §30 for the trace
test, watchlist, and antidote table. The critic's Category 6 (results-
writing discipline) also explicitly flags phantom vocabulary, so it will
catch what the catalog pass misses — but it should not be the only check.

Common failure mode: applying patterns 1–29 thoroughly, then under-applying
30 because the coined terms *feel* defined by their surrounding sentences.
They aren't — a metaphor described in context is still a metaphor. Rewrite.

## Voice calibration (all modes)

If the user supplies a writing sample for voice matching (inline or by file
path), analyze it before rewriting regardless of mode. Match sentence-length
patterns, word-choice level, punctuation habits, paragraph openings, and any
recurring verbal tics. Do not upgrade the user's casual vocabulary to a
formal register.

## Hard gate — banned-word check (mandatory before finishing)

Before presenting any humanized text to the user (any mode), you **must** run
the absolute-ban check. The skill is not done until the gate returns `PASS`.

The ban list lives at `~/.claude/skills/humanize/banned_absolute.txt` and is
enforced by `~/.claude/skills/humanize/check_bans.sh`.

Steps:

1. Write the candidate final text to a temp file. For the HTML/markdown body
   of a long artifact, write the whole body; for a short rewrite, the prose
   itself is fine.
   ```bash
   # example
   cat > /tmp/humanize-out.txt <<'EOF'
   <your candidate final text>
   EOF
   ```
2. Run the gate:
   ```bash
   ~/.claude/skills/humanize/check_bans.sh /tmp/humanize-out.txt
   ```
3. Interpret the result:
   - **Exit 0 with `PASS: ...`** — gate passes. You may present the text.
   - **Exit 0 with `PASS (absolute bans clean) — N watch-list match(es)`** —
     gate passes but review the listed lines. If ≥2 watch terms appear in the
     same paragraph, rewrite that paragraph before presenting.
   - **Exit 1 with `FAIL: ...`** — gate fails. Rewrite every flagged
     occurrence, write the new draft to the temp file, and re-run. Loop
     until exit 0.
4. Do not present the rewrite to the user until the gate returns exit 0.

The banned list is editable. When the user says "stop using X" or "ban Y",
add a line to `banned_absolute.txt` (use `\bword\b` for single-word
boundary matching; multi-word phrases can go in raw). Watch-list-tier
entries (context-dependent overuse) go in `banned_watch.txt`. Both files
are case-insensitive ERE pattern lists consumed by `grep -niEf`.

The catalogs in `patterns_general.md` and `patterns_academic.md` remain the
fuller reference for *why* a term is banned and how to rewrite it; the
ban files are the mechanical enforcement layer.

## Do not

- Run more than one mode in a single invocation. Pick one; if the user wants
  a second pass with the other mode, that's a separate invocation.
- Skip the critic loop. Both modes require the critic subagent — single-pass
  pattern application alone is not the skill. The critic is the unbiased
  review step. Only skip when the user explicitly says so for the current
  turn (e.g. "no critic", "skip the critic").
- Skip the hard gate. Even a one-sentence rewrite must pass `check_bans.sh`
  before being presented.
- Add new patterns that aren't in the loaded reference file. The catalogs
  are versioned; if a real new tell shows up, propose a separate edit to
  the relevant reference file, not an inline addition.
- Strip hedging from genuinely uncertain claims (especially in academic
  mode — see `patterns_academic.md` §17 and §22).
- Soften prose to address an interpretation flag from the critic. When the
  critic flags interpretation issues, fix the underlying overclaim or add
  the missing alternative explanation; do not paraphrase.
- Drop facts, names, dates, statistics, or specific claims during any
  revision. The goal is to change how things are said, not what is said.
- Silently accept a FAIL verdict from the critic after 3 iterations.
  Present the best version with the remaining flagged issues stated
  honestly.

## Reference

Both pattern catalogs trace to Wikipedia's [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing),
maintained by WikiProject AI Cleanup. The academic catalog adds patterns
specific to medical/scientific register. The critic-loop procedure
(`critic_loop.md`) adds two interpretation-honesty categories
(interpretation honesty, results-writing discipline) on top of the four
prose-style categories.
