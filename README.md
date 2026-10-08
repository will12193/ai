# ai

Backup of my Copilot CLI customisation from `~/.copilot`.

- `skills/` - user-level skills
- `instructions/` - user-level instructions
- `mcp-config.redacted.json` - MCP server layout with all env/header values redacted

Session history, databases and logs are deliberately not backed up.

Run `./sync.sh` to copy, commit and push. To restore, copy `skills/` and `instructions/` back into `~/.copilot/`
and re-add secrets to `mcp-config.json` by hand.
