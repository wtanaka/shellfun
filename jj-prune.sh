#!/bin/sh
# jj-prune.sh: trim the jj operation log, then garbage-collect and rebuild
# the commit index. Installed next to config.toml; run via the `jj prune`
# alias.
#
# Retention rule: keep every operation from the last JJ_PRUNE_DAYS days, but
# never fewer than JJ_PRUNE_MIN and never more than JJ_PRUNE_MAX:
#     keep = clamp(ops newer than DAYS days, MIN, MAX)
# All ops older than a week -> MIN kept. A flood of new ops -> MAX kept.
#
# Usage: jj prune [-n]      (-n: only report what would be abandoned)
# Env:   JJ_PRUNE_DAYS (7)  JJ_PRUNE_MIN (64)  JJ_PRUNE_MAX (256)
#        JJ_PRUNE_NOW      epoch seconds to use as "now" (tests only)
#
# Steps: op abandon -> util gc --expire=now -> debug reindex. `debug` is an
# unstable jj namespace, so a failing reindex is reported but not fatal.

set -u

die() {   # die CODE MESSAGE...
    c=$1; shift
    printf 'jj-prune: %s\n' "$*" >&2
    exit "$c"
}

whole() {   # whole NAME VALUE: VALUE must be a non-negative integer
    case $2 in
        ''|*[!0-9]*) die 64 "$1 must be a whole number, got '$2'" ;;
    esac
}

dry=0
case ${1:-} in
    -n) dry=1 ;;
    '') ;;
    *) die 64 "usage: jj prune [-n]" ;;
esac

days=${JJ_PRUNE_DAYS:-7}
min=${JJ_PRUNE_MIN:-64}
max=${JJ_PRUNE_MAX:-256}
now=${JJ_PRUNE_NOW:-$(date +%s)}
whole JJ_PRUNE_DAYS "$days"
whole JJ_PRUNE_MIN "$min"
whole JJ_PRUNE_MAX "$max"
whole JJ_PRUNE_NOW "$now"
[ "$min" -le "$max" ] ||
    die 64 "JJ_PRUNE_MIN ($min) exceeds JJ_PRUNE_MAX ($max)"
[ "$min" -ge 1 ] || die 64 "JJ_PRUNE_MIN must be at least 1"

# Newest first: "<full op id> <end time, epoch seconds>". The root operation
# (all-zero id) is always present and cannot be abandoned, so it is dropped.
ops=$(jj op log --no-graph \
    -T 'id ++ " " ++ time.end().format("%s") ++ "\n"') ||
    die 1 "jj op log failed"
ops=$(printf '%s\n' "$ops" | awk 'NF && $1 !~ /^0+$/')
cutoff=$((now - days * 86400))
total=$(printf '%s\n' "$ops" | awk 'NF' | wc -l | tr -d ' ')
recent=$(printf '%s\n' "$ops" |
    awk -v c="$cutoff" 'NF && $2 >= c' | wc -l | tr -d ' ')

keep=$recent
[ "$keep" -ge "$min" ] || keep=$min
[ "$keep" -le "$max" ] || keep=$max

printf 'ops: %s total, %s in last %s days; keeping %s\n' \
    "$total" "$recent" "$days" "$keep"

# `jj op abandon ..X` removes X and all its ancestors, so X is the newest op
# that falls outside the keep window: the (keep+1)th line.
if [ "$total" -gt "$keep" ]; then
    victim=$(printf '%s\n' "$ops" |
        awk -v n=$((keep + 1)) 'NF && ++i == n { print $1 }')
    [ -n "$victim" ] || die 1 "could not find the cut-off operation"
    printf 'abandoning %s old ops\n' $((total - keep))
    [ "$dry" -eq 1 ] || jj op abandon "..$victim" || die 1 "op abandon failed"
else
    echo "nothing to abandon"
fi

[ "$dry" -eq 0 ] || exit 0
jj util gc --expire=now || die 1 "util gc failed"
jj debug reindex >/dev/null 2>&1 ||
    printf 'jj-prune: reindex skipped (jj debug reindex failed)\n' >&2
exit 0
