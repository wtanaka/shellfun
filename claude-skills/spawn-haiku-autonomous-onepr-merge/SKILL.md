---
name: spawn-haiku-autonomous-onepr-merge
description: Work through a set of GitHub issues (an epic) fully autonomously with TWO queues and ONE CI AT A TIME: a human-review slot (H, highest priority, never auto-merged) and an autonomous queue (A, merged on green). Haiku workers write all the code; the orchestrator reviews, iterates, and MERGES the A items. The user explicitly authorizes the orchestrator to merge with `jj-merge-pr` once a PR is green, exactly one commit past main, and all review feedback is addressed. Use when the user says things like "keep working on epic N autonomously", "one PR after another until done", "you're authorized to merge", "I'm going to sleep, keep going". Builds on spawn-haiku-onecommit-pr and spawn-haiku-amend-commit but OVERRIDES the "never review" and "never merge" rules of both skills.
---

# Autonomous epic: two queues (H and A), one CI run at a time, Haiku writes, orchestrator reviews and merges A

`spawn-haiku-autonomous-onepr-merge` is an explicit, standing authorization from the user for the
orchestrator to **merge PRs** (the one action that the worker-launching skills
`spawn-haiku-onecommit-pr` and `spawn-haiku-amend-commit` forbid) and to
**review** the work of Haiku workers (the action that those skills avoid). The orchestrator writes no code: Haiku
workers write the code, and the orchestrator reviews, verifies, sends feedback
and merges. Keep working until the issue set is done; stop to ask the user only
when a rule below says to.

## The invariants (never broken)

The `jj-merge-pr` skill holds the merge checks (one CI run at a time, one
commit past `main`, reviewed diff, green CI) and performs the merge, refusing
when any merge check fails. Merge only through `jj-merge-pr`; load the skill and
follow all of `jj-merge-pr`. `spawn-haiku-autonomous-onepr-merge` adds:

- Each A PR is exactly one commit past `main`. Fixes are amended into that
  commit, never stacked.

- Never push while a CI run for another PR is active. At most one PR is
  *parked* in the human slot (H, see "Two queues" below); apart from the parked
  PR, keep one PR open at a time and start the next PR only after the current
  PR has merged. No stacked PRs.
- Never merge an H item without the user's explicit word; merge A items only.

1. **Every subagent is Haiku (`subagent_type: "haiku-worker"`, `model: "haiku"`)
   unless the user has explicitly authorized another model for that task.** An
   advisor or a worker on a stronger model needs the user's explicit approval
   in the conversation for that kind of task; record the authorization in the
   report. When a task seems to need more than Haiku, shrink the task, split the
   task, or tell the user; never use a stronger model quietly.
2. **No subagent ever launches another subagent.** Only the orchestrator
   launches workers. Workers use the restricted `haiku-worker` agent type; the
   agent type has no Agent tool. Never ask a worker to delegate.

## Two queues: H (human review) and A (autonomous)

Work comes in two kinds, and the orchestrator always works the ready item with
the highest priority:

- **H, the human slot.** Items that need the user's judgment or feedback, such
  as a behavior that a reviewer should try. The human slot holds **one** item
  and has the highest priority.
- **A, the autonomous queue.** Mechanical, well-specified items that merge on
  green CI.

**The loop, run whenever no CI run is active:**
1. If the H slot has work (a new item to build, or new feedback from the user), do H.
2. Otherwise take the next A item.
3. If both are empty, stop and report (see "Stop conditions").

**H items are vertical slices that a person can try.** Each slice ships the
behavior end to end (logic, interface, configuration, tests), usable at the
normal entry point on the day of the merge, with no dead code waiting behind a
final switch. When a slice is not ready for every user, put the slice behind a
*visible* toggle (for example a settings option), never a hidden flag, and
delete the toggle once the slice has proven out. Each H PR description states
what to try (exact steps), what to look for, and the reviewer's question.

**An H item is "ready for feedback" when:** CI is green, the PR holds one
commit, the commit sits on the latest `main`, and the PR description has the
"how to try the slice" steps. The PR then stays open and **unmerged**. Do not touch
the parked PR, except to rebase locally as A items merge; push the rebase (and
let CI run) only when the user is about to review the PR or has asked for
changes. Never merge an H item without the user's explicit word.

