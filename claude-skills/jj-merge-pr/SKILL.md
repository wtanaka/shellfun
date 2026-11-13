---
name: jj-merge-pr
description: Merge a pull request (PR) with jj, but only if all five merge checks pass; when any check fails, nothing is merged. Use whenever an orchestrator merges a PR autonomously, instead of `gh pr merge`.
---

# Merge a PR only when all merge checks pass

```bash
sh ~/.claude/skills/jj-merge-pr/merge.sh <PR> --reviewed [--rebase|--squash]
```

Run the script from the repo's main checkout, as a standalone command, with a long
timeout or in the background: the script blocks while CI runs. The exit status
of the script is the verdict.

## The merge checks

| # | Check | Enforced by |
|---|---|---|
| 1 | The PR is open and not a draft | script, before any other check |
| 2 | One CI run at a time: no CI run for another commit is in progress or queued (the script ignores runs from pushes to the base branch and scheduled runs) | script, `gh run list` |
| 3 | The PR has at least one commit past `origin`'s base branch. With 2 or more commits, the caller must choose a merge method: `--rebase` keeps every commit, `--squash` makes one commit. The script finds the PR head by commit hash, so a branch on another remote works | script, after `jj git fetch --all-remotes` |
| 4 | The orchestrator reviewed the diff and addressed all feedback | the orchestrator asserts the review with `--reviewed` |
| 5 | CI is green on the latest push to the PR | `jj ghprcqmfr` waits fail-fast and refuses on red |

When check 1, 2 or 3 fails, the script exits 10 with one line naming the check
and does not merge. When the PR has 2 or more commits and no method flag was
given, the script exits 11, lists the commits and does not merge. Without `--reviewed`, the script exits 64 and does not
merge. When CI is red or the merge is refused, the script exits with the
status of `jj ghprcqmfr` and the PR stays unmerged. On success, the script
exits 0.

## Rules

1. Merge only through the script. Never run `gh pr merge`, never enable
   auto-merge.
2. Pass `--reviewed` only after reading the diff and sending back every defect
   (re-review after each amend). Only the `--reviewed` flag records the review;
   no other check verifies the review.
3. Never merge a PR parked for human review without the user's explicit word.
   Do not run the script for that PR.
4. Run the script as a standalone command, never chained after a status pipe
   (`gh pr checks | tail -1 && ...` once ran a merge on a failing check because
   `tail` exits 0).
5. Fix the cause of a failed merge check; never bypass the check.
6. On exit 11 (several commits, no method), ask the user whether to keep every
   commit (`--rebase`) or merge one commit (`--squash`), then rerun the script
   with the chosen flag. Never choose the method without the user's answer,
   unless a standing instruction from the user names the method. A PR with one
   commit needs no flag.
7. After a successful merge, push the base branch to any other remote that the
   repo's own instructions name (for example
   `jj git push --remote <remote> -b main`).
8. `jj ghprcwq <PR>` waits for CI and does not merge; run `jj ghprcwq <PR>` to
   get the CI verdict before deciding to review or merge.
