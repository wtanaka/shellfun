---
name: spawn-haiku-autonomous-chain
description: Build a chain of local jj commits fully autonomously. Haiku workers write the code, one commit per task, and the orchestrator reviews each commit and runs a human-specified CI script before the commit counts as done. The skill never opens a PR and never merges. Optionally pushes the chain to one branch on one remote that the user names, and fetches that remote to rebase the chain onto main, resolving conflicts. Use when the user says "build this as a chain of commits", "work through these tasks locally, no PRs", "keep a stacked branch up to date on remote X", "grind through the task list and keep the chain pushed".
---

# Autonomous chain: Haiku writes each commit, the orchestrator reviews and runs CI, nothing merges

The user authorizes the orchestrator to review Haiku's work, to rewrite the
local chain (rebase, amend) and, when the user names a push target, to
force-push the chain to the named branch. The orchestrator writes no code: a
Haiku worker does. The skill never opens a PR and never merges.

## Inputs (ask once, up front, then go autonomous)

1. **Tasks:** an ordered list. Each task has a goal, the files likely touched
   and acceptance criteria. Without a list, write one into a plan file in the
   scratchpad and get the user's approval of the plan.
2. **CI script:** a command that exits 0 when a commit is good (build, lint,
   tests). The script runs in the checked-out commit, from the repository root.
3. **Push target (optional):** a remote name and a branch name. With no
   target, the skill never pushes and never fetches.
4. **Base:** `main`. With a push target, the remote is the source of
   `main@<remote>`.
5. **Verification checkout:** `main checkout` (default) or `throwaway
   workspace`. Never ask the user about this input. Use the default unless
   "Choosing the verification checkout" below selects the other value.

Ask every missing input in one message. Afterward, decide by sensible default
and record the decision in the commit description.

## Invariants

1. **A commit is done only when both conditions hold:** the CI script exited 0
   on the final content of the commit, and the orchestrator has read the
   commit description and the full diff and confirmed that the commit meets the
   task's acceptance criteria. Neither condition alone is enough.
2. **The chain is linear:** each commit has exactly one parent, and the first
   commit's parent is the base. One task, one commit.
3. **The orchestrator never edits files.** The orchestrator runs jj commands
   (`new`, `edit`, `rebase`, `describe`, `bookmark`, `git fetch`, `git push`)
   and the CI script. Workers edit files.
4. **Every subagent is a Haiku worker** (`subagent_type: "haiku-worker"`,
   `model: "haiku"`), launched only by the orchestrator, one at a time. No
   subagent launches another subagent. A stronger model needs the user's
   explicit word in the conversation.
5. **Push only done commits, only to the named branch, only to the named
   remote.** Never push another bookmark. Never open a PR. Never merge. Never
   run `gh`.
6. **One worker at a time.** The next task starts only after the previous
   commit is done.

## Loop, per task

1. **Create the commit without checking the commit out**, so the main checkout
   stays free of the change under edit:
   ```bash
   jj new --no-edit <tip> -m "<one-line description of the task>"
   ```
   `<tip>` is the last done commit, or the base for the first task. Record the
   change ID that the command prints.
2. **Brief the worker.** Write a self-contained task description: goal, exact
   files and functions, constraints, what NOT to touch, the acceptance
   criteria and the commit description wanted. Load the `code-design-bias`
   skill and include the skill's rules in every brief. End every brief, and
   every amend-round brief, with the self-check footer from "Worker
   self-check footer" below.
3. **Run the work.** Load the `spawn-haiku-amend-commit` skill and follow
   `spawn-haiku-amend-commit` with the change ID from step 1 and the brief. The
   worker edits files inside the empty commit and runs no jj mutation. Ignore
   the "do not verify the worker's work" rules of `spawn-haiku-amend-commit`: the
   orchestrator reviews in step 4.
4. **Review.** Read the description and the whole diff:
   `jj show <change-id>`. Check the commit against the acceptance criteria,
   the repository rules and the design bias. Check that the new tests assert
   behavior and do not repeat the implementation. Verify claims directly; the
   worker's summary is not evidence.