**When the user returns with feedback:** let the A item that is in CI finish,
then switch to H: amend the H commit (via `/spawn-haiku-amend-commit`), push,
wait for CI, and park the PR again. When the user says to merge the H item,
merge with `jj-merge-pr` and let the next dependent slice fill the slot.

**Dependent slices** enter the slot in order: slice N+1 enters the slot only
after slice N has merged. When the acceptance check of a slice fails during the
build (for example a measurement shows that the trigger would almost never
fire), rework the slice before parking the PR; never park a slice that gives
the reviewer nothing to see.

**Queue recap.** Print a super-brief queue status, two lines at most, no bullets and no
explanation, only at these moments:

- a PR's CI finishes (passed or failed);
- a merge finishes;
- something now needs the user (a held item, a blocker, a decision);
- the queue is empty or the orchestrator stops.

    H: <slice and state: building / in CI / parked for feedback / none>.
    A: <n> PRs, about <h> h; now <item in CI or next>, then <next>. Held: <what needs the user>.

Every other message (a wait, a worker hand-back, a review result, a rebase, a
push, a flake rerun, an answer to the user's question) gets no recap: state what
happened in one or two sentences, or send nothing. When the user asks for
status, give the recap. State only what changed or comes next; omit anything
the user already knows. When nothing is queued, write "Queue empty".

## Never end a turn with work left

Follow the `autonomous-loop-discipline` skill. Here, a turn may end only when
the queue is empty or everything left needs the user (see "Stop conditions").
The queue recap is printed only at the moments listed under "Queue recap", not
every turn.

## Setup (once)

- Read the epic and the child issues. Write a **plan file** in the scratchpad:
  an ordered list of small steps (one PR each), each step with the issue number,
  the files likely touched, and the acceptance criteria. Small steps beat big
  steps: Haiku does well on narrow, concrete tasks and badly on vague tasks.
- Ask the user every needed question **once, up front**, then work
  autonomously. Afterward, decide by sensible default, record the decision in
  the PR or in an issue comment, and keep working. Never re-ask a resolved
  question.
- Give each worker workspace the untracked tool directories of the checkout,
  so the worker can run the real checks before pushing. After creating the
  workspace, symlink each such directory from the main checkout into the
  workspace (for example the dependency directory `node_modules`:
  `ln -s "$MAIN_CHECKOUT/node_modules" "$WORKSPACE_DIR/node_modules"`, plus any
  other untracked tool directory that the repo's checks need). A `.gitignore`
  entry with a trailing slash (`node_modules/`) does not match a symlink, so
  right after linking run `jj --repository "$WORKSPACE_DIR" status`: when the
  link shows as added, remove the link and have the worker run the repo's own
  install instead; otherwise the commit and the push carry the link into the
  PR. Tell the worker to run the repo's own compile, lint and test commands
  from the workspace and to fix failures before pushing.
- Record the repo facts that workers need: the test command, the CI duration
  (and known flakes), the remotes, the jj workspace path rules, and where a
  visual check is possible.

## Design bias

Put the principles of the `code-design-bias` skill (pure core, total functions,
illegal states unrepresentable) in every brief, and review every diff against
the principles.

## The loop (per step)

1. **Brief.** Write a self-contained task description: the goal, the exact
   files and functions, the constraints (house rules, voice, tests to add), what
   NOT to touch, and the issue number to reference in the commit message.
   Include the commit message format and "Refs #N" or "Closes #N" as
   appropriate. Always include the **design bias** (the `code-design-bias`
   skill) in the brief.
2. **Start the PR.** For new work, invoke `/spawn-haiku-onecommit-pr` with the
   brief and follow `/spawn-haiku-onecommit-pr` exactly. For an existing local
   commit (the user names a change ID, or the queue feeds in dangling commits
   one at a time), invoke `/spawn-haiku-amend-commit` with the change ID and
   the brief when the commit needs changes; then create the bookmark, push it
   and open the PR from the main checkout, because the amend worker never
   pushes. Ignore the "don't review" and "never merge" rules of both launching
   skills; `spawn-haiku-autonomous-onepr-merge` supersedes those rules.
3. **Review.** Read the diff (`jj diff` or `jj show` on the commit, run in the
   main checkout, with no edits there). Check the diff against the brief, the
   repo's rules, and the tests (are the new tests meaningful, not
   tautological?). Haiku cannot browse, so **verify** anything visual in the
   preview browser: start the dev server, seed the state, take a screenshot,
   check the console for errors. Verify claims; never trust the summary of the
   worker. Review against the **design bias** (the `code-design-bias` skill)
   too: logic sitting in an adapter, a partial function, or a state that the
   types allow but the program must not reach is a defect to send back, not a
   style nit.
4. **Iterate.** For every defect or doubt, list precise feedback (file, what is
   wrong, what is wanted, how to verify) and invoke `/spawn-haiku-amend-commit`
   with the change ID of the PR commit. Repeat the review until the diff
   satisfies the brief. Cap the loop at 5 amend rounds; when a step still does
   not converge, shrink the task, rewrite the brief, or abandon the commit and
   start a fresh worker. After each amend, run `jj workspace update-stale` in
   the main checkout when needed. The amend worker never pushes, so push the
   PR's bookmark from the main checkout (`jj git push -b <bookmark>`) to update
   the remote PR; a rebased local commit does not update the PR until pushed.
5. **CI.** Block on CI with `jj ghprcwq <PR>` (silent; waits for the checks,
   fail-fast; the exit status is the verdict: 0 means all checks passed). Run
   the command with a long timeout or in the background; never poll
   `gh pr checks` in a loop. On a non-zero exit, read the failing log
   (`gh run view <run-id> --log-failed`): fix a real failure through an amend
   round; rerun an infrastructure flake (timeout, worker crash with unrelated
   files) with `gh run rerun --failed`, and when the flake recurs, find the
   cause instead of rerunning without end. After each amend push, wait for the
   new CI run to register (`gh pr checks` right after a push can report "no
   checks reported") before running `jj ghprcwq`. Never merge on red.
6. **Merge.** When the review is done and all feedback is addressed, run
   `sh ~/.claude/skills/jj-merge-pr/merge.sh <PR> --reviewed` as a standalone
   command. The script checks that the PR is open, that one CI run is active at
   a time, and that the PR has a commit past `main` (an A PR has exactly one;
   exit 11 means the PR has several, so run an amend round that folds the
   commits into one commit, push, and rerun the script; never choose `--rebase`
   or `--squash` for an A PR without the user's word);
   blocks until CI passes
   (fail-fast); then merges, fetches and rebases locally. The script refuses
   when any check fails. Run `jj ghprcwq` first only to get the CI verdict
   before deciding (for example to review the output of a green run); otherwise
   run the script directly, so one command covers waiting and merging. Then push
   `main` to the other remote(s).
7. **Clean up.** Run `jj abandon` on any divergent leftover copy of the merged
   commit, run `jj workspace update-stale`, delete the `-wip` bookmark of the
   PR, confirm that no stray workspace or guard registration file remains, and
   tick the step off the plan.
8. **Close issues** whose acceptance criteria all hold, with a comment listing
   the PRs and any known gaps. Then go to step 1 for the next step.

## When something goes wrong

- A worker reports "no bug" or "already done": verify the report, then drop the
  step instead of forcing a PR.
- The merge script refuses: read the reason (red CI, conflict, not mergeable),
  fix the cause, never bypass the refusal.
- A conflict appears after `main` moves: have a worker amend (rebase) the single
  commit.
- The review of earlier work by someone else finds problems: file a new issue or
  plan step for the problems; never widen the current PR.
- Out-of-scope discoveries become new issues (and new plan steps); never add
  scope to a PR.

## Stop conditions

Stop only when every planned step has merged, or when the remaining work needs
something that only the user can provide (credentials, art, a product
decision); then list exactly what is blocked and why. The final report lists
the PRs merged, the known gaps, and the open decisions. Keep progress messages
to one line per merged PR.

## Don'ts

- Don't write code in the shared checkout; Haiku workers write the code.
- Don't merge an H item, or push the rebase of a parked H PR, without the
  user's explicit word.
- Don't widen OAuth scopes, secrets, billing, or any other irreversible or
  outward-facing change beyond what the issue asks without the user's approval.

At merge time, the merge checks of `jj-merge-pr` confirm that no other CI run is
active, that the PR has a commit past `main` (several commits make the script
exit 11 and the orchestrator amends the PR into one commit), and that the orchestrator
reviewed the diff; the script refuses to merge on red CI. The invariants above
forbid pushing during a CI run for another PR, a second open PR, and stacked commits
(each A PR is one commit); rules 1 and 2 forbid any model but Haiku and nested subagents.
