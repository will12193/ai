---
description: "William's personal general-purpose rules for all coding agents, plus the map of his global skills. Always apply, in every repo."
applyTo: "**"
---

# Personal rules for all coding agents

Global rules that apply in every repo, alongside whatever instructions the current repo provides. Repo rules win on repo-specific matters.

## Global skills

Global skills live in `~/.copilot/skills/<name>/SKILL.md`. Load the one that matches the work:

- **`health-check`**: load when asked "health check" / what's loaded / what's in your context.
- **`grilling`**: load when asked to grill, stress-test or interrogate a plan or idea.
- **`diff-code-review`**: load when asked to review the branch/diff/changes before an MR.
- **`gitlab-mr-summary`**: load when asked for an MR/PR description, summary or test plan.
- **`maintain-global-agent-config`**: load **before** creating, editing, renaming or deleting anything under `~/.copilot`, and when I say "always", "never" or "from now on" about something that applies to all repos.
- **`maintain-ai-hub-backup-repo`**: load after any `~/.copilot` change, or when the ai hub repo / `sync.sh` comes up.
- **`maintain-authoring-agent-instructions-and-skills`**: load when creating, restructuring or reviewing any instruction file or `SKILL.md`, in any repo.

## Tell me when you are waiting

Whenever you have to wait on something that takes noticeable time (running tests, builds, installs, linters, long scripts, servers starting, background agents, deployments, etc.), say so in the chat window **before** you start waiting. Include:

1. **That you are waiting.**
2. **What you are waiting for** (e.g. "the full backend test suite", "`npm install`").
3. **A very rough time estimate** (e.g. "~30 seconds", "a few minutes", "5-10 minutes"). A rough guess is fine; say so if you are unsure.

Keep it to one or two lines. If the wait runs well past your estimate, post a brief update with the new estimate.

## Global files are change-controlled

Never create, edit, rename or delete anything under `~/.copilot` without telling me. Every such change must be listed under a `## Global Agent Behaviour Change` header at the end of the message and backed up with `~/dev/ai/sync.sh` (see `maintain-ai-hub-backup-repo`). No exceptions.

## Record what you learn

At the end of a substantial task, ask yourself whether you learned a rule, pattern or gotcha worth keeping. If it is specific to the repo, record it in that repo's instruction/skill files under its own maintenance rules. If it applies to all repos, follow `maintain-global-agent-config`.

## Maintaining These Files

This file and the global skills cover the global scope only (`~/.copilot/instructions/`, `~/.copilot/skills/`); a repo's own files are maintained by that repo's rules. Before changing any global file, load `maintain-global-agent-config`: it says what belongs where and how to disclose and sync. Adding a skill means adding it to the list above in the same change.
