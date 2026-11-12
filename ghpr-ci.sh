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
#   GHPR_CI_POLL           between polls (default 10)
#   GHPR_CI_WATCH_INTERVAL `gh run watch` refresh (default 15; gh's own
#                          default of 3 burns ~2400 REST calls/hour per run)
#   GHPR_CI_RUN_TIMEOUT    wait for a first Actions run to appear when some
#                          workflow must run (default 300)
#   GHPR_CI_SOFT_TIMEOUT   same, when every workflow is path-filtered, so a
#                          commit may legitimately have no run (default 60)
#   GHPR_CI_REQ_TIMEOUT    wait for a required check to report (default 120)
#   GHPR_CI_CHECK_TIMEOUT  wait for non-Actions checks to finish (default 1800)
# With no Actions run, the status rollup alone decides; if that is empty too,
# nothing verified the commit (exit 3). Merging also needs mergeStateStatus
# CLEAN (or HAS_HOOKS).
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
poll=${GHPR_CI_POLL:-10}
wint=${GHPR_CI_WATCH_INTERVAL:-15}
timeout=${GHPR_CI_RUN_TIMEOUT:-300}
ctimeout=${GHPR_CI_CHECK_TIMEOUT:-1800}
soft=${GHPR_CI_SOFT_TIMEOUT:-60}
rtimeout=${GHPR_CI_REQ_TIMEOUT:-120}
case "$poll$wint$timeout$ctimeout$soft$rtimeout" in
    *[!0-9]*) fail 64 "GHPR_CI_* timeouts must be whole seconds" ;;
esac
[ "$poll" -ge 1 ] || fail 64 "GHPR_CI_POLL must be at least 1"
[ "$wint" -ge 1 ] || fail 64 "GHPR_CI_WATCH_INTERVAL must be at least 1"

if [ -z "$sel" ]; then   # jj has no current branch: use the nearest bookmark
    out=$(jj bookmark list --color never \
        -r 'latest(ancestors(@) & bookmarks())' \
        -T 'if(remote, "", name ++ "\n")') || die "cannot list bookmarks"
    sel=$(printf '%s\n' "$out" | sed -n '1p')
    [ -n "$sel" ] || fail 2 "no PR given and no bookmark above @"
    [ "$sel" != main ] || fail 2 "nearest bookmark is main; pass a PR"
fi

