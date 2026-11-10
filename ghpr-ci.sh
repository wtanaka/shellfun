#!/bin/sh
# ghpr-ci.sh -- wait for ALL CI on a PR's head commit; `merge` then merges
# (rebase, delete branch), fetches and rebases @ onto main.
#
# Why not `gh pr checks --watch`: it exits as soon as every check registered
# so far has finished, but later jobs register only after earlier ones end, so
# it can return (and a merge can happen) while tests are still to run.
# So: (1) watch every GitHub Actions run of the head commit, then (2) wait for
# every item in the PR's status rollup (this also covers checks that are not
# Actions runs, e.g. an external build service) to be complete and green.
#
# Usage: ghpr-ci.sh wait|merge [-q] [-R owner/repo] [PR]
#   PR  number, #number, URL or branch; default: nearest bookmark above @
#   -q  hide `gh run watch` output (phase lines and errors still print)
# Env (whole seconds):
#   GHPR_CI_POLL           between polls (default 5)
#   GHPR_CI_RUN_TIMEOUT    wait for a first Actions run to appear (default 300)
#   GHPR_CI_CHECK_TIMEOUT  wait for non-Actions checks to finish (default 1800)
# Exit status: 0 green (and merged, for `merge`)
#              1 a run/check failed or was cancelled, still pending at the
#                timeout, or the PR is not open/mergeable/ready
#              2 PR not found (or no PR given and no bookmark above @)
#              3 no workflow run ever appeared for the head commit
#              4 PR head moved (during the wait, or the merge was refused
#                because the head no longer matched)
#             64 usage error
set -eu

repo=""; quiet=""; sel=""
die() { echo "ghpr-ci: $*" >&2; exit 1; }
fail() { code=$1; shift; echo "ghpr-ci: $*" >&2; exit "$code"; }
say() { echo "ghpr-ci: $*" >&2; }
gh_() { if [ -n "$repo" ]; then gh "$@" -R "$repo"; else gh "$@"; fi; }
good() { case "$1" in success|skipped|neutral) return 0 ;; esac; return 1; }

[ $# -ge 1 ] || fail 64 "usage: ghpr-ci.sh wait|merge [-q] [-R owner/repo] [PR]"
mode=$1; shift
case "$mode" in wait|merge) ;; *) fail 64 "unknown mode '$mode'" ;; esac
while [ $# -gt 0 ]; do
    case "$1" in
        -q) quiet=1 ;;
        -R|--repo) [ $# -ge 2 ] || fail 64 "$1 needs a value"; repo=$2; shift ;;
        --repo=*) repo=${1#--repo=} ;;
        -*) fail 64 "unknown option '$1'" ;;
        *) [ -z "$sel" ] || fail 64 "more than one PR given"; sel=${1#\#} ;;
    esac
    shift
done
poll=${GHPR_CI_POLL:-5}
timeout=${GHPR_CI_RUN_TIMEOUT:-300}
ctimeout=${GHPR_CI_CHECK_TIMEOUT:-1800}
case "$poll$timeout$ctimeout" in
    *[!0-9]*) fail 64 "GHPR_CI_* timeouts must be whole seconds" ;;
esac
[ "$poll" -ge 1 ] || fail 64 "GHPR_CI_POLL must be at least 1"

if [ -z "$sel" ]; then   # jj has no current branch: use the nearest bookmark
    out=$(jj bookmark list --color never \
        -r 'latest(ancestors(@) & bookmarks())' \
        -T 'if(remote, "", name ++ "\n")') || die "cannot list bookmarks"
    sel=$(printf '%s\n' "$out" | sed -n '1p')
    [ -n "$sel" ] || fail 2 "no PR given and no bookmark above @"
    [ "$sel" != main ] || fail 2 "nearest bookmark is main; pass a PR"
fi

