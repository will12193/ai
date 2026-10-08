---
name: align-repo-agent-files
description: "Bring the current repo's instruction files and skills in line with William's authoring conventions without losing existing knowledge. Use when: the user says 'align this repo', 'restructure this repo's agent files', 'bring the repo's skills/instructions up to my conventions', or asks to tidy, split or standardise a repo's existing instruction and skill files."
---

Bring this repo's agent files (instruction files and skills) into the shape defined by `maintain-authoring-agent-instructions-and-skills`. Load that skill first and treat it as the spec: its structure, size budget, scoping, always-on and one-way-boundary rules all apply. Don't restate them here, and don't invent conventions of your own.

The point is **restructure, not rewrite**. The existing knowledge is the valuable part; the structure is what you're fixing. If you're unsure whether a line is still true, keep it and flag it.

## Process

1. **Inventory.** Find every agent file in the repo: `.github/instructions/`, `.github/skills/`, `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md`, plus any other instruction-like files. Note each file's size, `applyTo`, whether it is discovered without a file in play, and its role. Read them all before judging anything.
2. **Assess against the spec.** For each file, where does it fall short? Typical gaps: instruction file over budget or holding situational content; no skill map; skills with weak trigger descriptions, no companion line or no maintaining section; content duplicated across files; missing `AGENTS.md` pointer; a maintaining section that doesn't map each file to its scope; references to anything outside the repo (see below).
3. **Write a ledger before moving anything.** List each distinct piece of knowledge (rule, pattern, gotcha, command, table, example) and its current home. Group by topic, not by file. This is what makes the next step provably lossless.
4. **Propose the target layout** to the user: which content stays in the instruction file (needed on most tasks, kept terse), which becomes or stays in which skill, and which new skills (if any) are justified. For each moved block say where it goes. Wait for the user's go-ahead on the layout; a restructure touches many shared files.
5. **Apply it.** Move content rather than rewriting it. Keep original wording, exact error text and code examples. Only edit text where the structure requires it: trimming prose that restates code, merging true duplicates (one home, others link by skill name), adding the skill map, companion lines, `Use when:` triggers and maintaining sections.
6. **Verify nothing was lost.** Walk the ledger: every item must still exist exactly once, or have been deliberately merged as a duplicate. Report any deletions with the reason. Re-check that every skill is in the skill map and the maintaining list, and that the instruction file is within budget.
7. **Boundary check.** Re-read every file as a teammate who has no global layer. Remove anything that references `~/.copilot`, global skills, an AI hub repo, `sync.sh`, or any individual by name. Repo files must stand alone, in a neutral team voice.
8. **Report.** What changed and why, what moved where, anything dropped or flagged as possibly stale, and any content you found that looks like a personal preference rather than a team convention, so the user can decide where it belongs.

## Constraints

- Only touch agent files (instruction files and skills). Don't change source code, config or docs.
- Don't commit or push unless asked. Leave the changes in the working tree for review.
- Don't add new knowledge you haven't verified. This is a restructure: no speculative conventions, no new claims about the codebase.
- If a repo has almost no agent files, say so and offer to bootstrap them via the authoring skill's bootstrap section instead of inventing content.
- Keep reference implementations, domain glossaries, commands and gotchas; they're the substance.

## Maintaining This Skill File

Update this file (not the authoring skill) when the user changes how a repo alignment should be run, or when a step proves unreliable. Structural rules belong in `maintain-authoring-agent-instructions-and-skills`.
