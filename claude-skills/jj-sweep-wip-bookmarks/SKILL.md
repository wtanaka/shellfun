---
name: jj-sweep-wip-bookmarks
description: Delete stale `<task>-wip` jj bookmarks whose commit is already reachable another way (merged, pushed, under another bookmark). Run the sweep before creating a worker workspace, or whenever `jj bookmark list` shows leftover `*-wip` bookmarks.
---

# Sweep stale `-wip` bookmarks

A `<task>-wip` bookmark keeps a worker's commit visible in `jj log` after the
temporary workspace is forgotten. Once something else keeps the commit
reachable, the bookmark is redundant.

## Run the sweep

```bash
sh ~/.claude/skills/jj-sweep-wip-bookmarks/sweep.sh        # delete
sh ~/.claude/skills/jj-sweep-wip-bookmarks/sweep.sh -n     # list only
```

Run the script from the repo's main checkout. The trunk bookmark is `main`,
else `master`; set `JJ_SWEEP_TRUNK` to override the choice.

## What the sweep deletes

The sweep deletes a `-wip` bookmark only when the bookmark's commit is an
ancestor of one of: the trunk bookmark, any other bookmark, any remote
bookmark, or the default workspace's `@`. A bookmark for work still in flight
is never reachable from any of those heads, so the sweep cannot delete a live
bookmark of another concurrent run. Running the sweep from several runs at once
is safe; jj serializes the operations, so a command may block for a few seconds.

## Rules

1. Select bookmarks by name pattern (`'glob:*-wip'`). Never select with
   `jj bookmark list -r <revset>`: that form lists every bookmark on a matching
   commit. The `-r` form once deleted `main` itself.
2. Keep the `grep -- '-wip$'` guard. The sweep touches only names ending in
   `-wip`.
3. The sweep does not touch the bookmark that a run creates for the run's own
   commit. A run always creates that bookmark, because the bookmark keeps the
   commit visible.
