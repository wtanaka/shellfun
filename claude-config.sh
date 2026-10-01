#!/bin/sh
# Copyright (C) 2026 Wesley Tanaka
# Adds a SessionStart hook to ~/.claude/settings.json that makes Claude Code
# source ~/.claude-env.sh before every Bash command.  Claude Code owns
# $CLAUDE_ENV_FILE, so the hook appends a line to it.  Idempotent.

DEST_DIR="$HOME/.claude"
DEST="$DEST_DIR/settings.json"
HOOK_CMD='[ -n "$CLAUDE_ENV_FILE" ] && echo '\''. "$HOME/.claude-env.sh"'\'' >> "$CLAUDE_ENV_FILE"'

if ! command -v jq > /dev/null; then
   echo "claude-config.sh: jq not found, skipping $DEST" >&2
   exit 0
fi

mkdir -p "$DEST_DIR"
if [ ! -s "$DEST" ]; then
   echo '{}' > "$DEST"
fi

TMP="`mktemp "$DEST_DIR/settings.json.XXXXXX"`" || exit 1
if jq --arg cmd "$HOOK_CMD" '
     .hooks.SessionStart = (
       (.hooks.SessionStart // [])
       | if any(.[]; .hooks[]?.command == $cmd) then .
         else . + [{"hooks": [{"type": "command", "command": $cmd}]}] end)
   ' "$DEST" > "$TMP"; then
   mv "$TMP" "$DEST"
else
   rm -f "$TMP"
   echo "claude-config.sh: could not update $DEST" >&2
fi
