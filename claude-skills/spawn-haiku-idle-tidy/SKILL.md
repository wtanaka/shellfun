---
name: spawn-haiku-idle-tidy
description: A higher-level wrapper around spawn-haiku-autonomous-onepr-merge. The wrapper drains the work queue of spawn-haiku-autonomous-onepr-merge first. Only when the queue is idle does the wrapper search, unprompted, for UNAMBIGUOUS wins that make the repo more DRY, make illegal states unrepresentable, push logic into pure functions behind thin I/O shells, or make the repo lint clean, all without any performance cost. Built to run unattended: the wrapper asks the user nothing and leaves no open issues behind; each find becomes one small, self-describing PR that is a lowest-priority A item for the queue skill. Use when the user says "keep the repo tidy while idle", "when the queue is empty look for cleanups", "run the idle-tidy loop", "improve the codebase autonomously, only safe wins".
---

# Idle tidy: the autonomous queue, plus a lowest-priority cleanup scout

`spawn-haiku-idle-tidy` adds exactly one behavior to `spawn-haiku-autonomous-onepr-merge`
(the **queue skill**): what the orchestrator does when the queue is idle. The
queue skill supplies everything else, by reference. Load the queue skill with
the Skill tool once per session (if not already in context) and follow the
queue skill for all mechanics: the H and A queues, one CI run at a time, one
commit per PR, workspaces, guard files, `-wip` bookmarks, review,
merging, the recap, the fallback wakeup. **Do not copy or restate those
rules here. If `spawn-haiku-idle-tidy` and the queue skill disagree, the queue skill
wins.** In particular, every subagent is Haiku (`haiku-worker`,
`model: "haiku"`), no subagent launches another subagent, and no H item
merges without the user's word.

## Unattended by design

The user must be able to leave the loop running and never be interrupted.

- **Never ask the user a question.** Decide by the win checklist (below). When
  the checklist cannot decide, the answer is "skip the candidate". Record
  doubtful, performance-sensitive, ambiguous and design-choice candidates in
  the local ledger; never raise the candidates.
- **Leave nothing open for the user to act on.** Do not file issues, blockers,
  TODO files or review requests. The only durable artifacts are merged PRs
  (each self-describing) and ledger files outside the repo. Close a tidy PR
  that cannot be finished and delete the branch; never leave the PR open as a
  to-do.
- **Say almost nothing.** Print no progress messages. Print the queue skill's
  recap only at the moments the queue skill names. When the loop stops, print
  one short sentence (what merged, what was skipped). Invoking `spawn-haiku-idle-tidy` is
  the user's standing authorization for the queue skill's autonomous
  merge-on-green of tidy PRs, and for nothing else.
- **The user's veto is the revert.** Each merged tidy PR is one commit, so one
  revert undoes the PR. The strict win checklist exists for this reason.

## When tidy work starts

Act only when **all** of these hold, and re-check each condition every time:

1. The A queue is empty and the H slot holds nothing that needs work (a parked
   H PR with green CI is fine).
2. No CI run is active and no worker is in flight.
3. The user has handed over no new work (see "Priority" below).

Never start a second tidy PR while one tidy PR is open.

## Priority: self-initiated tidy work is always last

Everything that `spawn-haiku-idle-tidy` starts on the orchestrator's own initiative has the **lowest priority
there is**, below every H item and every A item, with no exceptions:

- **Anything the user directs wins, every time.** Directed work includes
  `/spawn-haiku-autonomous-onepr-merge` invoked directly, an explicit request
  to work on a queue item or an issue, feedback on an H item, and any new
  instruction. The progress of a tidy item does not change the outcome.
- **Tidy work never makes user work wait.** When user work arrives while a
  tidy worker runs, let the worker finish the current command and start
  nothing new for the worker. When a tidy PR is in CI and the user's item needs
  the CI slot, cancel the tidy CI run at once (`gh run cancel`), leave the tidy
  PR open and unmerged, and run the user's item. Resume the tidy PR only when
  the queue is idle again, after rebasing the tidy PR onto the new `main`.
  When the tidy PR no longer passes the win checklist, or has waited more than
  24 hours, close the PR and delete the branch.
- **Tidy items never go ahead of anything already queued.** Queue a tidy item
  behind every existing and future item, including items the user adds later.
