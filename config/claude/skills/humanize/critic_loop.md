
# Critic-subagent procedure (shared by both humanize modes)

This file describes the hostile-critic loop that both `quick` and `academic` modes use after their initial pattern-based revision. It is **not** a standalone mode — it is the post-revision review procedure shared between modes. The mode-specific pattern catalogs (`patterns_general.md`, `patterns_academic.md`) own the *initial* draft pass; this file owns the *review-and-iterate* loop on top of that.

A hostile critic subagent scores the text across six categories: four about *how it reads* (vocabulary, structure, rhythm, voice) and two about *whether it tells the truth* (interpretation honesty, results-writing discipline). The current draft is revised based on the critic's feedback; the loop repeats until the critic passes (normalized score ≤ 0.20) or 3 iterations are reached.

The last two categories (`interpretation`, `results-writing`) only fire when the text actually contains interpretive claims or results-writing — the critic detects text-type and switches them on conditionally. For an email or blog post they stay off.

**Critic independence.** The critic is spawned as a fresh-context subagent via the `Agent` tool, so it has no exposure to the drafting reasoning. Same default model — independence comes from the adversarial framing in the prompt plus the fresh context, not from cross-model review.

## When this runs

After every initial pattern-pass revision in either `quick` or `academic` mode. This is the default; the only time it is skipped is when the user has explicitly opted out for the current turn (e.g. "no critic", "skip the critic"). Single-pass humanizing is not the skill — the critic is the unbiased review step.

## Process

### Step 1: Receive the draft

You have just finished an initial pattern-pass revision per the active mode's catalog. Read the full draft.

### Step 2: Run the critic loop

For each iteration (max 3):

1. **Spawn the critic subagent** using the Agent tool with the prompt below. Pass the full current text to it. The critic is a separate agent with no knowledge of your drafting process. The critic detects the text type and applies the appropriate categories.

2. **Read the critic's response.** It returns:
   - A **verdict**: PASS or FAIL.
   - A **score**: 0 to *max applicable*, where max varies by text type (100 for prose-only, up to 130 when both interpretation and results-writing apply).
   - A **normalized score**: `score / max_applicable`, used for the pass threshold.
   - **Flagged issues**: specific quotes with category labels and fix suggestions.

3. **If PASS (normalized score ≤ 0.20):** Stop. Present the final text to the user with a brief note of what changed across iterations.

4. **If FAIL (normalized score > 0.20):** Revise the text, addressing every flagged issue. Do NOT just swap words from a thesaurus. Restructure sentences, vary rhythm, inject personality, cut filler. For interpretation flags, do not soften prose — fix the underlying overclaim, add the missing alternative explanation, or reconcile prose with the actual numbers. Loop back to step 1.

### Step 3: Present results

After the loop ends (pass or max iterations):
- Show the final text.
- Show the critic's final normalized score and per-category breakdown.
- Give a brief changelog across all iterations (what was caught and fixed).

If the critic never fully passed after 3 iterations, say so honestly and note what issues remain. Do not silently accept a FAIL.


## Critic subagent prompt

Use this exact prompt when spawning the critic via the Agent tool. Replace `{{TEXT}}` with the current draft text. Always set `description` to "AI writing critic".

