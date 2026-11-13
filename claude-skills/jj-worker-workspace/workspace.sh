#!/bin/sh
# Lifecycle of a jj workspace for a worker subagent. Run from the repo's main
# checkout.
#   new TASK_ID [REV]         create the workspace (REV defaults to main)
#   register AGENT_ID DIR     register DIR as the workspace of that worker with
#                             the workspace-scope guard hook
#   teardown [--amended CHANGE_ID] TASK_ID [AGENT_ID]
#                             snapshot the workspace, bookmark TASK_ID-wip on
#                             the worker's commit, forget the workspace, delete
#                             the workspace directory, remove the registration.
#                             With --amended, the worker edited the existing
#                             commit CHANGE_ID, and the commit stays visible
#                             under the commit's own change ID: no bookmark,
#                             unless the workspace
#                             holds another non-empty commit; that commit is
#                             bookmarked so no work is lost.
#                             Safe to rerun after a partial run.
# `new` prints three lines (values are printed as is, unquoted; do not eval):
#   WORKSPACE_DIR=<absolute path of the new workspace>
#   MAIN_CHECKOUT=<absolute path of the main checkout>
#   TMP_ROOT=<temp dir without trailing slash>
# $TMPDIR ends in a slash on macOS and is not /tmp, so the script builds the
# path once from $TMPDIR with the slash stripped. Use the printed values
# verbatim.
set -u

die() { printf 'workspace.sh: %s\n' "$*" >&2; exit 1; }

cmd=${1:-}
validate_task() {
    case $1 in
        ''|-*|*[!a-z0-9-]*) die "TASK_ID must be kebab-case (a-z, 0-9, -), got '$1'" ;;
    esac
}
validate_agent() {
    case $1 in
        ''|*[!A-Za-z0-9_-]*) die "AGENT_ID must match [A-Za-z0-9_-]+, got '$1'" ;;
    esac
}

main=$(jj workspace root) || die "not inside a jj repo"
repo=$(basename "$main")
tmp=${TMPDIR:-/tmp}
tmp=${tmp%/}
guard_dir=${CLAUDE_WORKSPACE_GUARD_DIR:-$tmp/claude-workspace-guard}

# Fatal if jj cannot list workspaces (for example a stale main checkout): the
# script must never read an error as "the workspace is already forgotten".
workspaces=
load_workspaces() {
    workspaces=$(jj --ignore-working-copy workspace list -T 'name ++ "\n"') ||
        die "cannot list workspaces; fix jj (stale working copy?) and rerun"
}
has_workspace() {   # has_workspace NAME
    printf '%s\n' "$workspaces" | grep -qx -- "$1"
}

case $cmd in
new)
    task=${2:-}
    rev=${3:-main}
    validate_task "$task"
    dir="$tmp/$repo-$task"
    [ ! -e "$dir" ] || die "$dir already exists"
    load_workspaces
    ! has_workspace "$task" || die "a workspace named '$task' already exists"
    if [ -n "$(jj bookmark list -T 'name ++ "\n"' "exact:$task-wip" 2>/dev/null)" ]; then
        die "bookmark $task-wip already exists; pick another TASK_ID or delete the bookmark"
    fi
    jj workspace add --name "$task" "$dir" -r "$rev" >&2 || die "jj workspace add failed"
    ls "$dir" >/dev/null 2>&1 || die "$dir missing after workspace add"
    jj workspace list >&2
    printf 'WORKSPACE_DIR=%s\nMAIN_CHECKOUT=%s\nTMP_ROOT=%s\n' "$dir" "$main" "$tmp"
    ;;
register)
    agent=${2:-}
    dir=${3:-}
    validate_agent "$agent"
    case $dir in /*) ;; *) die "DIR must be an absolute path, got '$dir'" ;; esac
    [ -d "$dir" ] || die "$dir is not a directory"
    mkdir -p "$guard_dir" || die "cannot create $guard_dir"
    printf '%s' "$dir" > "$guard_dir/$agent.path" || die "cannot write registration"
    echo "registered $agent -> $dir"
    ;;
teardown)
    shift
    amended=
    if [ "${1:-}" = --amended ]; then
        amended=${2:-}
        [ -n "$amended" ] || die "--amended needs a CHANGE_ID"
        shift 2
    fi
    task=${1:-}
    agent=${2:-}
    validate_task "$task"
    [ -z "$agent" ] || validate_agent "$agent"
    dir="$tmp/$repo-$task"
    kept="workspace removed"
    load_workspaces
    if has_workspace "$task"; then
        # 1. Snapshot first: jj records file edits only when a jj command runs
        #    in the workspace, and the bookmark below must follow the commit
        #    that the snapshot rewrites. On failure, abort and leave everything.
        jj --repository "$dir" status >&2 || die "snapshot failed; workspace left in place"
        # 2. Bookmark, so the commit stays visible in `jj log` after the
        #    workspace is forgotten. With --amended, bookmark only when the
        #    workspace holds another non-empty commit.
        mark=1
        if [ -n "$amended" ]; then
            mark=0
            want=$(jj log -r "$amended" --no-graph -T change_id 2>/dev/null)
            have=$(jj log -r "$task@" --no-graph -T change_id 2>/dev/null)
            if [ -z "$want" ] || [ "$want" != "$have" ]; then
                if [ "$(jj log -r "$task@" --no-graph -T 'if(empty, "empty", "full")' 2>/dev/null)" = full ]; then
                    mark=1
                    echo "workspace holds a commit other than $amended; keeping the commit" >&2
                fi
            fi
        fi
        if [ "$mark" -eq 1 ]; then
            jj bookmark set "$task-wip" -r "$task@" || die "bookmark failed; workspace left in place (if the main checkout is stale, run jj workspace update-stale there and rerun)"
            kept="commit kept at bookmark $task-wip"
        fi
        # 3. Forget the workspace.
        jj workspace forget "$task" || die "workspace forget failed"
    else
        echo "workspace '$task' already forgotten; cleaning up" >&2
        if [ -n "$(jj bookmark list -T 'name ++ "\n"' "exact:$task-wip" 2>/dev/null)" ]; then
            kept="commit kept at bookmark $task-wip"
        fi
    fi
    # 4. Delete the workspace directory (only under the temp root) and the
    #    registration.
    if [ -e "$dir" ]; then
        case $dir in
            "$tmp"/?*) rm -rf "$dir" ;;
            *) die "refusing to delete '$dir' (not under $tmp)" ;;
        esac
    fi
    [ -z "$agent" ] || rm -f "$guard_dir/$agent.path"
    echo "$kept"
    ;;
*)
    die "usage: workspace.sh new TASK_ID [REV] | register AGENT_ID DIR | teardown [--amended CHANGE_ID] TASK_ID [AGENT_ID]"
    ;;
esac
