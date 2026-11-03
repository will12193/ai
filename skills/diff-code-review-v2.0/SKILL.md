---
name: diff-code-review-v2.0
description: "Exhaustive v2.0 review of the code changes on the current branch (git diff against a base branch, default origin/master): reports every confirmed issue with a severity tag, reviewing file by file. Use when: the user explicitly asks for 'diff code review v2', 'diff-code-review-v2.0' or 'exhaustive diff review'. For a plain 'review the branch/diff', use `diff-code-review` instead."
---

# Diff Code Review v2.0

Companion to `~/.copilot/instructions/coding-agents.instructions.md` (global rules and skill map); this file is the procedure for reviewing a branch diff. It is a stricter variant of `diff-code-review`: same criteria, but exhaustive. Review the code changes on the current branch against a base branch.

## Core rules

- **Report every confirmed issue.** Never cap, truncate or summarise the list to a "top N". Order by severity within each heading instead of dropping lower-severity items.
- **Tag every finding** with a severity: `blocker` (will break behaviour, lose data or open a vulnerability), `should-fix` (real defect or clear risk, not immediately breaking), `nit` (style, naming, minor cleanup).
- **The checklist is a floor, not the whole review.** Issues found outside the checklist are reported too.

## Steps

1. Determine the base branch: use the branch/ref the user named in their request, otherwise default to `origin/master`.
2. Get the diff against the base branch:
   - 2a. Run `git --no-pager diff <base-branch>` to get the full list of changes.
   - 2b. If the output is empty or looks stale, run `git fetch origin` first, then re-run the diff.
   - 2c. If the diff command fails or the base branch cannot be resolved after fetching, stop and report the exact error to the user with the suggestion to verify the base branch name.
3. Do a first pass over the diff to understand what the changes are actually doing: what files/areas are touched, what kind of change each one is (new feature, refactor, bug fix, config change, dependency bump, etc.), and note anything that looks glaring or immediately suspicious. List the changed files; this list drives step 5.
4. Based on that first pass, generate a concrete checklist of potential issues to investigate, informed by the type of each change and how the surrounding (unchanged) code in those areas behaves. Read the surrounding code where needed to understand context. Each item should be specific (e.g. "new endpoint in X does not appear to validate the `id` param before use in a query" rather than "check for injection").
5. Review **file by file**. For each changed file, read all of its diff hunks in full (use per-file diffs if the combined diff is too large to read reliably), apply the relevant checklist items, and also look for anything the checklist did not anticipate. Record every issue found (with severity) before moving to the next file. Do not sample or skip files; later files get the same attention as earlier ones. For a very large diff, split the files into groups, review each group the same way, then merge the findings.
6. Assess test coverage: note which tests (if any) were added or changed in the diff, and identify behaviour in the changed code that no test exercises, noting at which level (in-package unit vs full-scale integration) existing coverage sits, if any.
7. Review the changed code against the criteria below, incorporating the findings from steps 5 and 6. Only report issues found in the changed code itself: unchanged code read for context in steps 4-5 is for understanding only, not for reporting.
8. **Completeness pass.** Re-scan every hunk once more against the criteria below for anything not yet recorded, and add it. Then de-duplicate (merge findings that share a cause; list each affected location).

## Review criteria

For each issue found, cite the file and approximate location, give the severity tag, explain the concern, and suggest a concrete fix. Group findings under these headings:

- **Performance issues**: inefficient algorithms, unnecessary allocations/queries, N+1 patterns, blocking calls on hot paths.
- **Bug risks**: potential for panics, nil dereferences, unhandled errors, race conditions, memory leaks, incorrect logic, off-by-one errors, etc.
- **Security vulnerabilities**: OWASP Top 10 concerns, injection, unsafe deserialization, missing authz/input validation, secrets in code.
- **Code quality**: readability, duplication, error handling, naming, dead code.
- **Potential Regressions**: changes that could break existing functionality, including API changes, altered behaviour of existing functions, and changes to data structures.
- **Best practices**: idiomatic use of the language/framework, consistency with existing patterns in the surrounding code and any repo-level instructions or skills (e.g. `.github/instructions/`, `.github/skills/`).
- **Missing tests**: recommend specific tests the diff should include but doesn't. Check which test files the diff touches and which existing tests cover the changed code, then list each gap as a concrete test. Prioritise gaps by risk, and follow the repo's test conventions (e.g. `.github/skills/` test skills). Only recommend tests for changed code; don't ask for tests on trivial changes (renames, comments, config bumps) unless they alter behaviour. For each gap:
  - **Choose the test level and justify it in a line.** Two levels, and they are not interchangeable:
    - **In-package unit test**: exercises a function/method/type directly, in the same package, with collaborators faked or absent. Fast, pinpoints the failure. Best for pure logic, branching, calculations, parsing/validation, error mapping, boundary values, nil/empty input, and state-transition rules.
    - **Full-scale integration test**: drives the real flow through the real boundary (HTTP/API handler, queue consumer, CLI) against real dependencies (DB, migrations, wiring, auth middleware). Slower, but the only level that proves the pieces work together. Best for new/changed endpoints, queries/SQL and migrations, transactions, authz and middleware behaviour, serialisation of request/response shapes, cross-component workflows, and regressions that only appear through wiring.
  - **Decide, don't list both by default.** Recommend the level that catches the risk most cheaply: unit when the risk is inside one function's logic; integration when the risk is in how components, storage or the API contract interact. Recommend **both** only when the change has distinct risk at each level, and say why. Prefer the repo's existing split.
  - **Spell out the test:** level (unit/integration), the behaviour or case to cover (happy path, error/edge cases, boundary values, nil/empty input, authz failures, state transitions, regressions for fixed bugs), the file where it belongs, and a suggested test name.
- **Other crucial concerns**: anything else important that doesn't fit the above (e.g. breaking changes, concurrency bugs).

If a category has no issues, state "No issues found" under that heading rather than omitting it. Do not comment on line/file counts in the findings. When referencing an issue, include a markdown link to the file and line (or line range).

## Closing line

End the review with one line stating how many files were reviewed and the total findings by severity (e.g. `Reviewed 14 files: 2 blocker, 7 should-fix, 5 nit. No findings omitted.`). This is the one place counts belong.

## Maintaining This Skill File

Update this file (not the instructions file) when the user asks for a different review focus, output shape or base-branch behaviour, or when a step turns out to be unreliable in practice. Keep the original `diff-code-review` untouched unless asked. Keep entries short.
