# ai

My AI hub: a backup of my global Copilot CLI customisation, and the place where the structure for scaling agent knowledge across my repos is defined.

`~/.copilot` is the source of truth; this repo is overwritten from it by `sync.sh`. Concrete coding conventions live in each repo's own agent files; the global layer here holds cross-repo behaviours and the rules for how those repo files are structured and maintained.

## How it works

1. Change things in `~/.copilot` (never directly in `skills/`, `instructions/` or `mcp-config.redacted.json` here; `sync.sh` refuses to run if they have uncommitted edits).
2. Run `./sync.sh "what changed and why"`. It copies the config, regenerates the tables below from each file's frontmatter, scans for secrets, then commits with that message and pushes. With no argument the message is `Backup <date>`.

The hand-written parts of this README, `sync.sh` and `.gitignore` live only in this repo and are edited here.

To restore, copy `skills/` and `instructions/` back into `~/.copilot/` and re-add secrets to `mcp-config.json` by hand.

## What's in here

<!-- BEGIN GENERATED -->
### Instructions (`instructions/`)

| File | Summary | applyTo |
|---|---|---|
| `coding-agents.instructions.md` | William's personal general-purpose rules for all coding agents, plus the map of his global skills. Always apply, in every repo. | none (always loaded) |

### Skills (`skills/`)

| Skill | Summary | Load when |
|---|---|---|
| `align-repo-agent-files` | Bring the current repo's instruction files and skills in line with William's authoring conventions without losing existing knowledge. | the user says 'align this repo', 'restructure this repo's agent files', 'bring the repo's skills/instructions up to my conventions', or asks to tidy, split or standardise a repo's existing instruction and skill files. |
| `diff-code-review` | Review the code changes on the current branch (git diff against a base branch, default origin/master) for performance, bug risks, security, code quality, regressions and best practices. | the user asks to review the branch, review the diff, review their changes before opening an MR, or says 'diff code review' / 'code review this branch'. |
| `gitlab-mr-summary` | Generate a GitLab merge request title, summary and manual test plan from the git diff of the current branch against a base branch (default origin/master). | the user asks for an MR description, MR summary, merge request text, PR description, or a test plan for their branch. |
| `grilling` | Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases. |  |
| `health-check` | Report honestly what the agent currently has in its context: instruction files loaded (grouped by level: global, repo, other), skills available, and relevant session state. | the user says 'health check', 'health-check', '/health-check', 'what do you have loaded', 'what instructions/skills do you have', 'what's in your context', or asks for a status of the session. |
| `maintain-ai-hub-backup-repo` | Maintain the user's AI hub backup repo (~/dev/ai, GitHub will12193/ai) that mirrors ~/.copilot. | the user asks to add, change, rename or remove any Copilot skill, instruction, or MCP config; mentions the 'ai hub', 'ai repo', 'sync.sh', or backing up Copilot config; or after any edit under ~/.copilot/skills or ~/.copilot/instructions. |
| `maintain-authoring-agent-instructions-and-skills` | William's preferences for how agent instruction files and skills are structured, sized and scoped: one lean always-loaded instruction file that orchestrates scoped, self-maintaining skills. | deciding whether content belongs in the instruction file or a skill; splitting, trimming or restructuring agent files; the instruction file is getting long; setting up agent files for a repo that has none; reviewing agent files against these preferences. This is a policy layer: it does not cover file-format mechanics (frontmatter syntax, applyTo globs, debugging why a file isn't loaded), which belong to any built-in customization tooling. Distilled from the platform-api setup. |
| `maintain-global-agent-config` | Rules for evolving William's GLOBAL agent files in ~/.copilot (instructions/ and skills/): when to add or change a rule or skill, what scope belongs there, and the mandatory disclosure and sync steps. | the user says 'you should always...', 'never...', 'from now on', corrects a wrong assumption or preference that applies to all repos, a knowledge gap or recurring pattern is discovered that is relevant to all coding regardless of repo, or you are about to create/edit/delete any file under ~/.copilot/instructions or ~/.copilot/skills, regardless of which tool or skill makes the edit. This is a policy layer (when/whether to change, disclosure, sync); it does not cover file-format mechanics, which belong to any built-in customization tooling. |
<!-- END GENERATED -->

### Other files

- `mcp-config.redacted.json` - MCP server layout with all env/header values redacted.
- `sync.sh` - copy, regenerate README tables, secret-scan, commit and push.

Session history, databases and logs are deliberately not backed up.
