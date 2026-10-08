#!/usr/bin/env bash
# Copies shareable Copilot config from ~/.copilot into this repo, regenerates the
# README tables, then commits and pushes.
# Usage: ./sync.sh ["commit message describing what changed and why"]
# Never copies session history, databases, logs or unredacted MCP config.
set -euo pipefail

SRC="$HOME/.copilot"
DEST="$(cd "$(dirname "$0")" && pwd)"
MSG="${1:-Backup $(date +%F\ %H:%M)}"

cd "$DEST"

# Synced paths are overwritten below; refuse to destroy edits made in the repo by mistake.
if [ -n "$(git status --porcelain -- skills instructions mcp-config.redacted.json)" ]; then
    echo "Repo has uncommitted changes in synced paths (~/.copilot is the source of truth):" >&2
    git status --short -- skills instructions mcp-config.redacted.json >&2
    echo "Port them into ~/.copilot or discard them (git checkout -- <path>), then re-run." >&2
    exit 1
fi

rsync -a --delete --exclude='.DS_Store' "$SRC/skills/" "$DEST/skills/"
rsync -a --delete --exclude='.DS_Store' "$SRC/instructions/" "$DEST/instructions/"

# Keep MCP server layout but blank every env value, since they hold tokens.
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

if grep -rIlE 'glpat-|ghp_|github_pat_|AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|PRIVATE)' --exclude-dir=.git --exclude=sync.sh .; then
    echo "Possible secret found in the files above; aborting." >&2
    exit 1
fi

git add -A
if git diff --cached --quiet; then
    echo "No changes to back up."
    exit 0
fi
git commit -q -m "$MSG"
git push -q origin HEAD
echo "Backed up."
