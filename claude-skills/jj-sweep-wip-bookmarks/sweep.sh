#!/bin/sh
# Delete stale `*-wip` bookmarks whose commit is already reachable from
# another visible head (trunk, another bookmark, a remote bookmark, or the
# default workspace's @). Touches only bookmarks whose name ends in "-wip".
# Usage: sh sweep.sh [-n]   (-n: list the bookmarks that would be deleted)
# Env:   JJ_SWEEP_TRUNK  trunk bookmark (default: main, else master)
set -u

dry=0
case ${1:-} in
    -n) dry=1 ;;
    '') ;;
    *) echo "usage: sweep.sh [-n]" >&2; exit 64 ;;
esac

trunk=${JJ_SWEEP_TRUNK:-}
if [ -z "$trunk" ]; then
    for t in main master; do
        if [ -n "$(jj bookmark list -T 'name ++ "\n"' "exact:$t" 2>/dev/null)" ]; then
            trunk=$t
            break
        fi
    done
fi
[ -n "$trunk" ] || { echo "sweep: no main or master bookmark; nothing swept" >&2; exit 0; }

# By NAME pattern only. `jj bookmark list -r <revset>` lists every bookmark on
# a matching commit, and that form once made the loop delete `main` itself.
for bm in $(jj bookmark list -T 'name ++ "\n"' 'glob:*-wip' | grep -- '-wip$'); do
    if jj log --no-graph -T commit_id --ignore-working-copy \
        -r "${bm} & ::(${trunk} | (bookmarks() ~ bookmarks(exact:\"${bm}\")) | remote_bookmarks() | default@)" \
        | grep -q .; then
        if [ "$dry" -eq 1 ]; then
            echo "would delete $bm"
        else
            jj bookmark delete "$bm"
        fi
    fi
done
exit 0