read_pr() {   # sets number sha state draft mergeable review url
    line=$(gh_ pr view "$sel" \
        --json number,headRefOid,state,isDraft,mergeable,reviewDecision,url \
        -q '[.number, .headRefOid, .state, .isDraft, .mergeable,
             (.reviewDecision // ""), .url]
            | map(tostring) | join("|")') \
        || fail 2 "cannot find a PR for '$sel'"
    IFS='|' read -r number sha state draft mergeable review url <<EOF
$line
EOF
}
list_runs() {   # id|status|conclusion|workflow of each Actions run of $1
    gh_ run list --commit "$1" --limit 100 \
        --json databaseId,status,conclusion,workflowName \
        -q '.[] | [.databaseId, .status, .conclusion, .workflowName]
            | map(tostring) | join("|")'
}
rollup() {   # state|url|name per status-rollup item (CheckRun/StatusContext)
    gh_ pr view "$sel" --json statusCheckRollup -q '
        (.statusCheckRollup // [])[]
        | if .__typename == "CheckRun" then
            [(if .status == "COMPLETED"
              then ((.conclusion // "") | ascii_downcase)
              else "pending" end),
             (.detailsUrl // ""), .name]
          else
            [(if .state == "SUCCESS" then "success"
              elif (.state == "PENDING" or .state == "EXPECTED") then "pending"
              else "failure" end),
             (.targetUrl // ""), .context]
          end
        | join("|")'
}

read_pr
[ "$state" = OPEN ] || die "PR $number is $state, not OPEN"
start_sha=$sha

say "waiting for runs of $(printf '%.7s' "$sha") (PR $number)"
waited=0
while :; do   # 1a. at least one Actions run must exist for this commit
    runs=$(list_runs "$sha") || die "gh run list failed"
    if [ -n "$runs" ]; then break; fi
    [ "$waited" -lt "$timeout" ] \
        || fail 3 "no workflow run for $sha after ${timeout}s"
    sleep "$poll"; waited=$((waited + poll))
done

clean=0
while [ "$clean" -lt 2 ]; do   # 1b. watch unfinished runs until stably done
    runs=$(list_runs "$sha") || die "gh run list failed"
    incomplete=""; bad=""
    while IFS='|' read -r id st cc wf; do
        [ -n "$id" ] || continue
        if [ "$st" != completed ]; then incomplete="$incomplete $id"
        elif ! good "$cc"; then bad="$bad
  $wf (run $id): $cc"; fi
    done <<EOF
$runs
EOF
    [ -z "$bad" ] || die "failed runs for $sha:$bad"
    if [ -z "$incomplete" ]; then
        clean=$((clean + 1))
        if [ "$clean" -lt 2 ]; then sleep "$poll"; fi   # catch late runs
        continue
    fi
    clean=0
    for id in $incomplete; do
        say "watching run $id"
        if [ -n "$quiet" ]; then
            if gh_ run watch "$id" --exit-status >/dev/null
            then rc=0; else rc=$?; fi
        else
            if gh_ run watch "$id" --exit-status
            then rc=0; else rc=$?; fi
        fi
        # the verdict is the run's recorded state, never watch's exit code
        info=$(gh_ run view "$id" --json status,conclusion,workflowName,url \
            -q '[.status, .conclusion, .workflowName, .url] | join("|")') \
            || die "cannot read run $id"
        IFS='|' read -r st cc wf rurl <<EOF
$info
EOF
        [ "$st" = completed ] \
            || die "run $id ($wf) not completed after watch (exit $rc)"
        good "$cc" || die "run '$wf' ended $cc: $rurl"
    done
done

say "waiting for the status rollup (all checks, including non-Actions ones)"
cwaited=0; clean=0
while [ "$clean" -lt 2 ]; do   # 2. every rollup item complete and green
    items=$(rollup) || die "cannot read the status rollup"
    pending=""; bad=""
    while IFS='|' read -r st rurl name; do
        [ -n "$st" ] || [ -n "$name" ] || continue
        case "$st" in
            pending) pending="$pending
  $name" ;;
            success|skipped|neutral) ;;
            *) bad="$bad
  $name: ${st:-no conclusion} $rurl" ;;
        esac
    done <<EOF
$items
EOF
    [ -z "$bad" ] || die "failed checks:$bad"
    if [ -n "$pending" ]; then
        clean=0
        [ "$cwaited" -lt "$ctimeout" ] \
            || die "checks still pending after ${ctimeout}s:$pending"
        sleep "$poll"; cwaited=$((cwaited + poll))
        continue
    fi
    clean=$((clean + 1))
    if [ "$clean" -lt 2 ]; then sleep "$poll"; fi   # catch late checks
done

say "re-checking PR $number"   # 3. re-read the PR after the wait
tries=0
while :; do
    read_pr
    if [ "$mergeable" != UNKNOWN ] || [ "$tries" -ge 5 ]; then break; fi
    tries=$((tries + 1)); sleep "$poll"
done
[ "$state" = OPEN ] || die "PR $number is now $state"
[ "$sha" = "$start_sha" ] \
    || fail 4 "PR head changed during the wait ($start_sha -> $sha); rerun"
if [ "$mode" = wait ]; then say "all CI green for $sha"; exit 0; fi
[ "$draft" = false ] || die "PR $number is a draft"
[ "$mergeable" = MERGEABLE ] || die "PR $number is not mergeable ($mergeable)"
[ "$review" != CHANGES_REQUESTED ] || die "PR $number has requested changes"

say "merging PR $number ($url)"
if ! gh_ pr merge "$number" --rebase --delete-branch \
        --match-head-commit "$sha"; then
    # --match-head-commit refuses if the head moved: report that distinctly
    now=$(gh_ pr view "$sel" --json headRefOid -q .headRefOid) || now=""
    if [ -n "$now" ] && [ "$now" != "$sha" ]; then
        fail 4 "merge refused: PR head moved ($sha -> $now); rerun"
    fi
    die "merge failed"
fi
say "fetching all remotes"
jj gfa || die "fetch failed"
say "rebasing working copy onto main"
jj rrm || die "rebase failed"
