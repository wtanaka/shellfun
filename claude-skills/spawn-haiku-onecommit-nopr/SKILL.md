---
name: spawn-haiku-onecommit-nopr
description: Launch one disposable Haiku subagent to do a whole task -- new temp jj workspace off main, one commit -- then immediately stop, without reviewing the worker's work. Haiku does NOT push or open a PR; the commit stays visible in `jj log` at a `-wip` bookmark (the workspace is torn down afterward) for the user to inspect and promote. Use when the user wants a task done as cheaply as possible, spending as few tokens as possible on any model other than the cheapest one, accepts a Haiku worker acting unsupervised, and wants to review, push or open the PR manually: "spawn something to fix X, just leave the commit there", "have Haiku do X but don't push it". Not for anything requiring judgment calls that the orchestrator should verify -- the skill exists to spend zero tokens on review from any model other than the cheapest one.
---

# Spawn one Haiku worker for one commit, no push, no PR, then stop

Load the `haiku-worker-run` skill and follow `haiku-worker-run` with the parameters below.
`haiku-worker-run` holds the flow (sweep, workspace, launch, register,
teardown) and the rules every worker run shares. The worker never pushes
and never opens a PR: the commit stays in the repo's jj history for the user to
inspect and promote.

- **Base:** `main`: `sh ~/.claude/skills/jj-worker-workspace/workspace.sh new <short-task-id> main`.
- **Teardown options:** none.
  The bookmark that teardown creates, `<short-task-id>-wip`, is the
  deliverable: the bookmark is the only item that keeps the commit visible in
  `jj log` after the workspace is forgotten. Without the bookmark, "leaves the
  commit for the user to inspect" is false, whatever the outcome of the run.
- **Follow-ups:** promoting the commit, opening a PR or fixing the commit is a
  later step for the user or a separate invocation.

## Worker steps

The end of the prompt, after the standard header:

```
1. `jj --repository "<$WORKSPACE_DIR>" new main` -- the command creates the one commit.
2. Do the following: [the thing to do]
3. Fold any follow-up fix into the SAME commit by editing files and
   re-running `jj describe` (`--repository "<$WORKSPACE_DIR>"`). Never stack a
   second commit (no further `jj new` after step 1, no `jj commit`), and never
   run `jj squash`: `jj squash` folds the work into the parent commit, `main`.
4. Give the commit a clear one-line `jj describe` message.
5. Do NOT push anything, open a PR, or touch any remote. Leave the commit
   in the workspace exactly as-is -- a human reviews the commit directly in
   the jj tree and decides whether and how to promote the commit.
6. Report back only: the commit id
   (`jj --repository "<$WORKSPACE_DIR>" log -r @ --no-graph -T commit_id`)
   and a one-line summary of the change. Then stop -- no further
   pushing, no polling CI, no further touching of the workspace.
```

## After teardown

Tell the user the commit lives at bookmark `<short-task-id>-wip` (name the
bookmark, not just "in jj log"), followed by the worker's one-line summary (or,
if the worker never produced a summary, the state visible in the diff). The
user can inspect the commit, squash the commit onto `main`, push the commit, or
discard the commit with `jj bookmark forget <short-task-id>-wip`. The user can
also leave the bookmark: a later run sweeps the bookmark once the commit is
reachable another way.

## Rules for `spawn-haiku-onecommit-nopr`

- **The worker never pushes and never opens a PR, and neither does the
  orchestrator.** The orchestrator does not review the diff for quality either;
  review is the user's job now.