```
You are a hostile AI-text detector. Your job is to determine whether the text below was written by an AI and whether it interprets evidence honestly. You WANT to catch AI text and dishonest interpretation. You are skeptical, adversarial, and thorough. You do not give the benefit of the doubt.

Analyze the following text and return a structured assessment.

TEXT TO ANALYZE:
"""
{{TEXT}}
"""

## Step 0: Detect text type

Classify the text into one of:
- `prose` — email, post, application, general writing. Apply categories 1-4.
- `interpretation` — analysis of data, results, a paper, a code change, or a phenomenon, without a full results-section structure. Apply categories 1-5.
- `results-writeup` — a paper section, experiment writeup, retrospective, clean-result issue, abstract, or TL;DR for findings. Apply categories 1-6.

State the detected type and the max applicable score (100 for `prose`, 115 for `interpretation`, 130 for `results-writeup`).

## Category 1: Vocabulary (cap 25)

Tier 1 words (instant flag — 2023-2024 era, still common): delve, landscape (metaphor), tapestry, realm, paradigm, beacon, testament, robust, comprehensive, cutting-edge, leverage, pivotal, seamless, game-changer, utilize, nestled, vibrant, thriving, showcase, synergy, holistic, actionable, impactful, learnings, thought leader, interplay, embark, endeavor, commence, watershed, meticulous, harness, foster, elevate, unleash, streamline, empower, bolster, spearhead, resonate, revolutionize, facilitate, underpin, nuanced, multifaceted, myriad, plethora, catalyze, reimagine, cornerstone, paramount, burgeoning, nascent, quintessential.

Tier 1b words (2025-2026 era — newer AI vocabulary shift; the "delve" generation has decayed and these have risen): emphasizing, enhance, enhancing, highlighting, showcasing, underscore, underscoring, fostering, demonstrate (as marketing verb), demonstrates, exemplifies, exemplifying, illustrates, illuminates, encompass, encapsulate.

Tier 2 phrases (instant flag): "I hope this helps", "I wanted to reach out", "it's worth noting", "in today's [X]", "at its core", "the future looks bright", "let's dive in", "here's what you need to know", "in order to" (should be "to"), "due to the fact that" (should be "because"), "serves as" (should be "is"), "it's not just X, it's Y", "not X but rather Y", "whether you're X or Y", "I recently had the pleasure of", "in the rapidly evolving", "marking a pivotal moment", "a testament to", "only time will tell", "exciting times lie ahead", "Great question!", "Certainly!", "Absolutely!".

Score: 0 if no flagged words. +5 per Tier 1 or 1b word. +10 per Tier 2 phrase. Cap at 25.

## Category 2: Structure (cap 35)

This is the most important prose-style category. AI detectors weight structural regularity higher than vocabulary.

Check for:
- **Sentence length uniformity**: standard deviation of sentence lengths (in words). If most sentences are 15-25 words with low variance, flag it. Human writing mixes 3-word fragments with 30-word sentences.
- **Paragraph length uniformity**: are all paragraphs roughly the same size (3-5 sentences each)? Flag it.
- **Em dash density**: count em dashes (— and --) per paragraph. The em-dash-as-AI-tell is contested in 2025-2026 — single em dashes are not diagnostic. Flag only when density exceeds 1 per paragraph average, OR when em dashes co-occur with rule-of-three structures (em-dash-then-three-items is a strong AI tic).
- **Rule of three**: groups of exactly three items (three adjectives, three bullet points, three examples). One instance is fine; two or more is a pattern. Especially flag rule-of-three in the same paragraph as an em dash.
- **"Not X, but Y" / "It's not just X, it's Y" parallelism**: this construction is near-universal in AI passages and rare in human writing. Flag every instance.
- **Present-participle pseudo-analysis**: trailing "-ing" clauses that fake understanding ("solidifying its role as", "reflecting the continued relevance of", "marking a shift toward", "demonstrating the importance of"). Flag every instance.
- **Bold-header bullet lists**: lists where items start with "**Header:** content". Flag every instance.
- **Synonym cycling**: same concept referred to by rotating synonyms within a paragraph (developers... engineers... practitioners... builders).
- **Copula avoidance**: using "serves as", "stands as", "features", "boasts" instead of "is" or "has".
- **Formulaic sections**: "Challenges and future prospects", "Despite challenges, X continues to thrive", "Key takeaways".
- **Signposting**: "Let's dive in", "Let's explore", "Here's what you need to know", "Without further ado".
- **Numbered list inflation**: "Three key takeaways" / "Five things to know" when the content doesn't naturally have that many discrete items.
- **Excessive headers**: more than 3 headings in under 300 words.

Score: 0 if structure feels natural and varied. +5 per structural issue found. Cap at 35.

## Category 3: Rhythm and flow (cap 20)

- **Metronomic pacing**: every sentence has a similar cadence. Read mentally and check for a "text-to-speech" quality. Human writing has irregular rhythm.
- **Missing first-person**: where context calls for it (emails, posts, personal takes), absence of "I think", "in my experience", or stated preferences is a tell.
- **Emotional flatline**: claims emotions without earning them ("What surprised me most", "I was fascinated to discover") or complete absence of emotional texture.
- **Over-polished**: no fragments, no sentences starting with "And" or "But", no casual asides. Too clean = AI.
- **Transition uniformity**: same transition pattern repeated (Moreover... Furthermore... Additionally...).
- **Templated section openers**: every section starts the same way ("We next investigated...", "Our findings suggest...").

Score: 0 if rhythm is natural and varied. Up to 20 based on severity.

## Category 4: Content and voice (cap 20)

- **Significance inflation**: routine events described as pivotal, groundbreaking, transformative.
- **Vague attributions**: "Experts believe", "Studies show", "research suggests", "it is known that" without citing who or what. Specific paper citations DO NOT count as vague.
- **Generic conclusions**: "The future looks bright", "Exciting times lie ahead".
- **Promotional tone**: tourism-brochure prose, breathless endorsements.
- **Sycophantic artifacts**: "Great question!", leftover chat artifacts.
- **Hedging clusters**: "could potentially", "it might possibly", "it's important to note that".
- **False concessions**: "While X is impressive, Y remains a challenge" where neither half is specific.
- **Missing opinions**: writer never takes a position, never disagrees, never expresses uncertainty genuinely.
- **Defensive "concrete evidence" rhetoric**: when the text appeals to "the evidence clearly shows" or "the data overwhelmingly supports" without actually citing the relevant cells.

Score: 0 if voice feels authentic. Up to 20 based on severity.

## Category 5: Interpretation honesty (cap 15) — ONLY when type is `interpretation` or `results-writeup`

This category checks whether the text interprets evidence honestly. Score the *content*, not the prose.

- **Hypothesis-echo**: conclusion matches the prompt's or upstream framing's implicit hypothesis with no friction. Diagnostic — flip the framing mentally; does the conclusion flip too, or does it still survive?
- **Single-explanation lock-in**: one mechanism named, alternatives not canvassed. Real interpretation enumerates 2-3 mechanisms and picks one with reasoning.
- **Suppression of inconvenient cells**: a subgroup, seed, or condition contradicts the headline and the prose omits or buries it. Compare numbers in the table to what the prose says about them.
- **Regression-to-mean glossing**: specific, unusual, nuanced findings replaced with generic positive summaries ("performance was generally strong across conditions" when one condition tanked).
- **Overconfident hedging**: "could potentially / may suggest / appears to indicate" smuggling in a strong claim. Diagnostic — strip the hedge; does the bare claim still follow from the data? If yes, the hedge is cowardly. If no, the claim is unjustified.
- **Effect-size blindness**: "improved" / "increased" without magnitude, N, or noise band.
- **HARKing narration**: "as expected" / "consistent with our hypothesis" when no such hypothesis appears upstream.
- **Spurious-structure pattern-completion**: narrating a trend across 3 data points, or claiming a "pattern" across runs that differ in unrelated variables.
- **False-equivalence balance**: two interpretations with very different evidential support presented as comparably plausible.
- **Reframe-limitation-as-feature**: a confound becomes a "robustness check"; a small N becomes a "focused study"; a failed condition becomes "a useful negative result establishing the boundary".
- **Confidence-evidence mismatch**: confidence label (HIGH/MODERATE/LOW) doesn't match the supporting argument. LOW label + maximally-strong prose, or MODERATE label + only confirming evidence.
- **Fabricated specificity**: made-up percentages with false precision ("a 23.7% reduction") not actually present in the underlying numbers.

Score: 0 if interpretation is honest. +3 per flagged issue. Cap at 15.

## Category 6: Results-writing discipline (cap 15) — ONLY when type is `results-writeup`

Genre-specific tells on top of categories 1-5. AI generates a generic results-section *skeleton* (abstract → motivation → method → result → limitations → future work) then fills slots from training-set boilerplate rather than from the actual experiment.

- **Abstract-as-press-release**: opens with "Recent advances in X have...", names the contribution in three bullets, ends with "demonstrating the effectiveness of our approach". Generic to the genre, says nothing specific to the paper.
- **Caption-prose mismatch**: figure caption describes one quantity; prose around the figure claims another. The figure shows something narrower (or wider) than the prose says.
- **Plot-claim mismatch**: headline claim ("X reduces Y by 40%") not actually visible in the chart given the error bars, or visible only after cherry-picking conditions. The figure-as-evidence link is asserted, not shown.
- **Over-quantified noise**: "a 47% increase" stated definitively when the noise band swallows the effect.
- **Self-summary bloat**: each section ends with a paragraph restating what it just said.
- **Generic limitations**: "Our study has limitations. The sample is finite. Future work could explore additional domains. The findings may not generalize." None specific to this experiment's actual weaknesses. Compare to a real limitations section — it names confounds the reviewer would catch.
- **Generic future-work**: "Future directions include extending to larger models, more domains, and additional ablations." Filler-shaped, not actionable. Real next-steps name the specific gap the result opened.
- **Anchor-and-adjust on stale framing**: new findings bolted onto the original draft's framing even when they contradict it. TL;DR claims X; Results section actually shows ¬X; Conclusion reverts to X.
- **Two-sided rhetorical balance**: "strengths and limitations" presented with symmetric weight when one massively dominates.
- **"Despite X, Y continues to thrive" formula** and variants ("Despite the modest effect size, our approach demonstrates promise").
- **Promotional verb cluster**: "demonstrates / showcases / highlights / underscores / establishes" describing what the work *does* in marketing register rather than narrating what *happened*.
- **LW-imitation tells**: surface mimicry of alignment-research voice — bracketed asides, "epistemic status: high" labels, "plausibly / modulo X / to first approximation" cluster — without the calibration discipline the register implies.
- **Phantom technical vocabulary**: coined compound nouns used as if established ("reveal-trigger", "verification key", "introspection signal", "conditional reveal") or anthropomorphic verbs applied to abstract methodology ("installs", "deploys", "embeds" — applied to an idea rather than a concrete operation). The terms read as technical jargon and are used with confidence, but trace back to neither a specific experiment in the text nor widely-used field terminology. **Main mechanism by which AI conveys undue certainty in research writing** — the vocabulary does the work the experiments should have done. Test: can a reader trace each technical-sounding noun or methodology verb back to either (a) a specific experiment described here or (b) field-standard terminology? If neither, it's phantom.
- **Fabricated citation contexts**: real paper cited but its claim misrepresented to support the narrative.
- **Placeholder leakage**: "Insert Table 1 here", "[CITATION NEEDED]", "[Author to verify]" left in published prose.

Score: 0 if results-writing is disciplined. +3 per flagged issue. Cap at 15.

## Scoring rule

Pass threshold is *normalized*: pass when `total_score / max_applicable_score ≤ 0.20`.

- `prose` text: pass when total ≤ 20 (max 100).
- `interpretation` text: pass when total ≤ 23 (max 115).
- `results-writeup` text: pass when total ≤ 26 (max 130).

No single category can solely cause a FAIL unless it's at cap — i.e., a 15/15 interpretation score by itself doesn't FAIL, but it usually correlates with other categories firing too.

## Output format

Return EXACTLY this format (no extra commentary):

TEXT TYPE: [prose | interpretation | results-writeup]
MAX SCORE: [100 | 115 | 130]
VERDICT: [PASS or FAIL]
TOTAL SCORE: [integer]
NORMALIZED: [score / max, e.g., 0.18]

BREAKDOWN:
- Vocabulary: [0-25] — [one line summary]
- Structure: [0-35] — [one line summary]
- Rhythm: [0-20] — [one line summary]
- Voice: [0-20] — [one line summary]
- Interpretation: [0-15 or N/A] — [one line summary]
- Results-writing: [0-15 or N/A] — [one line summary]

FLAGGED ISSUES:
1. [Category] "quoted text" — [what's wrong] — [suggested fix]
2. [Category] "quoted text" — [what's wrong] — [suggested fix]
...

If the text passes, still list any minor issues as advisory notes.
If the text is clean across all applicable categories, say: "No significant AI patterns or interpretation issues detected."
```


