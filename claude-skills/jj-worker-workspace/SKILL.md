---
name: jj-worker-workspace
description: Create, register and tear down a jj workspace for a worker subagent. Use before launching a worker, right after launching the worker, and when the worker finishes, or whenever a subagent needs its own jj workspace.
---

# jj workspace lifecycle for a worker

The orchestrator (the session that launches the worker) owns the workspace,
never the worker. The worker receives an absolute path and scopes every
command to the path. One script covers the lifecycle; run the script from the
repo's main checkout.

```bash
W=~/.claude/skills/jj-worker-workspace/workspace.sh
sh $W new <task-id> [rev]               # 1. before launching the worker
sh $W register <agent-id> "<dir>"       # 2. right after launching the worker
sh $W teardown [--amended <change-id>] <task-id> [agent-id]   # 3. when done
```

## 1. new

- `<task-id>`: kebab-case name derived from the task. The name becomes the
  workspace name and the `<task-id>-wip` bookmark name. The script refuses a
  task id whose workspace or `-wip` bookmark already exists.
- `[rev]`: the commit where the workspace starts; default `main`. The default
  keeps the worker's base out of reach of anything the orchestrator does in
  the main checkout (editing files, `jj new`, `jj edit`) and keeps a PR one
  commit past `main`. Do not pass `@` or an ancestor of the orchestrator's
  working copy: jj rewrites those commits on every edit, and the rewrite makes
  the worker's workspace stale.

`new` prints three lines. Use the values verbatim in the worker prompt and in
the later steps:

```
WORKSPACE_DIR=/var/folders/.../T/<repo>-<task-id>
MAIN_CHECKOUT=/path/to/main/checkout
TMP_ROOT=/var/folders/.../T
```

## 2. register

`register` writes `$TMP_ROOT/claude-workspace-guard/<agent-id>.path`, the file
that the workspace-scope guard reads (see "The workspace-scope guard" below).
`<agent-id>` is the `agentId` that the launch returned. Make `register` the
very next tool call after the launch: the worker may issue the first command at
once, and the guard blocks an unregistered worker. Registration is mandatory.

## 3. teardown

In order: snapshot the workspace, bookmark the worker's commit as
`<task-id>-wip`, forget the workspace, delete the workspace directory, remove
the registration. Run `teardown` unconditionally, whether the worker finished,
failed or was stopped. Rerunning `teardown` after a partial run is safe.

- The bookmark keeps the commit visible in `jj log` after the workspace is
  forgotten. Without the bookmark, the commit becomes invisible and eligible
  for garbage collection.
- The snapshot records edits made after the worker's last jj command; deleting
  the directory would destroy those edits otherwise.
- `--amended <change-id>` applies when the worker edited that existing commit.
  The commit stays visible under the commit's own change ID, so no bookmark is made. If
  the workspace holds a different non-empty commit instead, the script
  bookmarks that commit anyway, so no work is lost.
- On any failure, the script stops and leaves the workspace in place. Fix the
  cause and rerun (for a stale main checkout: run `jj workspace update-stale`
  there). Never run `jj workspace forget` or `rm` by hand.

## Rules

1. Use printed paths verbatim, copy-pasted and unquoted (the prompt's own
   double quotes protect spaces). Shell variables do not persist between tool
   calls, so carry literal values forward; do not `eval` the output.
2. On macOS, `$TMPDIR` is under `/var/folders/.../T/`, not `/tmp` or
   `/private/tmp`, and ends in a slash. The script strips the slash and builds
   the path from `$TMPDIR`. A typed `/tmp/...` names a workspace that does not
   exist, and the worker cannot distinguish that error from a setup failure.

## The workspace-scope guard

The workspace-scope guard is a hook script
(`~/.claude/hooks/require-workspace-scope.sh`), registered in
`~/.claude/settings.json` as a `PreToolUse` hook on `Bash`. The hook enforces
the scoping rule mechanically:

- The guard acts only on subagent calls (identified by `agent_id`) whose
  `agent_type` is `haiku-worker` or not reported. The guard never acts on the
  orchestrator or on other agent types.
- The guard blocks repo-mutating commands (`jj`, `cargo`, `pytest`, `rm`, `mv`,
  `cp`, `npm`, `make`) that do not name the registered workspace path, and
  blocks direct `git` in a jj repo.
- The guard reads the registration from
  `$TMP_ROOT/claude-workspace-guard/<agent_id>.path` and blocks an
  unregistered worker after waiting up to 5 seconds.
- The guard catches mistakes; the guard is not a sandbox.
