---
name: spawn-dependabot-rebase-merge
description: Work through the open Dependabot PRs one at a time, sharing the one-CI-at-a-time queue with spawn-haiku-autonomous-onepr-merge. The orchestrator touches a Dependabot PR only by posting `@dependabot rebase` as a PR comment, never pushes to a Dependabot branch, and writes no code. The orchestrator sequences the rebases so only one PR runs CI at a time, reviews each bump, requires green CI and, for a PR with several commits, the user's choice of rebase or squash, and merges with `jj-merge-pr`. Use when the user says "merge the dependabot PRs", "rebase and merge dependabot one by one", "clear the dependabot backlog". Same queue and merge conditions as spawn-haiku-autonomous-onepr-merge, but with no worker and no amend: Dependabot's own rebase replaces the amend.
---

# Dependabot PRs: rebase by comment, one CI at a time, review, merge

`spawn-dependabot-rebase-merge` is a sibling of
`spawn-haiku-autonomous-onepr-merge` and **shares the
queue** of `spawn-haiku-autonomous-onepr-merge`: the invariants of the
autonomous queue (A) apply, specialised below, and a Dependabot PR is one more
A item. The differences:

- The orchestrator does the work, and no Haiku worker runs, because the only
  action is posting a comment (no code, no workspace, no guard registration).
- Dependabot's own rebase replaces the amend, triggered by the comment
  `@dependabot rebase`. The comment is the **only** interaction allowed with a
  Dependabot PR: never `@dependabot recreate`, `ignore`, `close` or `merge`,
  never a push to the Dependabot branch, never an edit of the PR's files,
  never an edit of the PR body.
- `spawn-dependabot-rebase-merge` authorizes the orchestrator to merge with `jj-merge-pr`, under the
  same conditions as `spawn-haiku-autonomous-onepr-merge`.

## The invariants (the `jj-merge-pr` merge checks, specialised for Dependabot)

Load `jj-merge-pr`. That skill holds the merge checks (open PR, one CI run at a
time, a commit past `main`, a merge method for several commits, green CI,
reviewed diff) and does the merge.
`spawn-dependabot-rebase-merge` adds:

1. **One CI active at a time, across both skills.** Before posting a rebase
   comment, confirm that no other PR (Dependabot, Haiku, another agent session,
   a parked human slot (H) PR that the user asked to run) has a CI run in
   progress: `gh run list --status in_progress` and `--status queued` for the
   repo must both print nothing. Dependabot also rebases PRs unprompted when
   `main` moves; when a CI run that the orchestrator did not start is active,
   wait.
2. **Several commits need the user's choice of merge method.** A PR rebased by
   Dependabot usually holds one commit, but a workflow may add another commit.
   When the merge script exits 11 (several commits), report the commits to the
   user and ask whether to keep every commit (`--rebase`) or merge one commit
   (`--squash`); skip the PR meanwhile and rerun the script with the chosen
   flag once the user answers. Never choose the method without the answer.
3. **Review first** (checklist below), then merge only with
   `sh ~/.claude/skills/jj-merge-pr/merge.sh <PR> --reviewed`. After the whole
   run is done and no other agent session is active, push `main` to any other
   remote that the repo's own instructions name.
4. **Never touch a PR that the user parked, or a human slot (H) item.**

## Order and selection

- List: `gh pr list --repo <owner/repo> --author "app/dependabot" --state open --json number,title,headRefName,mergeable,statusCheckRollup`.
- Skip and report (never merge) a PR that: is a **major version bump** of a
  runtime or build dependency (report the PR for the user's decision), has an
  unresolved conflict Dependabot cannot rebase, changes more files than a
  manifest, lockfile or pin, or fails the review below.
- Order: security updates first, then GitHub Actions pins, then dev-only
  dependencies, then runtime, smallest diff first. Group-update PRs count as
  one item.
- Take **one item at a time.** Post the rebase comment for the next item only
  after the previous item has merged (or been skipped) and the CI run of the
  previous item has finished.

## Review checklist (orchestrator, every PR)

Read the diff (`gh pr diff <PR>`), not the description. The diff must:
- change only version strings in manifests, lockfiles and workflow pins
  (a `uses:` bump must stay a version/SHA of the same action);
- not add, remove or rename a dependency, and not change features;
- keep lockfiles consistent with manifests (a manifest bump with an untouched
  lockfile, or the reverse, is a skip);
- not touch a protected file (a checksum or lint-digest file, budgets, ratchets). The
  lint digest blanks dependency version strings, so a plain bump should not
  change the digest; when the digest check fails, report the PR and skip,
  never edit the digest;
- leak nothing (no hostnames, absolute paths, usernames in the diff).
Accept a pure patch or minor bump with green CI and a diff that meets every
point above.

## The loop (per PR)

1. Confirm that no CI run is active (invariant 1) and that the PR is not
   already rebased onto the current `main@origin` with green CI. When the PR
   already meets both conditions, skip to step 4.
2. Post the rebase: `gh pr comment <PR> --repo <owner/repo> --body "@dependabot rebase"`.
   The `@dependabot` mention is the one intended notification; make
   `@dependabot rebase` the only text of the comment.
3. Wait for Dependabot to force-push. Poll **once** per check-in, never in a
   tight loop: run `jj git fetch`, then compare `gh pr view <PR> --json
   headRefOid` against the old head. Schedule the next check-in with
   `ScheduleWakeup` (120 seconds); Dependabot usually answers within 1 to 2
   minutes. When nothing has changed after 10 minutes, report the PR and move
   on to the next PR without posting a second comment.
4. Wait for CI on the new head with `jj ghprcwq <PR>` (silent; the exit status
   is the verdict; run with a long timeout or in the background). On a failure,
   read the log (`gh run view <run-id> --log-failed`): rerun an infrastructure
   flake once with `gh run rerun --failed`; skip and report a real failure,
   never edit.
5. Review (checklist above), then run
   `sh ~/.claude/skills/jj-merge-pr/merge.sh <PR> --reviewed` as a standalone
   command; the script re-checks one CI run at a time and the commit count, and refuses
   when a check fails; exit 11 means several commits, so ask the user (invariant 2).
6. Clean up: `jj git fetch`, `jj workspace update-stale` if needed, confirm no
   stray bookmark or workspace remains. Then go to step 1 for the next PR.

## Stop conditions and report

Stop when every open Dependabot PR has merged or been skipped. Final report: PRs
merged, PRs skipped with the reason (major bump, review failure, red CI, more
than one commit and no method chosen yet, no response from Dependabot), and anything needing the user.
End every user-facing message with the two-line queue recap (`H:` / `A:`).

## Don'ts

- Don't post anything but `@dependabot rebase` on a Dependabot PR.
- Don't push to, edit, close or reopen a Dependabot PR or branch.
- Don't run two CI runs at once, across `spawn-dependabot-rebase-merge` and `spawn-haiku-autonomous-onepr-merge`.
- Don't merge without review and green CI, or a PR with several commits without the user's merge-method answer.
- Don't edit a protected file to make a Dependabot bump pass.