5. **Run the CI script** in the commit, in the checkout that the
   verification checkout input names.

   **Main checkout (default).** Record the commit ID, then:
   ```bash
   jj edit <change-id>
   <CI script>
   jj log -r @ --no-graph -T commit_id
   ```
   Run the last `jj log` without `--ignore-working-copy`: the command snapshots
   the files that the CI script wrote, so the second commit ID reflects them.
   Afterward, move the main checkout to the parking commit (see "Parking the
   main checkout").

   **Throwaway workspace.** The main checkout never moves. Create a workspace
   from the parking commit and copy the printed `WORKSPACE_DIR` literally:
   ```bash
   sh ~/.claude/skills/jj-worker-workspace/workspace.sh new verify-<task-id> <parking-commit>
   jj --repository "<WORKSPACE_DIR>" edit <change-id>
   jj --repository "<WORKSPACE_DIR>" log -r @ --no-graph -T commit_id
   (cd "<WORKSPACE_DIR>" && <install command>)
   (cd "<WORKSPACE_DIR>" && <CI script>)
   jj --repository "<WORKSPACE_DIR>" log -r @ --no-graph -T commit_id
   ```
   The install command is the one from the self-check footer: a fresh
   workspace holds no ignored files such as `node_modules`. Tear the workspace
   down as the next command, whether CI passed or failed, and also when
   `edit` or the install failed:
   ```bash
   sh ~/.claude/skills/jj-worker-workspace/workspace.sh teardown --amended <change-id> verify-<task-id>
   ```
   Never run `jj workspace forget` or `rm` by hand. After teardown,
   `jj workspace list` shows no `verify-*` workspace; when one remains, rerun
   the teardown command.

   **Both variants.** Compare the two commit IDs. A change means the CI script
   rewrote files: treat the run as a failure and list the changed files in the
   feedback. The CI script must not depend on the path of the main checkout.
6. **Iterate.** For every defect, CI failure or doubt, write precise feedback
   (file, what is wrong, what is wanted, how to verify, and the failing log
   excerpt for a CI failure) and run another amend round through
   `spawn-haiku-amend-commit`. Return to step 4. Cap at 5 rounds. When the
   commit does not converge, shrink the task, rewrite the brief, or abandon the
   commit (`jj abandon <change-id>`) and start a fresh commit for the same
   task. After a second failed attempt, stop and report to the user.
7. **Mark done.** Both conditions of invariant 1 hold. Add a line to the plan
   file. With a push target, run "Push the chain" below. Go to step 1 for the
   next task.

## Changing the backlog

The backlog is the plan file's list of tasks that have no commit yet. The plan
file is the source of truth for the backlog order. Re-read the plan file before
starting each task.

A user message that adds, removes or reorders backlog tasks takes effect at the
next task boundary, never while a worker runs. The orchestrator folds the change
into the plan file, then continues. The change never touches the chain: the
commit in progress and the done commits keep their positions, and no change to
the backlog rewrites a commit.

**Placement of a new task.** The user may state a position ("first", "after
task 3", "last"); the stated position wins. Without a stated position, the
orchestrator judges the position among the backlog tasks:

1. A task that a backlog task depends on goes before the dependent task.
2. An urgent task goes first in the backlog.
3. Any other task goes at the end, unless the task touches the same files as
   a backlog task, in which case the task goes beside that task to limit
   rebase conflicts.

The orchestrator states the chosen position and the one-line reason in the
reply, and the user may override at any time. An override moves the task in
the plan file.

**Removal.** A backlog task is removed from the plan file. A task that already
has a commit is not in the backlog: the orchestrator asks the user how to
treat the commit and does not abandon the commit on the orchestrator's own
judgment.

## Choosing the verification checkout

Pick the value in this order, and state the winner in one line when the run
starts (for example "verification checkout: throwaway workspace, from
CLAUDE.md"):

1. An explicit instruction from the user in the conversation.
2. A line in the repository's agent-context file (`CLAUDE.md`), such as
   `chain verification: throwaway workspace`.
3. The environment variable `CHAIN_VERIFY_CHECKOUT`: the value `workspace`
   selects `throwaway workspace`, and any other value or no value selects
   `main checkout`.
4. Otherwise `main checkout`.

Choose `throwaway workspace` when the main checkout must stay clean: for
example, a Stop hook that blocks whenever the main checkout holds uncommitted
files fires during every CI run, because the checked-out commit's files look
uncommitted to git.

The default stays `main checkout`, so such an environment needs an explicit
choice. The cheapest choice that sticks is `CHAIN_VERIFY_CHECKOUT=workspace` in
the environment settings, which changes no repository file; a `CLAUDE.md` line
must be copied into every agent-context file that a repository keeps identical.

## Parking the main checkout

Review needs no checkout: `jj show <change-id>` reads the commit. Only
`main checkout` verification needs `jj edit <change-id>` in the main checkout.
A commit checked out in the main checkout and edited by a worker's workspace
makes the working copy stale. Create one empty parking commit at the start, off
the base:

```bash
jj new --no-edit <base> -m "parking, never push"
```

With `main checkout` verification, run `jj edit <parking-change-id>` after
every CI run. With `throwaway workspace` verification, no command moves the
main checkout, and the parking commit serves only as the base of each
verification workspace. In both variants, the parking commit stays outside the
chain, and the push step never touches the parking commit.

The workspace-scope guard acts only on `haiku-worker` agents. The orchestrator's
own `jj --repository` commands, the CI script and the verification workspace
need no registration. A worker's `(cd "<WORKSPACE_DIR>" && npm ci)` names the
registered workspace and passes the guard.

## Worker self-check footer

Workers run in a fresh workspace without installed dependencies, so a worker
cannot run the formatter, the type checker or the tests until the worker
installs them. A commit that fails CI on a formatting error costs a full CI run,
an amend round and a worker launch. Before the first task, read the repository's
agent-context file and the CI script, and record the exact install command and
the exact fast checks: the formatter in fix mode on the changed files, then lint
and type check, then the tests that cover the change. End every brief and
every amend-round brief with:

```
Before editing: install the dependencies inside your own workspace only:
(cd "<WORKSPACE_DIR>" && <install command>)
The install directory is gitignored and never enters the commit.

After editing, run these checks in order, each as
(cd "<WORKSPACE_DIR>" && <command>): <formatter fix command>, then
<lint and type check commands>, then <test commands for the change>. Never
hand-format. Fix every failure in the same commit and rerun until every check
passes.

Finish with jj --repository "<WORKSPACE_DIR>" diff --stat. The output must list
only the intended files.

Report the commands you ran and the exit code of each.
```

The footer cuts avoidable CI failures and replaces no verification: the
orchestrator still reads the diff (step 4) and runs the CI script (step 5), and
a worker's report is not evidence. An amend round gets the footer too, because
a fix can introduce a new defect.

An install that takes several minutes per worker still costs less than a failed
CI run plus an amend round. When one install takes longer than one CI run, skip
the install: run the formatter once in the verification checkout and pass the
output to the worker in the brief.

Every amend round runs in a new workspace, so every round installs again. When
the repository's package manager documents a setting for a shared cache
directory (read the package manager's documentation; never guess the setting's
name), name that setting and one shared directory in the footer, so repeat
installs read from the cache.

## Push the chain

Run only when the user named a remote and a branch, and only when the tip is a
done commit.

```bash
jj bookmark set <branch> -r <tip-of-done-commits>
jj git push --remote <remote> -b <branch>
```

Push after every commit that becomes done, and after every rebase. A rebase
rewrites commits, so the push is a forced update of the one named branch. The
user's naming of the branch is the authorization. If the push is rejected,
read the reason and fix the cause; never push to a different branch.

## Rebase onto main

Run only with a push target, and run before starting each task and after each
done commit:

```bash
jj git fetch --remote <remote>
jj log -r 'main@<remote> ~ ::<chain-root>' --no-graph -T commit_id
```

When the second command prints a commit ID, `main@<remote>` holds commits
that the chain does not contain.
Rebase the whole chain:

```bash
jj rebase -s <chain-root> -d main@<remote>
```

`<chain-root>` is the first commit of the chain. Then:

1. **Find the conflicts:** `jj log -r 'conflicts() & <chain-root>::'`.
2. **Resolve bottom-up.** For the lowest conflicted commit, run an amend round
   through `spawn-haiku-amend-commit`: the brief names the conflicted files, says to
   resolve every conflict marker, and states what each side of the conflict was
   meant to do. Descendants rebase automatically and may conflict in turn;
   repeat until `conflicts()` is empty for the chain.
3. **Re-verify.** Run review (step 4) and the CI script (step 5) on every
   commit that had a conflict and on the tip. The earlier done status of a
   rewritten commit holds only after the re-run passes.
4. **Push** the chain.

When the conflict resolution requires a product decision, stop and ask the user.

## Never end a turn with work left

Load the `autonomous-loop-discipline` skill and follow `autonomous-loop-discipline`.
In short: while a task remains, the last action of the turn is a tool call
that starts the next step; wait on a worker with a background command plus
one fallback wakeup of 1200 seconds or more.

## Stop conditions

Stop only when every task is done, or when what remains needs something only
the user can provide (a product decision, credentials, a push rejection that
the user must resolve). Final report: the chain (one line per commit: change
ID, description, CI result), the push state (branch, remote, tip), and open
decisions.

## Don'ts

- Never write code in the main checkout.
- Never stack two commits for one task, and never merge two tasks into one
  commit.
- Never mark a commit done on a CI result from an earlier version of the
  commit.
- Never push without a named remote and branch, and never push any other
  bookmark.
- Never open a PR, merge, or run `gh`.
- Never use a model other than Haiku for a worker without the user's explicit
  word.
