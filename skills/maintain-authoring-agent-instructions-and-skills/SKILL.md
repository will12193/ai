---
name: maintain-authoring-agent-instructions-and-skills
description: "How William likes agent instruction files and skills structured: one lean always-loaded instruction file that orchestrates scoped, self-maintaining skills. Use when: creating, restructuring, splitting, trimming or reviewing any instruction file (.instructions.md, copilot-instructions.md, AGENTS.md) or SKILL.md, in any repo or globally; deciding whether content belongs in the instruction file or a skill; setting up agent files for a new repo; the instruction file is getting long. Distilled from the platform-api setup."
---

# Authoring instruction files and skills

Model: **one instruction file orchestrates; skills hold the depth.** This keeps context small and each topic independently maintainable. Reference implementation: `~/dev/platform-api/.github/instructions/platform-api.instructions.md` plus `.github/skills/platform-api-*/`.

For *where* global files live and the disclosure/sync duties when editing `~/.copilot`, see `maintain-global-agent-config`. This skill is about structure and content.

## 0. Where knowledge lives

Concrete coding conventions, domain knowledge and gotchas belong in the **repo that uses them**, in that repo's instruction file and skills. The global layer (`~/.copilot`) does not collect them; its job is to **orchestrate**: hold cross-repo behaviours and preferences, and define how every repo's agent files are structured and maintained so knowledge is gathered inside each repo in a consistent shape. When in doubt, push structure down into the repo rather than pulling conventions up to global.

## 1. Context efficiency (the main constraint)

- The instruction file (`applyTo: "**"`) is loaded **every session**. Every line costs context on every task. Keep it compact: target roughly 150-300 lines, and shrink it whenever it grows.
- Skills load **on demand** by `description` match, so they can be long and detailed.
- The instruction file must still carry the **essential patterns** (the things needed on almost every task) or else point to the skill that does. Never leave an essential pattern undocumented and unreferenced.
- Test for each piece of content: *"Is this needed on most tasks?"* Yes → instruction file (tersely). No, only for one area/situation → skill, with a one-line pointer.
- Prefer short rules, one code example per pattern (not several), tables for lookups. No prose that restates the code. No duplicated content between files: one home, others link by skill name.

## 2. The instruction file: orchestrator and scoper

Order of sections, matching the platform-api file:

1. **Frontmatter**: `description` (what it covers, incl. "and the skill map") and `applyTo: "**"` (or a narrower glob if truly scoped).
2. **Title + one-liner**: project identity (module/name) and where conventions live.
3. **Skills** (the skill map, near the top): one bullet per skill: `**name**` - what it covers; **load for** <specific files/tasks/errors that trigger it>. Also name the **reference implementation** (the best existing example to copy) and any blanket rule (e.g. "don't touch files outside the task").
4. **Essentials** needed on most tasks: runtime/stack facts, domain glossary, structure/layering, the 3-6 core patterns (one tight example each), helpers table, checklist for the most common task (e.g. "add a new feature").
5. **Conventions** (language/format/lint/validation commands, "before submitting" commands).
6. **Maintaining These Files** (last): see section 5.

The instruction file **scopes problems**: it tells the agent which skill to load for which kind of work, so the agent loads only what it needs.

## 3. Skills: scoped, narrow, trigger-rich

- **One skill per cohesive problem area** (e.g. query builder, tests, errors, one domain, lint recipes). Split when a skill covers two areas that would be loaded independently; merge when two are always loaded together.
- Name: repo skills use `<scope>-<area>` (e.g. `platform-api-tests`); global skills use a plain descriptive name (e.g. `health-check`), with a `maintain-` prefix for meta skills. Folder = `name`. File = `SKILL.md`.
- **`description` is the trigger.** Quote it. Say what it covers, then `Use when:` with concrete triggers: file names (`query.go`, `*_test.go`), tools/commands, symbols, and **exact error messages**. Flag outdated knowledge explicitly when relevant ("anything you remember about X is OUT OF DATE").
- Body shape:
  1. `# <Scope> — <Area> Skill` for repo skills; a plain title for global ones.
  2. **Companion line**: "Companion to `<instruction file path>`, which covers X; this file covers Y in depth." (Prevents duplication and tells the agent what it already has.)
  3. Core idea / mental model first, then reference, then gotchas.
  4. Gotchas as **symptom → cause → fix**, with the exact error text so future greps match.
  5. Worked examples/commands only where they save real effort.
  6. **Maintaining This Skill File** (last): see section 5.
