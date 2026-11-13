#!/bin/sh
# Copyright (C) 2026 Wesley Tanaka
# Adds a SessionStart hook to ~/.claude/settings.json that makes Claude Code
# source ~/.claude-env.sh before every Bash command.  Claude Code owns
# $CLAUDE_ENV_FILE, so the hook appends a line to it.  Idempotent.

DEST_DIR="$HOME/.claude"
DEST="$DEST_DIR/settings.json"
# Follow a symlinked settings.json (dotfile managers) so mv updates the target
# and keeps the link.
if [ -L "$DEST" ]; then
   LINK_TARGET="`readlink "$DEST"`"
   case $LINK_TARGET in
      /*) DEST="$LINK_TARGET" ;;
      *) DEST="$DEST_DIR/$LINK_TARGET" ;;
   esac
   DEST_DIR="`dirname "$DEST"`"
fi

HOOK_CMD='[ -n "$CLAUDE_ENV_FILE" ] && echo '\''. "$HOME/.claude-env.sh"'\'' >> "$CLAUDE_ENV_FILE"'

if ! command -v jq > /dev/null; then
   echo "claude-config.sh: jq not found, skipping $DEST" >&2
   exit 0
fi

mkdir -p "$DEST_DIR"
# Serialize concurrent runs (a lost update otherwise).  After 5s, go ahead
# without the lock rather than hang on a stale one.
LOCK="$DEST.lock"
LOCKED=
n=0
while [ $n -lt 50 ]; do
   if mkdir "$LOCK" 2>/dev/null; then LOCKED=1; break; fi
   n=$((n + 1)); sleep 0.1
done
[ -z "$LOCKED" ] || trap 'rmdir "$LOCK" 2>/dev/null' EXIT
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

# Register the workspace-scope guard (installed by install.sh) as a PreToolUse
# hook on Bash.  It only acts on subagent calls.  Idempotent.
GUARD_CMD='$HOME/.claude/hooks/require-workspace-scope.sh'
TMP="`mktemp "$DEST_DIR/settings.json.XXXXXX"`" || exit 1
if jq --arg cmd "$GUARD_CMD" '
     .hooks.PreToolUse = (
       (.hooks.PreToolUse // [])
       | if any(.[]; .hooks[]?.command == $cmd) then .
         else . + [{"matcher": "Bash",
                    "hooks": [{"type": "command", "command": $cmd}]}] end)
   ' "$DEST" > "$TMP"; then
   mv "$TMP" "$DEST"
else
   rm -f "$TMP"
   echo "claude-config.sh: could not update $DEST" >&2
fi