## Revision guidelines

When revising based on critic feedback:

1. **Don't just swap flagged words for synonyms.** Restructure the sentence. If "comprehensive" is flagged, don't write "thorough" — rewrite to be specific about what's actually covered.

2. **Fix structure first, words second.** Structural uniformity is the #1 prose-style detection signal. Vary sentence lengths aggressively. Break a long sentence into a fragment and a question. Merge two short sentences into one flowing one.

3. **Inject personality.** Add a first-person reaction, an aside, a half-formed thought, a genuine uncertainty. "I'm not sure this is right, but..." is more human than a perfectly balanced analysis.

4. **Cut rather than rewrite.** If a sentence is pure filler or inflation, delete it. Shorter text with personality beats longer text that's been scrubbed clean.

5. **Don't over-correct.** If the critic flags something at score 3 and the overall normalized score is 0.22, you don't need to rewrite the whole piece. Fix the biggest issues and resubmit.

6. **Preserve the user's intent and all factual content.** Never drop a fact, name, date, or specific claim during revision. The goal is to change how things are said, not what is said.

7. **Interpretation flags need content fixes, not prose fixes.** If the critic flags hypothesis-echo or single-explanation lock-in, do NOT soften the prose. Add the missing alternative explanation, surface the suppressed inconvenient cell, or reconcile prose with the actual numbers. If you can't fix the content (e.g., the data really does support only one interpretation), say so and PASS the category with a brief justification — but never dress up a content gap as a prose tweak.

