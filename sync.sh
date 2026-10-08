#!/usr/bin/env bash
# Copies shareable Copilot config from ~/.copilot into this repo, then commits and pushes.
# Never copies session history, databases, logs or unredacted MCP config.
set -euo pipefail

SRC="$HOME/.copilot"
DEST="$(cd "$(dirname "$0")" && pwd)"

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

cd "$DEST"
if grep -rIlE 'glpat-|ghp_|github_pat_|AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|PRIVATE)' --exclude-dir=.git --exclude=sync.sh .; then
    echo "Possible secret found in the files above; aborting." >&2
    exit 1
fi

git add -A
if git diff --cached --quiet; then
    echo "No changes to back up."
    exit 0
fi
git commit -q -m "Backup $(date +%F\ %H:%M)"
git push -q origin HEAD
echo "Backed up."