read_pr() {   # sets number sha state draft mergeable review url base mstate
    fields=number,headRefOid,state,isDraft,mergeable,reviewDecision
    fields=$fields,url,baseRefName,mergeStateStatus
    line=$(gh_ pr view "$sel" --json "$fields" \
        -q '[.number, .headRefOid, .state, .isDraft, .mergeable,
             (.reviewDecision // ""), .url, .baseRefName,
             .mergeStateStatus]
            | map(tostring) | join("|")') \
        || fail 2 "cannot find a PR for '$sel'"
    IFS='|' read -r number sha state draft mergeable review url base \
        mstate <<EOF
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

nwo=$repo   # owner/repo, for `gh api` (which has no -R)
[ -n "$nwo" ] || nwo=$(gh repo view --json nameWithOwner \
    -q .nameWithOwner 2>/dev/null) || nwo=""
# Reads one workflow file on stdin; exit 0 = some trigger is certain to run
# (an unfiltered push / pull_request / pull_request_target in the real `on:`
# block), 1 = none is. Comments are stripped first. Anything unexpected
# (no `on:`, flow maps, anchors, tabs, odd syntax) exits 0: we only get
# stricter. A YAML 1.1 parser reads the key `on` as true, so accept both.
WF_AWK='
function strip(l,   i, c, q, out) {   # drop a # comment outside quotes
    q = ""; out = ""
    for (i = 1; i <= length(l); i++) {
        c = substr(l, i, 1)
        if (q == "") {
            if (c == "\"" || c == "\047") q = c
            else if (c == "#" && (i == 1 || substr(l, i - 1, 1) ~ /[ \t]/))
                break
        } else if (c == q) q = ""
        out = out c
    }
    sub(/[ \t]+$/, "", out)
    return out
}
function trig(s) { return s == "push" || s == "pull_request" \
    || s == "pull_request_target" }
function unq(s) { gsub(/^[ \t"\047]+/, "", s); gsub(/[ \t"\047]+$/, "", s)
    return s }
{
    l = strip($0)
    if (l ~ /^[ \t]*$/ || l == "---") next
    if (l ~ /^ *\t/) bad = 1
    n++; line[n] = l; ind[n] = match(l, /[^ ]/) - 1
    txt[n] = substr(l, ind[n] + 1)   # without indentation
}
END {
    if (bad) exit 0
    for (i = 1; i <= n; i++)
        if (ind[i] == 0 && line[i] ~ /^("on"|\047on\047|on|true)[ \t]*:/) break
    if (i > n) exit 0
    rest = line[i]; sub(/^[^:]*:[ \t]*/, "", rest)
    if (rest != "") {
        if (rest ~ /^\[/) {   # on: [push, pull_request]
            if (rest !~ /\]$/) exit 0
            m = split(substr(rest, 2, length(rest) - 2), a, ",")
            for (k = 1; k <= m; k++) if (trig(unq(a[k]))) exit 0
            exit 1
        }
        if (rest ~ /^[{&*!|>]/) exit 0
        exit trig(unq(rest)) ? 0 : 1   # on: push
    }
    j = i + 1
    if (j > n || ind[j] == 0) exit 0
    ci = ind[j]
    if (txt[j] ~ /^-/) {   # block list
        for (k = j; k <= n && ind[k] > 0; k++)
            if (ind[k] == ci && txt[k] ~ /^-/) {
                s = txt[k]; sub(/^-[ \t]*/, "", s)
                if (trig(unq(s))) exit 0
            }
        exit 1
    }
    for (k = j; k <= n && ind[k] > 0; k++) {   # block map
        if (ind[k] != ci) continue
        key = line[k]; sub(/[ \t]*:.*/, "", key)
        if (!trig(unq(key))) continue
        val = line[k]; sub(/^[^:]*:[ \t]*/, "", val)
        if (val != "") {
            if (val ~ /^(~|null|\{\})$/) exit 0
            if (val ~ /^\{[ \t]*(paths|paths-ignore)[ \t]*:/) continue
            exit 0
        }
        b = k + 1
        if (b > n || ind[b] <= ci) exit 0   # null value: unfiltered
        bi = ind[b]; filt = 0
        for (q = b; q <= n && ind[q] > ci; q++)
            if (ind[q] == bi && txt[q] ~ /^(paths|paths-ignore)[ \t]*:/)
                filt = 1
        if (!filt) exit 0
    }
    exit 1
}'
wf_certain() {   # stdin: one workflow file; only a clean exit 1 = not certain
    if awk "$WF_AWK"; then return 0; else [ $? -ne 1 ] || return 1; fi
    return 0
}
runs_certain() {   # 0 if some workflow at $1 must run for this PR/push
    # Looks only at the trigger and path-filter keys of the real `on:` block,
    # never evaluates globs, so an error here can only make us stricter.
    # Unknown (API error, unparsable file) = certain.
    # GHPR_WORKFLOWS_DIR (tests only) reads local *.yml/*.yaml instead.
    if [ -n "${GHPR_WORKFLOWS_DIR:-}" ]; then
        for f in "$GHPR_WORKFLOWS_DIR"/*.yml "$GHPR_WORKFLOWS_DIR"/*.yaml; do
            [ -f "$f" ] || continue
            wf_certain < "$f" || continue
            return 0
        done
        return 1
    fi
    [ -n "$nwo" ] || return 0
    names=$(gh api "repos/$nwo/contents/.github/workflows?ref=$1" \
        -q '.[] | select(.type == "file") | .name' 2>/dev/null) || return 0
    for f in $names; do
        body=$(gh api -H 'Accept: application/vnd.github.raw+json' \
            "repos/$nwo/contents/.github/workflows/$f?ref=$1" \
            2>/dev/null) || return 0
        printf '%s\n' "$body" | wf_certain && return 0
    done
    return 1
}
required() {   # contexts that branch rules / protection require on $base
    [ -n "$nwo" ] || return 0
    r1=$(gh api "repos/$nwo/rules/branches/$base" -q '.[]
        | select(.type == "required_status_checks")
        | .parameters.required_status_checks[].context' 2>/dev/null) || r1=""
    r2=$(gh api "repos/$nwo/branches/$base/protection/required_status_checks" \
        -q '(.contexts[]?), (.checks[]?.context)' 2>/dev/null) || r2=""
    printf '%s\n%s\n' "$r1" "$r2" | sort -u | grep . || true
}

read_pr
[ "$state" = OPEN ] || die "PR $number is $state, not OPEN"
start_sha=$sha

say "waiting for runs of $(printf '%.7s' "$sha") (PR $number)"
if runs_certain "$sha"; then limit=$timeout; strict=1
else limit=$soft; strict=""; fi
waited=0; noruns=""
while :; do   # 1a. an Actions run must appear, unless none can be expected
    runs=$(list_runs "$sha") || die "gh run list failed"
    if [ -n "$runs" ]; then break; fi
    if [ "$waited" -ge "$limit" ]; then
        [ -z "$strict" ] || fail 3 "no workflow run for $sha after ${limit}s"
        say "no Actions run after ${limit}s (all workflows path-filtered?);" \
            "relying on the status rollup"
        noruns=1; break
    fi
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
            if gh_ run watch "$id" --exit-status -i "$wint" >/dev/null
            then rc=0; else rc=$?; fi
        else
            if gh_ run watch "$id" --exit-status -i "$wint"
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
req=$(required)
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
    missing=""   # required checks that have not reported at all
    while IFS= read -r c; do
        [ -n "$c" ] || continue
        printf '%s\n' "$items" \
            | awk -F'|' -v c="$c" '$3 == c { f = 1 } END { exit !f }' \
            || missing="$missing
  $c"
    done <<EOF
$req
EOF
    if [ -n "$missing" ] && [ "$cwaited" -ge "$rtimeout" ]; then
        die "required checks never reported (path filter?):$missing"
    fi
    if [ -n "$pending" ] || [ -n "$missing" ]; then
        clean=0
        [ "$cwaited" -lt "$ctimeout" ] \
            || die "checks still pending after ${ctimeout}s:$pending$missing"
        sleep "$poll"; cwaited=$((cwaited + poll))
        continue
    fi
    clean=$((clean + 1))
    if [ "$clean" -lt 2 ]; then sleep "$poll"; fi   # catch late checks
done

if [ -n "$noruns" ] && [ -z "$items" ]; then   # nothing verified the commit
    fail 3 "no Actions run and no status checks for $sha"
fi

say "re-checking PR $number"   # 3. re-read the PR after the wait
tries=0
while :; do
    read_pr
    if [ "$mergeable" != UNKNOWN ] && [ "$mstate" != UNKNOWN ]; then break; fi
    if [ "$tries" -ge 5 ]; then break; fi
    tries=$((tries + 1)); sleep "$poll"
done
[ "$state" = OPEN ] || die "PR $number is now $state"
[ "$sha" = "$start_sha" ] \
    || fail 4 "PR head changed during the wait ($start_sha -> $sha); rerun"
if [ "$mode" = wait ]; then say "all CI green for $sha"; exit 0; fi
[ "$draft" = false ] || die "PR $number is a draft"
[ "$mergeable" = MERGEABLE ] || die "PR $number is not mergeable ($mergeable)"
[ "$review" != CHANGES_REQUESTED ] || die "PR $number has requested changes"
case "$mstate" in   # BLOCKED = required checks pending, UNSTABLE = a check
    CLEAN|HAS_HOOKS) ;;   # is not passing, BEHIND = base moved
    *) die "PR $number mergeStateStatus is $mstate, not CLEAN" ;;
esac

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