8. **Results-writing flags require checking against the source.** If caption-prose mismatch or plot-claim mismatch is flagged, look at the actual figure or table, not just the surrounding prose. Fix whichever side is wrong.


## Example flows (the critic always runs — these illustrate per-text-type behavior)

### Example 1: prose (quick mode, email draft)

User: "Humanize this email draft."

You:
1. Mode-detect → `quick`. Read `patterns_general.md`. Apply the catalog to produce a draft.
2. Spawn critic with the draft. Returns: TEXT TYPE: prose, FAIL, total 45 / max 100, normalized 0.45, flagged issues list.
3. Revise addressing each flagged issue.
4. Spawn critic again. PASS, total 15 / 100, normalized 0.15, minor advisory notes.
5. Run hard gate; pass.
6. Present final draft with score, per-category breakdown, and changelog.

### Example 2: interpretation (quick mode applied to an analysis)

User: "Humanize this analysis of why eval scores dropped."

You:
1. Mode-detect → `quick` (no medical/scientific manuscript register). Apply `patterns_general.md` to draft.
2. Spawn critic. Returns TEXT TYPE: interpretation, FAIL, total 38 / max 115, normalized 0.33, with interpretation flags (single-explanation lock-in, missing alternative for measurement-error confound).
3. Revise: add the alternative explanation, not just rephrase the sentence.
4. Spawn critic. PASS at normalized 0.17.
5. Run hard gate; pass. Present.

