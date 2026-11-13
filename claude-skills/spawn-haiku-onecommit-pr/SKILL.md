---
name: spawn-haiku-onecommit-pr
description: Launch one disposable Haiku subagent to do a whole task -- new temp jj workspace off main, one commit, push, open a PR -- then immediately stop, without reviewing the worker's work. Use when the user wants a task done as cheaply as possible, spending as few tokens as possible on any model other than the cheapest one, and accepts a Haiku worker acting unsupervised: "just get a PR up for X", "have Haiku knock this out", "spawn something to fix X and open a PR, don't check it". Not for anything requiring judgment calls that the orchestrator should verify -- the skill exists to spend zero tokens on review from any model other than the cheapest one.
---

# Spawn one Haiku worker for one commit and one PR, then stop

Load the `haiku-worker-run` skill and follow `haiku-worker-run` with the parameters below.
`haiku-worker-run` holds the flow (sweep, workspace, launch, register,
teardown) and the rules every worker run shares.

- **Base:** `main`, so the PR is one commit past `main`:
  `sh ~/.claude/skills/jj-worker-workspace/workspace.sh new <short-task-id> main`.
- **Teardown options:** none.
- **Follow-ups:** a CI failure or a review comment is a separate invocation of
  `spawn-haiku-onecommit-pr`, not work for the current run.

## Worker steps

The end of the prompt, after the standard header:

```
1. `jj --repository "<$WORKSPACE_DIR>" new main` -- the command creates the one commit.
2. Do the following: [the thing to do]
3. Fold any follow-up fix into the SAME commit by editing files and
   re-running `jj describe` (`--repository "<$WORKSPACE_DIR>"`). Never stack a
   second commit (no further `jj new` after step 1, no `jj commit`), and never
   run `jj squash`: `jj squash` folds the work into the parent commit, `main`.
4. Push and open a PR against main. If the repo documents a non-default
   remote setup (for example a split canonical remote and personal-copy
   remote), use that setup; otherwise use origin. Scope every push and remote
   command to <$WORKSPACE_DIR> as above. If a PR for the branch is already
   open and the push carries a fix, push the new commit FIRST so CI starts
   before anything else.
5. Report back only: the PR URL (or the reason no PR exists) and a one-line
   summary of the change. Then stop -- no polling CI, no waiting for review,
   no further touching of the workspace.
```

## After teardown

Relay the PR URL (if any) to the user. If no PR exists -- the worker got
stuck, failed or was stopped -- tell the user the work survives at bookmark
`<short-task-id>-wip`, and let the user decide whether to resume the work,
discard the work (`jj bookmark forget <short-task-id>-wip`), or hand the work
to a fresh worker. If a PR exists, mention that the bookmark exists too: a
later run sweeps the bookmark once the commit is reachable another way, but a
rebase merge or squash merge puts a new commit on `main`, so delete
`<short-task-id>-wip` after the PR merges if the bookmark remains. Do not read
the worker's diff, commit or CI status beyond what relaying the PR URL needs.

## Rules for `spawn-haiku-onecommit-pr`

- **Never merge the PR, and never enable auto-merge.** `spawn-haiku-onecommit-pr` only opens a
  PR; a human merges the PR.
