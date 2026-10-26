---
description: "William's personal general-purpose rules for all coding agents, plus the map of his global skills. Always apply, in every repo."
---

# Personal rules for all coding agents

Global rules that apply in every repo, alongside whatever instructions the current repo provides. Repo rules win on repo-specific matters.

Health-check sentinel: journey before destination

## Global skills

Global skills load from `~/.copilot/skills/<name>/SKILL.md`, which is a mirror of the ai hub repo: edit them in the repo, not there (see `maintain-ai-hub-backup-repo`). Load the one that matches the work:

- **`health-check`**: load when asked "health check" / what's loaded / what's in your context.
- **`grilling`**: load when asked to grill, stress-test or interrogate a plan or idea.
- **`diff-code-review`**: load when asked to review the branch/diff/changes before an MR.
- **`gitlab-mr-summary`**: load when asked for an MR/PR description, summary or test plan.
- **`maintain-global-agent-config`**: load **before** creating, editing, renaming or deleting anything under `~/.copilot` (whichever tool does it), and when I say "always", "never" or "from now on" about something that applies to all repos.
- **`maintain-ai-hub-backup-repo`**: load **before** editing any skill or instruction (pull first, edit in the repo, push after), after any `~/.copilot` change, or when the ai hub repo / `sync.sh` / `sync.ps1` comes up.
- **`maintain-authoring-agent-instructions-and-skills`**: load **before** creating or editing any instruction file or skill, in any repo or globally, even for a single added entry. It covers what belongs where, body shape, what to record, size budget and the repo boundary. Use it alongside any built-in customization tooling, which owns file-format mechanics.
- **`align-repo-agent-files`**: load when asked to align, restructure or standardise a repo's instruction files and skills to my conventions (lossless: keeps existing knowledge, applies the structure).
- **`windows-home-machine`**: load when setting up or maintaining my Windows home machine (Git, SSH, repo clones, WSL, Docker, storage on C:/F:), or when a Windows-specific shell or path problem comes up on it.

## My Windows home machine

When the OS is Windows (home `C:\Users\willc`):

- Repos live in `C:\Users\willc\Documents\dev` (the ai hub is `...\dev\ai`) and stay on C:. `F:\` is reserved for WSL and Docker storage only.
- The only shell is Windows PowerShell 5.1: no bash, rsync, pwsh or python. Scripts need `-ExecutionPolicy Bypass`.
- `git` may not be on PATH: use `C:\Program Files\Git\cmd\git.exe`. GitHub is over SSH (account `will12193`); never ask for a key passphrase in chat.
- The ai hub sync script here is `sync.ps1` (`sync.sh` on other machines): `pull` before editing skills or instructions, `push` after; see `maintain-ai-hub-backup-repo`.

## Tell me when you are waiting

Whenever you have to wait on something that takes noticeable time (running tests, builds, installs, linters, long scripts, servers starting, background agents, deployments, etc.), say so in the chat window **before** you start waiting. Include:

1. **That you are waiting.**
2. **What you are waiting for** (e.g. "the full backend test suite", "`npm install`").
3. **A very rough time estimate** (e.g. "~30 seconds", "a few minutes", "5-10 minutes"). A rough guess is fine; say so if you are unsure.

Keep it to one or two lines. If the wait runs well past your estimate, post a brief update with the new estimate.

## Global files are change-controlled

Never create, edit, rename or delete anything under `~/.copilot` without telling me. Every such change must be listed under a `## Global Agent Behaviour Change` header at the end of the message. Make the edit in the ai hub repo after a `pull`, then `push` with its sync script (`sync.sh`, or `sync.ps1` on Windows), which mirrors it into `~/.copilot` (see `maintain-ai-hub-backup-repo`). No exceptions.

## Record what you learn

At the end of a substantial task, ask yourself whether you learned a rule, pattern or gotcha worth keeping. Load `maintain-authoring-agent-instructions-and-skills` first, whichever scope it lands in. If it is specific to the repo, record it in that repo's instruction/skill files under its own maintenance rules; if the repo has none, offer to bootstrap them rather than creating files unasked. If it applies to all repos, also follow `maintain-global-agent-config`.

Repo agent files are shared with other people who do not have this global layer. Write them for the team, in a neutral voice, and never reference `~/.copilot`, the ai hub repo, these global skills, or me by name. My personal preferences go in the global layer, not in repo files.

## Maintaining These Files

This file and the global skills cover the global scope only (`~/.copilot/instructions/`, `~/.copilot/skills/`); a repo's own files are maintained by that repo's rules. Before changing any global file, load `maintain-authoring-agent-instructions-and-skills` (structure and content), `maintain-global-agent-config` (what counts as global, disclosure) and `maintain-ai-hub-backup-repo` (pull first, edit in the repo, push). Adding a skill means adding it to the list above in the same change.
