---
name: health-check
description: "Report honestly what the agent currently has in its context: instruction files loaded (grouped by level: global, repo, other), skills available, and relevant session state. Use when: the user says 'health check', 'health-check', '/health-check', 'what do you have loaded', 'what instructions/skills do you have', 'what's in your context', or asks for a status of the session."
---

# Health check

Companion to `~/.copilot/instructions/coding-agents.instructions.md` (global rules and skill map); this file is the report procedure.

A read-out of the agent's **own current context**, for the user. Be honest and concrete. This is a report, not a task: don't change any files and don't start other work.

## Rules

- Report what is **actually in your context right now** (system prompt, injected instruction blocks, the available-skills list, tool list). Do not infer it from what exists on disk, and do not read files to "fill in" the report. If something exists on disk but is not in your context, flag it as a mismatch; don't list it as loaded.
- Don't guess or flatter. If you can't tell whether something is loaded, say "unsure". Never claim an instruction or skill is loaded that you can't point to.
- Loaded context can be stale: instruction files are read at session start, so edits made on disk since then may not be reflected. Say so when relevant.
- Keep it compact: one line per item, no paraphrasing of whole files.

## What to report

### 1. Environment
Working directory, git repo/branch if known, OS, and the model/agent identity if known.

### 2. Instruction files loaded, grouped by level
Work out each file's level yourself from its path and content. Use these groups, in this order, omitting empty ones:

- **Global** (`~/.copilot/instructions/`, user-level, applies to every repo)
- **Repo** (the current repo's `.github/instructions/`, `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md`, etc.); name the repo it comes from
- **Other** (plugin, org, or anything you can't place)

For each: file name, one-line summary of what it tells you, and `applyTo` if present. Flag any that look like an unfilled template, are empty, duplicated, or conflict with another.

### 3. Skills on hand, grouped by level
Same grouping, from the available-skills list (use each skill's listed location: user/global, repo/project, plugin). One line each: name and a few words on what it's for. For long plugin lists, group by plugin and give a count plus the names, not descriptions.

### 4. Tools and integrations
Short summary only: which tool families are available, which are deferred (need a search first), and any MCP servers. Don't list every tool.

### 5. Session so far
If the session has been going a while (several turns or checkpoints), give a quick summary: what was asked, what was done, what is pending or in flight (todos, background agents, running processes). If the session is new, say so in one line.

### 6. Concerns
Only if there are any: stale or conflicting instructions, context-heavy files, missing expected files (e.g. a repo with no instruction file), unfilled templates, skills with overlapping names/descriptions. One line each with a suggested fix. If none, say "No concerns."

## Format

Headings for the sections above, bullets underneath. Lead with the instruction-file groups (what the user most wants to see). No preamble, no closing offer.

## Maintaining This Skill File

Update this file when the user asks for different or additional information in the report, or when a kind of context turns out to be misreported. Keep it short.
