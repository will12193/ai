---
name: maintain-ai-hub-backup-repo
description: "Maintain the user's AI hub backup repo (/Users/william/dev/ai, will12193/ai) that mirrors ~/.copilot. Use when: the user asks to add, change, rename or remove any Copilot skill, instruction, or MCP config; mentions the 'ai hub', 'ai repo', 'sync.sh', or backing up Copilot config; or after any edit under ~/.copilot/skills or ~/.copilot/instructions."
---

# Maintain the AI hub repo

`/Users/william/dev/ai` (GitHub: will12193/ai) is a **backup** of shareable Copilot config. `~/.copilot` is the source of truth; the repo is overwritten from it by `sync.sh`.

## Golden rule

Any change to files under `~/.copilot` must also follow `maintain-global-agent-config` (disclose it to the user under a "Global Agent Behaviour Change" header at the end of the message).

**Never edit `skills/`, `instructions/` or `mcp-config.redacted.json` in the repo.** Those edits are destroyed on the next sync. Change the real files in `~/.copilot` first, then sync.

| Repo path | Source of truth |
|---|---|
| `skills/` | `~/.copilot/skills/` |
| `instructions/` | `~/.copilot/instructions/` |
| `mcp-config.redacted.json` | generated from `~/.copilot/mcp-config.json` (secrets redacted) |
| `README.md`, `sync.sh`, `.gitignore` | edited directly in the repo (not synced) |

## Workflow for any requested change

1. Make the change in `~/.copilot` (skill, instruction, MCP config).
2. Update `/Users/william/dev/ai/README.md` (see below) whenever a skill or instruction file was added, removed, renamed or its purpose changed.
3. Run `/Users/william/dev/ai/sync.sh`. It copies, scans for secrets, commits (`Backup <date>`) and pushes. Do not run a separate commit/push for synced content.
   - The README is committed by the sync's `git add -A`, so edit it **before** syncing so it lands in the same commit.
   - Changes to `sync.sh`/`.gitignore` are picked up by that same commit.
4. Verify: the output says `Backed up.` (or `No changes to back up.`), and `git -C /Users/william/dev/ai status -s` is clean.
5. If sync aborts with "Possible secret found", stop, tell the user which file, and do not push.

## README requirements

`README.md` is for humans. Always keep it accurate and include:

- What the repo is and how sync/restore works.
- **Instructions**: a table or list of every file in `instructions/` with a one-line summary of what it tells the agent.
- **Skills**: a table or list of every skill in `skills/` with a one-line summary of what it does and when it triggers.
- The MCP config note (redacted) and what is deliberately not backed up.

Derive summaries from each file's frontmatter `description` and body. If an instruction file is still an unfilled template, say so plainly. When files are removed, remove their README entries.

## Don'ts

- Don't back up session history, databases, logs, or the unredacted `mcp-config.json`.
- Don't commit secrets; keep the sync's secret scan in place.
- Don't hand-edit synced files in the repo "just to be quick".
