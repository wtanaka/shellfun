---
name: spawn-haiku-amend-commit
description: Launch one disposable Haiku subagent to do a task by editing an EXISTING jj commit in place -- takes a jj change ID and a task description, has Haiku `jj edit <change-id>` (instead of `jj new main`) and then edit files directly on that change with no further jj operations -- then immediately stop, without reviewing the worker's work. `spawn-haiku-amend-commit` amends a commit that already exists -- for example a commit that an earlier Haiku run left at a `-wip` bookmark, or any commit the user names by change ID. Use when the user wants cheap, unsupervised follow-up edits folded into a specific existing commit: "have Haiku fix X directly on change abc123", "amend qpvvzxxx with Y, don't make a new commit". Not for anything requiring judgment calls that the orchestrator should verify -- `spawn-haiku-amend-commit` exists to spend zero tokens on review from any model other than the cheapest one.
---

# Spawn one Haiku worker to amend one existing commit in place, then stop

Load the `haiku-worker-run` skill and follow `haiku-worker-run` with the parameters and the
changes below. `haiku-worker-run` holds the flow (sweep, workspace, launch,
register, teardown) and the rules every worker run shares.

**The worker runs `jj edit <change-id>` (check out and directly edit a commit
that already exists) instead of `jj new main` (start a new child commit).** The substitution has three consequences:

- The commit under edit is not new. The commit may already be pushed, back an
  open PR, or be the target of other in-flight work. Editing rewrites the commit
  in place (new commit hash, same change ID). Whoever follows up must update
  every reference that uses the commit hash instead of the change ID.
- After the initial `jj edit`, the worker makes **no further mutating jj
  operations**, only read-only operations for self-checks (`diff`, `status`,
  `workspace list`, `log`). No `jj new`, no `jj describe`, no `jj squash`, no
  `jj bookmark`, no `jj git push`. jj auto-snapshots file edits into the checked
  out commit, so plain file edits amend the commit.
- **No push, no PR.** The commit stays where the commit was (same change ID,
  new commit hash) for the user to inspect and then push or promote.

**The core action of `spawn-haiku-amend-commit` has already leaked once.** `jj edit <rev>`
run with no `--repository` flag under `default@` moved the *orchestrator's own
main checkout* onto the commit, not only another workspace. Treat the
isolation rule in the prompt as load-bearing, not boilerplate, and always run
the post-run leak check below.

**A stale working copy is an expected risk, not corruption.** If the change ID
is *also* checked out (`@`) in another workspace (the orchestrator's `default`
checkout or a concurrent session) and the other workspace edits files first, the next jj
command in the worker's workspace fails with `jj: The working copy is stale`.
The prompt tells the worker the recovery: `workspace update-stale`, scoped to
the worker's workspace, then re-verify `diff --stat`.

## Parameters and changes to the flow

- **Base:** `main`: `sh ~/.claude/skills/jj-worker-workspace/workspace.sh new <short-task-id> main`.
  The base matters little, since the worker's first command is
  `jj edit <CHANGE_ID>`.
- **Before step 1 of the flow:** fill in `<CHANGE_ID>` with the change ID from
  the user, and verify the change ID resolves before launching anything
  (`jj log -r <CHANGE_ID> --no-graph -T 'change_id ++ "\n" ++ description'`
  from the orchestrator's checkout). If the change ID does not resolve, stop and
  ask the user instead of launching the worker at an ambiguous target. Also run
  `jj workspace list` to check whether `<CHANGE_ID>` is the `@` of any
  workspace (including `default`). That state is allowed, but state the fact
  when confirming the launch, because a concurrent edit from the other workspace
  can trigger the stale-recovery path.
- **Before launching (flow step 3):** snapshot the orchestrator's own checkout
  as the baseline for the leak check:
  ```bash
  jj log -r @ --no-graph -T 'change_id ++ " " ++ commit_id' --ignore-working-copy
  ```
  Name the change ID under edit and the workspace path in the confirmation.
- **On completion, before teardown:** relay the worker's summary (the resulting
  commit id and description), **then check the orchestrator's checkout for a
  leak**: run the same `jj log` command and compare the output with the
  baseline. A leak is an unscoped jj command from the worker that reached the
  default workspace. The signs are a changed output, or an `@` that sits on
  `<CHANGE_ID>` or on any commit other than the empty commit on `main`.
  Recover with `jj new main` in the orchestrator's checkout. Nothing is lost,
  because the worker's edit is a separate change that exists independently in
  the commit graph.
- **Teardown options:** `--amended <CHANGE_ID>`, placed before `<short-task-id>`.
  The script makes no `-wip` bookmark, because the amended commit stays visible
  under the same change ID (`jj log -r <CHANGE_ID>` shows the new commit hash).
  Exception: if the workspace holds a different non-empty commit (the worker
  never ran `jj edit`, or ran a stray `jj new`), the script bookmarks that
  commit as `<short-task-id>-wip`, so no work is lost. Tell the user when the
  exception happens.