- **The user's direct use of the queue skill overrides `spawn-haiku-idle-tidy`.** While the
  user drives the queue, do not scout and do not start tidy PRs. Resume only
  after the queue is idle and the user has asked for nothing else.
- **Never merge a tidy PR while user work is waiting**, even when the tidy PR
  has green CI.

## What counts as a win (the four themes)

The first three themes apply the principles of the `code-design-bias` skill as
refactors of existing code. Load `code-design-bias` and use the wording there
as the bar for an improvement; the rule for each theme lives there, not here.

1. **DRY:** collapse copies that must change together into one definition.
2. **Illegal states unrepresentable:** replace flags plus optional fields, raw
   values with runtime checks, and sentinel values with types that cannot be
   wrong.
3. **Pure core, thin shell:** move decision, parsing, scheduling and
   formatting logic out of adapters into pure, total functions, and add tests
   for each function, including edge cases.
4. **Lint clean.** Fix the findings that the repo's own linter reports, in the
   way the rule intends. Never add a lint-suppression comment, never loosen a
   rule or config, never raise a size or budget limit.

## The unambiguous-win checklist (all lines must hold, or the candidate is not a win)

Build a candidate only when every line is true. When any line is doubtful, do
**not** build the candidate: record the candidate (see "The ledger") and move
on. Doubt means no.

- **Behavior identical.** Existing tests prove identical behavior, or new
  tests added in the same commit do. Outputs, messages, exports, wire formats,
  serialized output and any checksum or hash the program exposes stay the
  same.
