#!/usr/bin/env bash
# Keeps ~/.copilot identical on every machine through this repo. The repo is the source of
# truth for skills/ and instructions/: edit them HERE, never in ~/.copilot.
# Usage:
#   ./sync.sh pull                  git pull, then mirror the repo into ~/.copilot. Run BEFORE editing.
#   ./sync.sh [push] ["message"]    mirror the repo into ~/.copilot, regenerate README tables, commit and push.
# MCP config is the exception: secrets live only in ~/.copilot/mcp-config.json, and a redacted
# copy is generated into the repo. Never copies session history, databases or logs.
set -euo pipefail

SRC="$HOME/.copilot"
DEST="$(cd "$(dirname "$0")" && pwd)"
CMD="push"
case "${1:-}" in pull|push) CMD="$1"; shift ;; esac
MSG="${1:-Backup $(date +%F\ %H:%M)}"

cd "$DEST"
mkdir -p "$SRC/skills" "$SRC/instructions"

# Mirroring overwrites ~/.copilot, so refuse if it holds edits that are not in the last commit.
check_copilot_matches_head() {
    local tmp changes
    # A fresh machine has nothing in ~/.copilot to protect, so the first pull may mirror straight in.
    if [ -z "$(find "$SRC/skills" "$SRC/instructions" -type f -print -quit)" ]; then
        return 0
    fi
    tmp="$(mktemp -d)"
    git archive HEAD skills instructions | tar -x -C "$tmp"
    # diff compares content only; rsync -c also flags timestamp-only differences on macOS (openrsync),
    # and git archive stamps files with the commit time.
    changes="$(for d in skills instructions; do
        diff -rq -x .DS_Store "$SRC/$d" "$tmp/$d" || true
    done)"
    rm -rf "$tmp"
    if [ -n "$changes" ]; then
        echo "~/.copilot differs from the last commit (left side is ~/.copilot, right is the commit; edits belong in the repo):" >&2
        echo "$changes" >&2
        echo "Copy anything you want to keep into the repo's skills/ or instructions/, then re-run." >&2
        exit 1
    fi
}

mirror_into_copilot() {
    for d in skills instructions; do
        rsync -a --delete --itemize-changes --exclude='.DS_Store' "$DEST/$d/" "$SRC/$d/"
    done
}

if [ "$CMD" = "pull" ]; then
    if [ -n "$(git status --porcelain -- skills instructions)" ]; then
        echo "Repo has uncommitted edits in skills/ or instructions/. Run './sync.sh push' first." >&2
        exit 1
    fi
    check_copilot_matches_head
    git pull -q --ff-only
    applied="$(mirror_into_copilot)"
    if [ -z "$applied" ]; then
        echo "Already up to date."
    else
        echo "$applied"
        echo "Pulled."
    fi
    exit 0
fi

# Pushing over a newer remote would silently drop the other machine's changes.
git fetch -q
if [ "$(git rev-list --count 'HEAD..@{u}')" != "0" ]; then
    echo "The remote has commits that are not in this checkout." >&2
    echo "Run 'git stash', './sync.sh pull', 'git stash pop', then re-run." >&2
    exit 1
fi
check_copilot_matches_head

# Keep MCP server layout but blank every env value, since they hold tokens.
if [ -f "$SRC/mcp-config.json" ]; then
python3 - "$SRC/mcp-config.json" "$DEST/mcp-config.redacted.json" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    cfg = json.load(f)
for server in cfg.get("mcpServers", {}).values():
    for key in server.get("env", {}):
        server["env"][key] = "<redacted>"
    for key in server.get("headers", {}):
        server["headers"][key] = "<redacted>"
with open(sys.argv[2], "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
PY
fi

# Regenerate the README tables between the GENERATED markers from each file's frontmatter.
python3 - "$DEST" <<'PY'
import glob, os, re, sys
root = sys.argv[1]

def frontmatter(path):
    text = open(path).read()
    m = re.match(r"---\n(.*?)\n---", text, re.S)
    fm = {}
    if m:
        for line in m.group(1).splitlines():
            if ":" in line and not line.startswith(("#", " ")):
                k, v = line.split(":", 1)
                fm[k.strip()] = v.strip().strip('"').strip("'")
    return fm

def cell(s):
    return s.replace("|", "\\|").strip()

def split_desc(desc):
    parts = re.split(r"\bUse when:\s*", desc, maxsplit=1)
    summary = parts[0].rstrip(" .") + "."
    triggers = parts[1].rstrip(" .") + "." if len(parts) > 1 else ""
    return summary, triggers

out = ["### Instructions (`instructions/`)", "", "| File | Summary | applyTo |", "|---|---|---|"]
for path in sorted(glob.glob(os.path.join(root, "instructions", "*.md"))):
    fm = frontmatter(path)
    applies = f"`{fm['applyTo']}`" if fm.get("applyTo") else "none (always loaded)"
    out.append(f"| `{os.path.basename(path)}` | {cell(fm.get('description', '(no description)'))} | {applies} |")

out += ["", "### Skills (`skills/`)", "", "| Skill | Summary | Load when |", "|---|---|---|"]
for path in sorted(glob.glob(os.path.join(root, "skills", "*", "SKILL.md"))):
    fm = frontmatter(path)
    summary, triggers = split_desc(fm.get("description", "(no description)"))
    out.append(f"| `{os.path.basename(os.path.dirname(path))}` | {cell(summary)} | {cell(triggers)} |")

readme = os.path.join(root, "README.md")
text = open(readme).read()
begin, end = "<!-- BEGIN GENERATED -->", "<!-- END GENERATED -->"
if begin not in text or end not in text:
    sys.exit("README.md is missing the GENERATED markers")
pre, rest = text.split(begin, 1)
_, post = rest.split(end, 1)
open(readme, "w").write(pre + begin + "\n" + "\n".join(out) + "\n" + end + post)
PY

if grep -rIlE 'glpat-|ghp_|github_pat_|AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|PRIVATE)' --exclude-dir=.git --exclude=sync.sh --exclude=sync.ps1 .; then
    echo "Possible secret found in the files above; aborting." >&2
    exit 1
fi

mirror_into_copilot >/dev/null

git add -A
if ! git diff --cached --quiet; then
    git commit -q -m "$MSG"
fi
# Also covers a previous run that committed but failed to push.
if [ "$(git rev-list --count '@{u}..HEAD')" = "0" ]; then
    echo "No changes to back up."
    exit 0
fi
git push -q origin HEAD
echo "Backed up."
