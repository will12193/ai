---
description: "William's personal general-purpose rules for all coding agents, plus the map of his global skills. Always apply, in every repo."
---

# Personal rules for all coding agents

Global rules that apply in every repo, alongside whatever instructions the current repo provides. Repo rules win on repo-specific matters.

Health-check sentinel: journey before destination

## Global skills

Global skills live in `~/.copilot/skills/<name>/SKILL.md`. Load the one that matches the work:

- **`health-check`**: load when asked "health check" / what's loaded / what's in your context.
- **`grilling`**: load when asked to grill, stress-test or interrogate a plan or idea.
- **`diff-code-review`**: load when asked to review the branch/diff/changes before an MR.
- **`gitlab-mr-summary`**: load when asked for an MR/PR description, summary or test plan.
- **`maintain-global-agent-config`**: load **before** creating, editing, renaming or deleting anything under `~/.copilot` (whichever tool does it), and when I say "always", "never" or "from now on" about something that applies to all repos.
- **`maintain-ai-hub-backup-repo`**: load after any `~/.copilot` change, or when the ai hub repo / `sync.sh` comes up.
- **`maintain-authoring-agent-instructions-and-skills`**: load **before** creating or editing any instruction file or skill, in any repo or globally, even for a single added entry. It covers what belongs where, body shape, what to record, size budget and the repo boundary. Use it alongside any built-in customization tooling, which owns file-format mechanics.
- **`align-repo-agent-files`**: load when asked to align, restructure or standardise a repo's instruction files and skills to my conventions (lossless: keeps existing knowledge, applies the structure).

## Tell me when you are waiting

Whenever you have to wait on something that takes noticeable time (running tests, builds, installs, linters, long scripts, servers starting, background agents, deployments, etc.), say so in the chat window **before** you start waiting. Include:

1. **That you are waiting.**
2. **What you are waiting for** (e.g. "the full backend test suite", "`npm install`").
3. **A very rough time estimate** (e.g. "~30 seconds", "a few minutes", "5-10 minutes"). A rough guess is fine; say so if you are unsure.

Keep it to one or two lines. If the wait runs well past your estimate, post a brief update with the new estimate.

## Global files are change-controlled

Never create, edit, rename or delete anything under `~/.copilot` without telling me. Every such change must be listed under a `## Global Agent Behaviour Change` header at the end of the message and backed up with `~/dev/ai/sync.sh` (see `maintain-ai-hub-backup-repo`). No exceptions.

## Record what you learn

At the end of a substantial task, ask yourself whether you learned a rule, pattern or gotcha worth keeping. Load `maintain-authoring-agent-instructions-and-skills` first, whichever scope it lands in. If it is specific to the repo, record it in that repo's instruction/skill files under its own maintenance rules; if the repo has none, offer to bootstrap them rather than creating files unasked. If it applies to all repos, also follow `maintain-global-agent-config`.

Repo agent files are shared with other people who do not have this global layer. Write them for the team, in a neutral voice, and never reference `~/.copilot`, the ai hub repo, these global skills, or me by name. My personal preferences go in the global layer, not in repo files.

## Maintaining These Files

This file and the global skills cover the global scope only (`~/.copilot/instructions/`, `~/.copilot/skills/`); a repo's own files are maintained by that repo's rules. Before changing any global file, load `maintain-authoring-agent-instructions-and-skills` (structure and content) and `maintain-global-agent-config` (what counts as global, disclosure and sync). Adding a skill means adding it to the list above in the same change.
