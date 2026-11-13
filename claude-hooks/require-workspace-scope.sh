#!/usr/bin/env bash
# PreToolUse guard for Bash calls made by haiku-worker subagents (the
# spawn-haiku-* skills). A seatbelt, not a sandbox: it catches a dropped `cd`
# or a bare `jj`/`cargo` that would land in the shared checkout, and it blocks
# direct `git` in jj repos (can desync jj's view of the working copy). A
# determined command can bypass it (for example by naming the path in a
# comment). Top-level sessions and other agent types are never touched.
#
# State: ${TMPDIR:-/tmp}/claude-workspace-guard/<agent_id>.path holds the
# agent's absolute workspace path. The orchestrator writes it before launching
# the worker and removes it on teardown; a stale file ages out with the OS temp
# purge. Hook, orchestrator and workers see the same $TMPDIR (checked on macOS,
# 2026-11-12). CLAUDE_WORKSPACE_GUARD_DIR overrides the directory.
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0   # cannot parse input: fail open

_tmp="${TMPDIR:-/tmp}"
STATE_DIR="${CLAUDE_WORKSPACE_GUARD_DIR:-${_tmp%/}/claude-workspace-guard}"
WORKER_TYPE=haiku-worker

input=$(cat)
agent_id=$(jq -r '.agent_id // empty' <<<"$input")
agent_type=$(jq -r '.agent_type // empty' <<<"$input")

[[ -n "$agent_id" ]] || exit 0                       # top-level session
[[ "$agent_id" =~ ^[A-Za-z0-9_-]+$ ]] || exit 0      # no path tricks
# Other agent types (Explore, general-purpose, ...) are not our workers.
[[ -z "$agent_type" || "$agent_type" == "$WORKER_TYPE" ]] || exit 0

command=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
state="$STATE_DIR/${agent_id}.path"

# Command text with quoted strings removed, so `jj describe -m 'fix git'`
# is not mistaken for a git call.
# Newlines are hidden during the strip so a quoted multi-line message goes too.
bare=$(printf '%s' "$command" | tr '\n' '\001' |
  sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g" | tr '\001' '\n')

# Matches NAME in command position, past env/sudo/command/VAR=x prefixes and
# an optional directory part (/usr/bin/git).
at_cmd() {   # at_cmd 'name|name' ; reads $bare
  grep -qE "(^|[;&|(])[[:space:]]*((env|sudo|command)[[:space:]]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*(/[^[:space:]]*/)?($1)([^A-Za-z0-9_-]|\$)" <<<"$bare"
}

norm() {   # macOS: /private/var == /var; $TMPDIR ends in /, so collapse //
  local p=$1
  while [[ "$p" == *//* ]]; do p=${p//\/\//\/}; done
  case $p in
    /private/*) printf '%s' "${p#/private}" ;;
    *) printf '%s' "$p" ;;
  esac
}

workspace=
workspace=$(cat "$state" 2>/dev/null || true)
workspace=${workspace%/}
# Not registered and not a known worker: not ours to guard.
[[ -n "$workspace" || "$agent_type" == "$WORKER_TYPE" ]] || exit 0

# Direct git: blocked only where a .jj directory exists.
where=${workspace:-$cwd}
if [[ -n "$where" && -d "$where/.jj" ]] && at_cmd git; then
  echo "Blocked: no direct git in a jj repo; use jj (jj git push, jj git fetch)." >&2
  exit 2
fi

at_cmd 'jj|cargo|pytest|rm|mv|cp|npm|make' || exit 0   # harmless command

if [[ -z "$workspace" && "$agent_type" == "$WORKER_TYPE" ]]; then
  # The orchestrator may still be registering this worker: wait up to 5s.
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    [[ -f "$state" ]] && break
    sleep 0.5
  done
  workspace=$(cat "$state" 2>/dev/null || true)
  workspace=${workspace%/}
fi
[[ -n "$workspace" ]] || {
  echo "Blocked: no workspace registered for this worker yet; wait and retry." >&2
  exit 2
}

ws=$(norm "$workspace")
c=$(norm "$cwd")
# Already inside the workspace.
[[ "$c" == "$ws" || "$c" == "$ws"/* ]] && exit 0

# The command must name the workspace path as a whole path, not a prefix of
# a sibling (/ws1 vs /ws10) or the tail of a longer path.
# names_ws CANDIDATE: 0 when the command contains CANDIDATE as a whole path.
cmd=${command//\/private\//\/}
while [[ "$cmd" == *//* ]]; do cmd=${cmd//\/\//\/}; done   # $TMPDIR ends in /
names_ws() {
  local rest=$cmd prefix after prev next
  while [[ "$rest" == *"$1"* ]]; do
    prefix=${rest%%"$1"*}
    after=${rest#*"$1"}
    prev=${prefix: -1}
    next=${after:0:1}
    if [[ ! "$prev" =~ [A-Za-z0-9_.-] ]]; then
      [[ -z "$next" || ! "$next" =~ [A-Za-z0-9_.-] ]] && return 0
    fi
    rest=$after
  done
  return 1
}
names_ws "$ws" && exit 0
# Shell-escaped spaces (my\ ws) in an unquoted path.
names_ws "${ws// /\\ }" && exit 0
echo "Blocked: run in $workspace: jj --repository \"$workspace\" ..., or (cd \"$workspace\" && ...)." >&2
exit 2
