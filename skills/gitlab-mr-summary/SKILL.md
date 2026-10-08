---
name: gitlab-mr-summary
description: "Generate a GitLab merge request title, summary and manual test plan from the git diff of the current branch against a base branch (default origin/master). Use when: the user asks for an MR description, MR summary, merge request text, PR description, or a test plan for their branch."
---

# GitLab MR Summary

Companion to `~/.copilot/instructions/coding-agents.instructions.md` (global rules and skill map); this file is the procedure for writing a GitLab merge request description for the current branch.

## Steps

1. Determine the base branch: use the branch/ref the user named in their request, otherwise default to `origin/master`.
2. Run `git --no-pager diff <base-branch>` to list the changes on this branch. If the diff looks empty or stale, run `git fetch origin` first and retry.
3. From that diff, write the merge request description below.

## Output requirements

Produce a single markdown document with these sections, ready to paste directly into a GitLab merge request description:

### Title
A short, descriptive title for the merge request.

### Summary
- A concise bullet list (600 characters or less total) of the key changes in this branch.
- Do NOT mention number of lines or files changed — only describe the actual functional/behavioral changes.

### Test Plan
- A markdown checklist (`- [ ] ...`) of manual tests to verify the changes in this branch.
- Each item should be a concrete, actionable verification step derived from the diff.

Do not add any commentary outside these three sections.

## Maintaining This Skill File

Update this file (not the instructions file) when the user asks for a different MR layout, section, length limit or base-branch behaviour. Keep entries short.