- **No performance cost.** The change is outside every hot path (inner loops,
  per-frame or per-request code, allocation-sensitive or typed-array code,
  anything the repo's perf, bench or size checks cover), unless a measurement
  shows equal speed. Workers run targeted tests only (no full suite, bench or
  perf run) unless the repo or the user says otherwise, so **`spawn-haiku-idle-tidy` does
  not build hot-path candidates**. Record each hot-path candidate in the
  ledger as "perf-sensitive" and leave the code alone. When the hotness of
  code is unknown, treat the code as hot.
- **Small.** One theme, at most 6 files and 150 changed lines, one commit.
  Split a bigger win into several independent PRs, each passing the checklist
  separately, or record the win in the ledger and skip the win.
- **Net simpler.** Fewer definitions, fewer states, or fewer lint findings
  afterward. A cleanup that adds more code than the cleanup removes needs a
  stated reason (for example, a new sum type that deletes a runtime check).
- **Binding rules respected.** Read the repo's own instructions first
  (CLAUDE.md, AGENTS.md, CONTRIBUTING, and any protocol, plan or design-system
  document the instructions point to) and treat every constraint in the
  instructions as binding for tidy work. In particular: do not edit planning,
  ledger or generated files that the instructions mark as off limits; do not
  touch registries and indexes unless the change requires; follow the design
  system for any UI change; keep output bit-identical for code whose output
  feeds a deterministic hash, replay, snapshot or golden file (add an equality
  test); add no new dependency. When the instructions are silent or unclear
  on something a candidate touches, the candidate fails the checklist.
- **No PII.** No hostnames, absolute paths, personal data or other project
  names in code, comments, commit messages, issues or PR bodies. No attribution
  lines.

## The loop

Run the loop whenever the "When tidy work starts" conditions hold.

1. **Check the ledger and the open issues first** (see "The ledger"; list the
   ledger directory and read only the entries for the area about to be
   scanned). Do not rediscover a rejected candidate and do not duplicate an
   open issue.
2. **Detect, cheaply and deterministically, before reading code.** Run
   mechanical detectors from the orchestrator (read-only, nearly free):
   - a duplicated-block scan (normalized windows of 8 or more non-trivial
     lines across the source directories), plus a grep for repeated literals
     and for the same regex, constant or format string defined twice;
   - the repo's own lint and type-check commands (the commands named in the
     repo's instructions or CI), to list findings;
   - greps for the smells of themes 2 and 3, in the repo's language: sentinel
     returns, unchecked casts or force-unwraps on parsed data, a boolean next
     to optional fields, logic inside I/O adapters.
   Only when a detector's output needs reading to judge a candidate, hand one
   Haiku scout one narrow area, read-only, in a separate workspace (never the main
   checkout), and ask for candidates with file and line evidence. A scout
   proposes and never edits.
3. **Check every candidate** against the win checklist above, from the
   evidence, in the orchestrator. Keep at most the best three candidates per
   cycle. Record every candidate that fails the checklist in the ledger with
   the reason.
4. **Brief the worker, no issue.** For each surviving candidate, one at a
   time, write the queue skill's usual self-contained brief (never an issue).
   The PR body is the record: a few bullets on what was duplicated or unsafe
   and what changed, the theme, one line per checklist line saying why the
   change is behavior-identical and outside every hot path, plus a test plan.
5. **Queue the candidate** as the lowest-priority A item and let the queue
   skill run the item: workspace, worker, review (including a check of the
   checklist against the real diff), CI, merge exactly as the queue skill
   specifies, clean up. Include the principles of the `code-design-bias` skill
   in every brief, and tell the worker to stop and report, without widening the
   change, when a checklist line stops holding.
6. **Review against the checklist, not only the brief.** When the diff touches
   a hot path, grows past the size cap, changes behavior, or needs a lint
   suppression, send the PR back through an amend round (the queue skill's cap
   applies). When the PR still fails the checklist, close the PR, delete the
   branch, record the reason in the ledger, and move on. Never merge a tidy
   PR that the checklist would reject because the PR is "mostly fine".
7. Return to step 1 when the PR has merged or closed.

## The ledger (so the loop terminates and does not repeat work)

Keep the ledger as **many tiny local files in a directory outside any
repository and outside version control**:
`~/.claude/idle-tidy/<repo-directory-name>/` (create the directory if absent).
Never commit the ledger, never push the ledger, never put ledger content in a
GitHub issue, comment or PR, and never write the ledger into the repo or plan
files.

- **One file per rejected candidate**, named `<theme>--<area-slug>.md` (theme
  is `dry`, `states`, `pure` or `lint`; the slug names the file or module, for
  example `dry--release-tag-format.md`). The name alone says what the entry
  is, so listing the directory yields the index. Body: at most five lines: the
  location(s), what was found, the checklist line that failed, the date.
- **A cycle that finds nothing** leaves one file, `cycle--YYYY-MM-DD.md`,
  with a single line.
- **Reading is cheap by design.** Step 1 lists the directory (names only) and
  opens only the files whose area is about to be scanned. Never read the whole
  directory into context.
- **Cleanup is deleting files.** Delete an entry when the location no longer
  exists, when the code changed enough that the checklist may now hold, or
  when the entry is older than 90 days; delete `cycle--` files after the next
  cycle. The user can clear the ledger with `rm -r` and nothing breaks.
- The ledger is the only memory that `spawn-haiku-idle-tidy` keeps. When the directory is
  missing, the loop rediscovers candidates; the rediscovery is slower but safe. Never
  raise ledger content with the user and never turn ledger content into an
  issue.

## Stop conditions

Stop when any of these holds. Never loop forever:

- A full cycle (detect, check) finds no unambiguous win. Record the cycle in
  the ledger and stop.
- Three tidy PRs in a row were closed because of the checklist (the detectors
  produce noise). Record the closures in the ledger and stop; do not report the
  closures as a question.
- The user adds work (switch to the queue skill) or asks for a stop.
- The queue skill's own stop conditions apply to anything the queue skill is
  running.

Waking up again: after a stop with nothing found, schedule at most one long
fallback wakeup (several hours) whose only job is to check whether `main` has
new commits since the last cycle. When `main` has no new commits, stop for
good; when `main` has new commits, run one more cycle. Allow at most three
such empty re-checks in a row, then stop for good.

When stopped, print one short sentence (what merged, what was skipped) and,
per the queue skill, the recap. The final message never ends with a question.
A stopped idle-tidy run is a normal, successful end.

## Don'ts

- Don't build a candidate with any doubt: doubt means ledger, not PR.
- Don't ask the user anything, file issues, leave open PRs or branches, or
  create blocker or TODO files: skip, record in the ledger, and keep going.
- Don't touch hot paths, perf budgets, size limits, files the repo marks as
  off limits, lockfiles beyond what a change needs, or lint config.
- Don't bundle themes or unrelated files into one PR, and don't stack commits.
- Don't run scouts in the main checkout, and don't give a scout write access to
  the repo.

The queue skill's rules and Don'ts apply as well (including Haiku-only workers
and no code written in the shared checkout). The "Priority" section above
covers acting while the queue has work.