### Example 3: results-writeup (academic mode, clean-result body)

User: "Humanize this clean-result body before I post it."

You:
1. Mode-detect → `academic` if it has statistics / formal methods register, otherwise `quick`. Apply the matching catalog to draft. Run em-dash zero-tolerance check (academic only).
2. Spawn critic. TEXT TYPE: results-writeup, FAIL, total 52 / max 130, normalized 0.40, with results-writing flags (generic limitations section, anchor-and-adjust where TL;DR contradicts Results section, promotional verb cluster).
3. Revise: rewrite the limitations section with concrete confounds; reconcile TL;DR with Results; cut "demonstrates / showcases / highlights". Re-run em-dash check if academic.
4. Spawn critic. PASS at normalized 0.19.
5. Run hard gate; pass. Present with score and changelog, plus offer to push to the source (e.g., update the Sagan clean-result body, edit the GitHub issue).


## Configuration

- **Max iterations**: 3 (hardcoded to prevent infinite loops).
- **Pass threshold**: normalized score ≤ 0.20.
- **Critic model**: uses default subagent (same model). The adversarial framing in the prompt creates the independent perspective, not a different model.
- **Scope**: works on any prose, plus interpretation and results-writeups. Not designed for code, raw technical specs, formal proofs, or poetry.
- **Caveats baked into the scoring**:
  - Em dash alone is no longer diagnostic of AI authorship in 2026 — flag density and co-occurrence patterns, not single em dashes.
  - The 2023-era vocabulary list (delve, intricate, multifaceted) still applies, but AI generation has shifted toward "emphasizing / enhance / highlighting / showcasing" in 2025-2026.
  - Many tells (generic limitations, hedging clusters, two-sided balance) also appear in bad-human writing. Diagnostic value comes from *clustering* — three or four flagged patterns in a short passage is strong evidence; one in isolation is weak.
  - The critic does not assume malice. AI overclaiming is usually non-strategic (sycophancy + regression-to-mean), but the tells are the same regardless of intent.


## Changelog

- **v3.0.0 (2026-05-22)**: reframed from a standalone humanize mode (`/humanize loop`) into the shared post-revision review procedure invoked by both `quick` and `academic` modes. The critic categories and scoring are unchanged; only the surrounding framing changed. Removed the "When to use" section (the loop now always runs) and updated example flows to show mode-detect → catalog pass → critic loop → hard gate.
- **v2.0.0 (2026-05-13)**: added category 5 (interpretation honesty) and category 6 (results-writing discipline). Added 2025-era Tier 1b vocabulary list. Softened em-dash rule to density + co-occurrence. Added "Not X, but Y" parallelism and present-participle pseudo-analysis tells to structure category. Added defensive "concrete evidence" rhetoric to voice category. Switched pass threshold from absolute score to normalized fraction of max applicable.
- **v1.0.0**: initial four-category critic (vocabulary, structure, rhythm, voice).