- Recipe-style skills (like lint): one entry per *pattern* (not per occurrence), fixed entry format in an HTML comment, sorted, only record fixes that were verified, no file/line references (they go stale), correct wrong entries in place.
- Keep skills self-contained but link to sibling skills by name rather than copying.
- **Prompt-style skills are exempt from the body shape.** A skill that is essentially a crafted prompt (e.g. `grilling`) keeps its voice and looseness: no forced title, companion line or maintenance section. Only apply the shape to reference/procedure skills.

## 4. Where does new content go?

| Content | Home |
|---|---|
| Needed on nearly every task; short | Instruction file |
| Only for one area, file type, or situation; or long | Skill (existing if it fits, else new) |
| Verified fix for a specific tool/error | The area's recipe/gotcha section |
| Two skills both need it | One owns it; the other links |
| Instruction file over budget | Move the least-universal section into a skill, leave a pointer |

Before creating a new skill, check whether an existing one should be extended. Create a new one when the topic is distinct, would be loaded independently, and is likely to recur.

## 5. Self-maintaining files

Every instruction file and skill ends with a maintenance section so knowledge gaps get recorded where they belong:

- **Instruction file** ends with `## Maintaining These Files`: a list mapping *each* section/skill to what belongs there ("`<skill>`: anything about X"), then:
  - **When to add an entry**: spent several tool calls working out an undocumented pattern/command; hit a bug whose cause/fix wasn't obvious; found a convention/helper/env var likely to recur; the user corrected a wrong assumption.
  - **How**: extend an existing section over adding a new one; short entries (symptom, cause, fix); exact error text; no one-off trivia.
- **Each skill** ends with `## Maintaining This Skill File`: "Update this file (not the instructions files) when you discover <its kinds of things>. Keep entries short: symptom, cause, fix."
- **Scope strictly.** A file's maintenance rules cover only the files in its own scope. A repo's files maintain that repo's files; the global files maintain only global files. Never edit another scope's files; tell the user instead.
- Adding a skill means updating the instruction file's **Skills** list and **Maintaining** list in the same change.

## 6. Creating a new setup (checklist)

1. Decide scope (global `~/.copilot/` vs a repo's `.github/`) and follow that scope's maintenance rules and disclosure duties.
2. Draft the instruction file: skill map first, essentials, conventions, maintaining section. Keep it lean.
3. Identify areas that are situational or long; make each a skill with a trigger-rich `description`, companion line and maintenance section.
4. Cross-check: every skill is in the skill map and maintaining list; no duplicated content; the instruction file still carries (or points to) every essential pattern.
5. Re-read the instruction file as a fresh agent: can it tell what to load for a given task? Trim anything not needed on most tasks.
6. For a global change: disclose under `## Global Agent Behaviour Change` and run `sync.sh "<why>"` (see `maintain-ai-hub-backup-repo`).

## 7. Bootstrapping a repo that has no agent files

Trigger: you learned something repo-specific worth recording and the repo has no instruction file or skills.

1. **Do not create files unasked.** Tell the user what you learned and offer to bootstrap the repo's agent files. Repo files get committed to their history, so this is their call.
2. If they agree, create the **minimal** set in the standard layout:
   - `.github/instructions/<repo>.instructions.md` with `applyTo: "**"`: identity one-liner, Skills section (may be empty with a note), 3-6 essentials you actually know, and the Maintaining These Files section. Target under 60 lines; it grows later.
   - A skill under `.github/skills/<repo>-<area>/SKILL.md` **only** if the lesson is clearly situational or long; otherwise record it in the instruction file.
3. Record the lesson, then stop; don't speculate about conventions you haven't observed.
4. If the repo already uses another convention (`AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`), add to that instead of introducing a second layout, and tell the user.

Standard layout for all repos: `.github/instructions/*.instructions.md` and `.github/skills/<name>/SKILL.md`, as in platform-api.

## Maintaining This Skill File

Update this file (and nothing outside the global scope) when William states a new preference about how agent files should be structured, sized or scoped, or when a structure turns out to work badly in practice. Keep entries short.
