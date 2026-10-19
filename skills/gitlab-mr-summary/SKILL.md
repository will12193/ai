---
name: gitlab-mr-summary
description: "Generate a GitLab merge request title, summary and manual test plan from the git diff of the current branch against a base branch (default origin/master), then offer to update the branch's existing MR with it. Use when: the user asks for an MR description, MR summary, merge request text, PR description, a test plan for their branch, or to update/refresh the MR."
---

# GitLab MR Summary

Companion to `~/.copilot/instructions/coding-agents.instructions.md` (global rules and skill map); this file is the procedure for writing a GitLab merge request description for the current branch and applying it to the existing MR.

## Steps

1. Determine the base branch: use the branch/ref the user named in their request, otherwise default to `origin/master`.
2. Run `git fetch origin` if the diff looks empty or stale, then read the changes with `git --no-pager diff <base-branch>...HEAD` and the intent with `git --no-pager log --oneline <base-branch>..HEAD`. Commit messages explain the why; the diff is the source of truth for what.
3. Write the document below.
4. Find the MR for this branch and offer to update it (next section).

## Output requirements

One markdown document with these sections, ready to paste into a GitLab MR description:

### Title

A short, descriptive title. Imperative mood.

### Summary

- Up to 2000 characters total. Use the space: a few themed bullets, each saying what changed and why it matters, rather than a terse list of one-liners.
- Lead with the main behaviour change, then notable secondary changes, then anything a reviewer must know: migrations, config/env changes, new dependencies, API or contract changes, breaking changes, follow-ups left out of scope.
- Describe functional/behavioural changes only. Do NOT mention number of lines or files changed, and don't narrate the diff file by file.

### Test Plan

- A markdown checklist (`- [ ] ...`) of manual tests.
- Each item is a concrete, actionable step with the expected result, derived from the diff. Cover the happy path, the edge cases the diff handles, and regressions in adjacent behaviour.

Output only these three sections, no other commentary.

## Updating the existing MR

Needs the `gitlab` MCP server (`@zereight/mcp-gitlab`); load its tools via tool search (`list_merge_requests`, `update_merge_request`). The older `@modelcontextprotocol/server-gitlab` can only create MRs.

1. Get the project path from `git remote get-url origin` (strip host and `.git`; use it URL-encoded as `project_id`) and the branch from `git branch --show-current`.
2. List open MRs with `source_branch` = the current branch. Exactly one: that is the MR. None: say so and offer `create_merge_request`. Several: ask which.
3. Show the document first, then ask before changing anything. On approval, call `update_merge_request` with the title and a description made of the Summary and Test Plan sections. Never update without that confirmation.
4. Report the MR URL. If the MCP tools aren't available, say so and just give the text.

## Maintaining This Skill File

Update this file (not the instructions file) when the user asks for a different MR layout, section, length limit or base-branch behaviour. Keep entries short.
