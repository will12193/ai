# ai

Backup of my Copilot CLI customisation. `~/.copilot` is the source of truth; this repo is overwritten from it by `sync.sh`.

## How it works

1. Change things in `~/.copilot` (never directly in `skills/`, `instructions/` or `mcp-config.redacted.json` here - they get overwritten).
2. Update this README if skills or instructions changed.
3. Run `./sync.sh`: it copies the config, scans for secrets, then commits and pushes.

`README.md`, `sync.sh` and `.gitignore` live only in this repo and are edited here.

To restore, copy `skills/` and `instructions/` back into `~/.copilot/` and re-add secrets to `mcp-config.json` by hand.

## Instructions (`instructions/`)

| File | Summary |
|---|---|
| `coding-agents.instructions.md` | My personal general-purpose rules for all coding agents (`applyTo: **`). Currently: when waiting on something slow (tests, builds, etc.), tell me in chat that it is waiting, what for, and a rough time estimate. |

## Skills (`skills/`)

| Skill | Summary |
|---|---|
| `diff-code-review` | Reviews the current branch's diff against a base branch (default `origin/master`) for performance, bugs, security, quality and regressions. |
| `gitlab-mr-summary` | Writes a GitLab merge request title, summary and manual test plan from the branch diff. |
| `grilling` | Interviews me in rounds of numbered questions (with recommended answers) to stress-test a plan or idea. |
| `maintain-ai-hub` | Rules for maintaining this repo: edit `~/.copilot` first, update this README, then run `sync.sh`. |

## Other files

- `mcp-config.redacted.json` - MCP server layout with all env/header values redacted.
- `sync.sh` - copy, secret-scan, commit and push.

Session history, databases and logs are deliberately not backed up.
