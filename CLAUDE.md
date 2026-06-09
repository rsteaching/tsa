# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Project: Quarto time-series site

Non-obvious, cross-file rules for this repo. (Structure and topic content are clear from the files themselves — not repeated here.)

- **Deploy target:** `docs/` is the committed GitHub Pages output (remote `rsteaching/tsa`). Editing source is not enough — run `quarto render` so `docs/` matches, then commit both source and `docs/`.
- **Fourier video pipeline:** edit `FourierWaterfall.py` → `manim render -qh FourierWaterfall.py FourierWaterfall` → copy `media/videos/FourierWaterfall/1080p60/FourierWaterfall.mp4` to the repo root → `quarto render` (copies it into `docs/`). `/media/` is gitignored throwaway output.
- **Palette is mirrored in 3 places** — keep in sync on any colour change:
  - `ember.scss` — source of truth (Ink/Coral palette).
  - `pdf-theme.tex` — `\definecolor` hex must match ember.scss; `slidebox.tex` inherits these.
  - hardcoded hex in `FourierWaterfall.py` / other manim scripts.
- **Navbar gotcha:** raw HTML in a Quarto navbar `text:` field is escaped and renders literally — style via CSS targeting `.navbar-nav.ms-auto .nav-link` instead.
- **Mechanics:** Quarto engine `knitr`; filters `shinylive` + `slidebox.lua`; render list in `_quarto.yml`; PDF engine `lualatex`.
