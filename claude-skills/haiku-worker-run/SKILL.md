---
name: haiku-worker-run
description: Run one Haiku worker in a dedicated jj workspace: sweep stale bookmarks, create the workspace, launch one haiku-worker with a self-contained prompt, register the workspace with the workspace-scope guard, and tear down the workspace afterwards. Takes four inputs: a base commit, the worker's steps, teardown options and a closing message.
---

# Run one Haiku worker in a dedicated jj workspace

Goal: minimum token spend on any model other than the cheapest model. The
orchestrator (the session that invokes the skill) creates the workspace,
launches ONE Haiku subagent (the worker) with a complete, self-contained prompt
that names the workspace, registers the workspace, and stops. The orchestrator
does not read the worker's output, verify the worker's edits or wait. Any
follow-up is a separate, later invocation.

The flow takes four inputs: the **base** (the commit where the
workspace starts), the **worker steps** (the end of the prompt), the
**teardown options** (the `jj-worker-workspace` `teardown` command owns the
teardown; the only variation is a flag such as `--amended`), and the
message to the user afterwards.

## The flow

1. **Fill in** `<the thing to do>` with exactly the user's request, concrete
   enough that the worker needs no clarification: file paths, the specific
   change, every constraint the user mentioned.
2. **Sweep stale `-wip` bookmarks, then create the workspace.** Load the
   `jj-sweep-wip-bookmarks` skill and run the sweep that `jj-sweep-wip-bookmarks` describes. Then run from
   the main checkout:
   ```bash
   sh ~/.claude/skills/jj-worker-workspace/workspace.sh new <short-task-id> <base>
   ```
   Pick `<short-task-id>` (kebab-case, derived from the task). `new` prints
   `WORKSPACE_DIR`, `MAIN_CHECKOUT` and `TMP_ROOT`. Copy-paste those literal
   values, never retype them, everywhere the prompt and the later steps
   mention the values. If `new` fails, stop and fix the failure instead of launching
   the worker into a workspace that does not exist.
3. **Launch exactly one Haiku subagent** (`Agent` tool, `model: "haiku"`,
   `subagent_type: "haiku-worker"`, a restricted agent type with no Agent tool)
   with the prompt below, verbatim except for the bracketed fill-ins. Run the
   subagent in the background. The launch returns an `agentId` immediately,
   before the subagent's first tool call runs. Capture the `agentId` as
   `<agentId>`.
4. **Register the workspace immediately**, as the *very next tool call*: no
   batching, no status checks, no waiting for the worker to finish.
   ```bash
   sh ~/.claude/skills/jj-worker-workspace/workspace.sh register <agentId> "<WORKSPACE_DIR>"
   ```
   Registration is mandatory. The workspace-scope guard (defined in
   `jj-worker-workspace`) blocks every repo-mutating command from a worker
   whose command does not name the registered workspace, so a skipped or
   delayed registration blocks the worker. The `haiku-worker` agent rules tell
   the worker to retry on "no workspace registered" as a backstop.
5. **Send the user one short line** confirming the launch.
6. **Tear down** when the completion notification arrives, or when the
   orchestrator stops or kills the worker because the worker is stuck. Tear
   down unconditionally, whatever the worker reported: run
   `sh ~/.claude/skills/jj-worker-workspace/workspace.sh teardown <short-task-id> <agentId>`
   with the teardown options. The command snapshots the workspace
   (saving edits made after the worker's last jj command), keeps the worker's commit reachable,
   forgets the workspace and deletes the workspace directory and the
   registration. Never skip teardown because the run looked stuck or empty;
   only the snapshot shows the real state. If teardown fails, the command
   leaves everything in place: fix the cause and rerun the command. Never run
   `jj workspace forget` or `rm` by hand.

## The prompt

The standard header, then the worker steps. Stricter wording may replace the
header.

```
Only job: do the task below, end to end, alone, then stop.

The workspace already exists at: <$WORKSPACE_DIR>
The main checkout, never touched, is: <$MAIN_CHECKOUT>
Follow the standing workspace rules: jj only, every command scoped to the
workspace (`jj --repository "<$WORKSPACE_DIR>" ...`, or
`(cd "<$WORKSPACE_DIR>" && <command>)`).

Steps:
<the worker steps>
```

## Rules

1. **The orchestrator never reviews the diff, the commit or the CI status
   after the launch.** Skipping review is the entire cost saving. A later
   review is a different, explicit request.
2. **The orchestrator creates and destroys the workspace, never the worker.** A
   prior run let the worker create the workspace, and unscoped worker commands
   leaked edits into the shared main checkout. An instruction such as "be
   careful" does not enforce anything. The enforcement is structural: the
   worker receives only an absolute path, and every command is self-contained.
3. **Exactly one Haiku subagent, and no subagents of subagents.**
4. **One commit, ever.** A fix during the run goes into the same commit.
5. **Teardown always runs, and the commit must stay reachable.** A commit with
   no bookmark and no workspace pointing at the commit disappears from
   `jj log` and becomes eligible for garbage collection the moment the
   workspace is forgotten. The teardown script prevents the loss; never
   replace the script with manual steps.