- Do not push, open a PR, read the worker's diff or verify the worker's work.

## The Haiku prompt

```
Only job: do the task below, end to end, alone, by editing ONE EXISTING
commit in place, then stop.

The workspace already exists at: <$WORKSPACE_DIR>
The main checkout, never touched, is: <$MAIN_CHECKOUT>
Follow the standing workspace rules: jj only, never git, and every command
scoped to the workspace. Do not run `jj workspace add` or `jj workspace
forget` at all.

**Mechanical isolation rule -- read before running anything.** The rule
matters more than usual for the task: a past run of a command shaped exactly
like the command below (`jj edit <rev>` without `--repository`) leaked into the
orchestrating session's OWN main checkout and moved the main checkout onto the
wrong commit. Every command must be self-contained and explicitly scoped to
<$WORKSPACE_DIR>. Never rely on a `cd` from an earlier command still being in
effect -- assume each tool call may start fresh.
  - Every `jj` command, with NO exceptions: pass `--repository
    "<$WORKSPACE_DIR>"` explicitly (for example `jj --repository
    "<$WORKSPACE_DIR>" edit <CHANGE_ID>`, `jj --repository "<$WORKSPACE_DIR>"
    diff --stat`). A planned `jj` command without `--repository
    "<$WORKSPACE_DIR>"` is a bug in the plan: fix the plan, do not run the
    command.
  - Every other command (cargo, npm, pytest, editing files, etc.): wrap the
    command as `(cd "<$WORKSPACE_DIR>" && <command>)` in a single shell
    invocation, every time -- never a bare `cd` followed by a separate
    command.
  - Never read from or write to <$MAIN_CHECKOUT> (the main checkout that the
    workspace branched from) or any path outside <$WORKSPACE_DIR>, under any
    circumstance.
  - Before making any edit, check the location: `jj --repository
    "<$WORKSPACE_DIR>" workspace list` must show the named workspace, and
    after `jj edit` the workspace line must show `@` on <CHANGE_ID>. If either
    check fails, stop and report the problem instead of continuing.

If a hook rejects the first commands with "no workspace registered for this
worker", the cause is a startup race (the orchestrator registers the
workspace a moment after launching the worker): wait 10 seconds (`sleep 10` as a
separate call) and retry, up to 5 times, before reporting blocked. Never create
the registration file.

**jj-operation budget for the task: ONE mutating jj command, ever.**

1. Run exactly this one mutating jj command and nothing else like the command:
   `jj --repository "<$WORKSPACE_DIR>" edit <CHANGE_ID>`
   The command checks out the target commit directly for editing. The command
   is NOT `jj new`: no child commit is created, and the checked out commit IS
   the target commit (same change ID; jj assigns a new commit hash once files
   change).

2. Do the following: [the thing to do]

3. No other jj mutation. Do **not** run `jj new`, `jj describe`, `jj squash`,
   `jj bookmark`, `jj commit` or `jj git push`, at any point, for any reason.
   jj auto-snapshots file edits into the commit checked out in step 1; nothing
   further needs committing. Read-only jj commands are allowed for
   self-checks: `jj --repository "<$WORKSPACE_DIR>" diff --stat`, `jj
   --repository "<$WORKSPACE_DIR>" status`, `jj --repository
   "<$WORKSPACE_DIR>" log -r @`, `jj --repository "<$WORKSPACE_DIR>"
   workspace list`.

4. If any jj command reports `The working copy is stale` (the cause: the same
   commit is also checked out in another workspace and that workspace edited the commit while
   the task ran): run `jj --repository "<$WORKSPACE_DIR>" workspace
   update-stale`, then immediately re-run `jj --repository "<$WORKSPACE_DIR>"
   diff --stat` and confirm the output shows only the intended files before
   continuing. The state is expected jj behavior, not corruption, and
   `update-stale` scoped to the worker's own workspace resolves the state
   without losing edits.

5. **Do NOT push anything. Do NOT open a PR. Do NOT touch any remote.** Leave
   the commit in the workspace exactly as-is -- a human reviews the commit
   directly in the jj tree and decides whether and how to push or promote the commit.

6. Report back only: the change ID that was edited (the change ID does not
   change), the resulting commit id (`jj --repository "<$WORKSPACE_DIR>" log
   -r @ --no-graph -T commit_id`), and a one-line summary of the change. Then
   stop -- no further work, no push, no CI polling, no further touching of the
   workspace.
```

## Rules for `spawn-haiku-amend-commit`

- **The worker runs exactly one mutating jj command: the initial `jj edit
  <CHANGE_ID>`.** Read-only jj commands for self-checks are allowed, and
  `jj workspace update-stale` is allowed strictly as stale-working-copy
  recovery.
- **The worker never pushes and never opens a PR.**
- **The orchestrator checks the orchestrator's own checkout for a leak
  immediately after the run finishes**, before tearing down the workspace.
