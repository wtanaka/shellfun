#!/bin/sh
# Merge a pull request with jj if all merge checks pass; otherwise fail
# without merging.
# Usage: sh merge.sh PR --reviewed [--rebase|--squash]
#        (run from the repo's main checkout)
# Required: --reviewed, the caller's assertion that the caller read the diff
# and addressed all feedback (exit 64 without the flag).
# Merge checks, in order (exit 10 with one line naming the failed check):
#   1. the PR is open and not a draft
#   2. no CI run for another commit is in progress or queued, ignoring runs
#      from pushes to the base branch (post-merge CI) and scheduled runs; when
#      the check fails, wait for the other CI runs to finish and rerun
#   3. the PR has at least one commit past origin's base branch, after fetching
#      every remote; the script addresses the PR head by the commit hash that
#      gh reports, so a branch pushed to another remote (split remotes) works.
#      A PR with more than one commit needs a merge method chosen by the
#      caller: without --rebase (keep every commit) or --squash (one commit),
#      the script exits 11 and lists the commits.
# Then run `jj ghprcqmfr PR`: the command waits for CI (fail-fast), merges, fetches
# and rebases, and refuses on red CI. Exit: 0 merged; 10 merge check failed;
# 11 several commits and no merge method; 64 usage; otherwise the status of `jj ghprcqmfr`.
set -u

fail() { printf 'jj-merge-pr: merge checks failed: %s\n' "$*" >&2; exit 10; }

usage() { echo "usage: merge.sh PR --reviewed [--rebase|--squash]" >&2; exit 64; }
pr=${1:-}
case $pr in ''|*[!0-9]*) usage ;; esac
shift
reviewed=; method=
for a in "$@"; do
    case $a in
        --reviewed) reviewed=1 ;;
        --rebase|--squash) [ -z "$method" ] || usage; method=${a#--} ;;
        *) usage ;;
    esac
done
[ -n "$reviewed" ] ||
    { echo "jj-merge-pr: pass --reviewed only after reading the diff and addressing all feedback" >&2; exit 64; }

info=$(gh pr view "$pr" --json state,isDraft,baseRefName,headRefName,headRefOid \
    -q '[.state, (.isDraft|tostring), .baseRefName, .headRefName, .headRefOid] | join(" ")') ||
    fail "cannot read PR $pr"
set -- $info
[ $# -eq 5 ] || fail "unexpected PR info: $info"
state=$1 draft=$2 base=$3 head=$4 sha=$5

# 1. open, not a draft
[ "$state" = OPEN ] || fail "PR $pr is $state, not OPEN"
[ "$draft" = false ] || fail "PR $pr is a draft"

# 2. one CI at a time: nothing running for any other commit, ignoring runs on
#    pushes to the base branch (post-merge CI) and scheduled runs; a fork PR
#    from a branch named like the base branch still counts
others=0
for st in in_progress queued; do
    n=$(gh run list --status "$st" --json headSha,headBranch,event \
        -q "[.[] | select(.headSha != \"$sha\" and .event != \"schedule\" and ((.event == \"push\" and .headBranch == \"$base\") | not))] | length") ||
        fail "cannot list $st runs"
    others=$((others + n))
done
[ "$others" -eq 0 ] || fail "$others CI run(s) for other commits are active"

# 3. at least one commit past the base branch (several need a method flag). Fetch every remote, since the PR
#    branch may live on a remote other than origin, and address the head by
#    the commit hash, not by branch name.
jj git fetch --all-remotes >/dev/null 2>&1 || fail "jj git fetch failed"
# stderr goes to a file so jj warnings never count as commits
errf=$(mktemp) || fail "cannot create a temp file"
commits=$(jj log -r "\"$base\"@origin..commit_id($sha)" --no-graph \
    -T 'change_id.short() ++ "\n"' 2>"$errf") || {
    msg=$(cat "$errf"); rm -f "$errf"
    fail "jj cannot resolve $base@origin..$sha: $msg"
}
rm -f "$errf"
count=$(printf '%s\n' "$commits" | grep -c .)
[ "$count" -ge 1 ] || fail "PR $pr has no commits past $base"
if [ "$count" -gt 1 ] && [ -z "$method" ]; then
    {
        echo "jj-merge-pr: PR $pr has $count commits past $base; nothing merged."
        jj log -r "\"$base\"@origin..commit_id($sha)" --no-graph \
            -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"' 2>/dev/null
        echo "Ask the user: keep every commit (--rebase) or one commit (--squash)?"
        echo "Rerun with the chosen flag."
    } >&2
    exit 11
fi

# Merge checks passed: merge. The exit status of the merge is the verdict.
if [ "$method" = squash ]; then jj ghprcqmfr "$pr" --squash; else jj ghprcqmfr "$pr"; fi
rc=$?
if [ "$rc" -ne 0 ]; then
    echo "jj-merge-pr: merge refused or failed (exit $rc); PR $pr not merged" >&2
    exit "$rc"
fi
echo "jj-merge-pr: PR $pr merged. Push $base to any other remote the repo's instructions name."
exit 0
