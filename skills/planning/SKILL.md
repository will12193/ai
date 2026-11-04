---
name: planning
description: "Plan a piece of work as a markdown plan spec saved in the repo's tmp folder, then grill William on it with the `grilling` skill before any implementation. Complements the built-in planning tools rather than replacing them. Use when: the user mentions planning in any form ('plan this', 'make a plan', 'let's plan', 'plan mode', 'how would you approach', 'write a spec for')."
---

# Planning

Companion to `grilling` (owns the interview technique) and to any built-in planning tooling (owns research and plan-mode mechanics); this file covers where the plan lives, its shape, and the plan-then-grill flow.

Planning produces a plan and agreement on it. It does **not** implement anything. Do not edit code until the user confirms the plan.

## Flow

1. **Find the home for the plan.** Use `<repo root>/tmp/`. If you are not in a repo, or the repo has no `tmp/` folder, stop and ask whether to create one and where. Do not write the plan anywhere else unasked. If `tmp/` exists but is not gitignored, say so rather than changing `.gitignore`.
2. **Ground the plan.** Read the relevant code, instruction files and skills (read-only; use the built-in research tools and subagents as usual). Look up facts yourself; only decisions go to the user.
3. **Write the plan spec** to `tmp/<short-kebab-slug>.plan.md` (reuse the file if a plan for this work already exists). Use the shape below. Put anything you could not settle from the code under **Open questions**, with your recommended answer.
4. **Grill.** Load `grilling` and run it with the plan file as the subject, seeding the first round with the Open questions and any weak points you can see (risky assumptions, unclear scope, missing edge cases, ordering problems). Follow `grilling`'s round format and rules unchanged; don't restate them here.
5. **Fold answers back in.** After each round, update the plan file: move settled questions from Open questions to **Decisions** (decision plus one-line reason) and adjust Approach/Steps to match. Keep the file the single source of truth.
6. **Finish.** When grilling's frontier is empty, summarise what changed, point to the plan file, and wait for the user's go-ahead before implementing.

## Plan spec shape

Keep it as short as the work allows; drop empty sections.

```markdown
# <Title>

## Goal
<What and why, 1-3 sentences.>

## Scope
- In: ...
- Out (non-goals): ...

## Approach
<The chosen design and why, referencing real files/symbols.>

## Steps
1. <Ordered, each small enough to verify; name the files touched.>

## Risks and edge cases
- ...

## Verification
<Tests to add or run, manual checks, lint/validation commands.>

## Decisions
- <Decision> - <reason>

## Open questions
- <Question> - recommended: <answer>
```

## Maintaining This Skill File

Update this file when William changes how plans should be stored, shaped or handed to grilling. Keep entries short.
