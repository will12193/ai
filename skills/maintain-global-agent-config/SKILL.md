---
name: maintain-global-agent-config
description: "Rules for evolving William's GLOBAL agent files in ~/.copilot (instructions/ and skills/): when to add or change a rule or skill, what scope belongs there, and the mandatory disclosure and sync steps. Use when: the user says 'you should always...', 'never...', 'from now on', corrects a wrong assumption or preference that applies to all repos, a knowledge gap or recurring pattern is discovered that is relevant to all coding regardless of repo, or you are about to create/edit/delete any file under ~/.copilot/instructions or ~/.copilot/skills."
---

# Maintaining the global agent files

Companion to `~/.copilot/instructions/coding-agents.instructions.md` (global rules and skill map); this file covers *when and whether* to change a global file and the duties that follow. Structure and sizing rules are in `maintain-authoring-agent-instructions-and-skills`; the backup/sync mechanics are in `maintain-ai-hub-backup-repo`.

The global files live in `~/.copilot/instructions/` and `~/.copilot/skills/`. They are loaded alongside repo-specific instruction and skill files (e.g. a project's own `copilot-instructions.md` or `platform-api-*` skills). They should evolve as knowledge gaps and preferences are discovered, so the next session doesn't have to rediscover them.

## Scope: global only

Only maintain files in `~/.copilot/instructions/` and `~/.copilot/skills/` (including this skill and `coding-agents.instructions.md`).

- **Never** edit a repo's own instruction or skill files from this skill. If a lesson belongs to one repo, follow that repo's own maintenance rules (or tell the user) instead.
- **Add here** only what is relevant to all coding, regardless of repo. Example: the user says "you should always do X"; if X applies to every repo, it goes in global files; if X is about one codebase, it doesn't.
- When unsure whether something is global or repo-specific, ask the user.

## Where things go

- `instructions/coding-agents.instructions.md`: short rules that must apply to every session (always loaded, so keep it lean). Behaviours, communication preferences, universal coding preferences.
- A new or existing skill under `skills/`: anything procedural, situational or long. Prefer a skill over growing the always-loaded instructions.
- Maintenance rules like these belong in this skill, not in the instructions.
- For how to structure, size and scope instruction files and skills (lean always-loaded instructions that orchestrate scoped skills), load `maintain-authoring-agent-instructions-and-skills`.
- `~/.copilot/mcp-config.json`: only change when asked.

## When to add an entry

- The user states a preference or rule ("always", "never", "from now on").
- The user corrects a wrong assumption that would recur in any repo.
- You spent several tool calls working out a cross-repo pattern or command that isn't documented.
- You hit a problem whose cause/fix wasn't obvious and would recur elsewhere.

Don't document one-off trivia.

## How

- Extend an existing section or file over adding a new one.
- Keep entries short: rule, and for gotchas symptom / cause / fix. Include exact error text so future greps match.
- You have freedom to learn the user's coding preferences and to create new skills on your own initiative when a skill is clearly applicable (e.g. a repeated multi-step workflow). Keep new skills focused, with a trigger-rich `description`.
- Delete or fix entries that turn out to be wrong or obsolete.

## Mandatory: tell the user, every time

These files sit outside version control from the user's point of view, so they won't know about changes unless told. **Never change, create, rename or delete any global file without explicitly telling the user in chat.**

At the **end** of the final message of the turn, add a section with this header:

```
## Global Agent Behaviour Change
```

List each file touched, what changed (added / modified / removed) and why, in a line or two each. If the turn changed nothing global, omit the section.

## Mandatory: sync after every change

After any change to the global files, back up with the `maintain-ai-hub-backup-repo` skill: run `~/dev/ai/sync.sh "<what changed and why>"`, which regenerates the README tables, commits and pushes. Confirm it printed `Backed up.` and mention the sync in the Global Agent Behaviour Change section.

## Maintaining This Skill File

Update this file when the user changes the rules for what counts as global, how changes must be disclosed, or what must happen after a change. Keep entries short.
