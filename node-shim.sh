#!/bin/sh
# Wrapper for node, npm, npx and fnm, installed four times into $HOME/bin (one
# file; the command name comes from $0). These commands are programs, never
# shell functions, so no function shadows a real node on PATH, and a script,
# make, an editor or `ssh host node -v` finds them too. nodelazy.sh keeps only
# an nvm function, because `nvm use` must change the PATH of the shell.
#
# node, npm, npx:
# 1. Fast path: $NVM_DIR/.default-version (written by nodelazy.sh after the
#    default version passed its damage check) names a version directory that
#    still has the command: put its bin directory first on PATH and exec. The
#    fast path does not look for lost files; the first call of the loader does.
#    Npm and npx are scripts with "#!/usr/bin/env node"; the PATH change
#    makes them find the matching node.
# 2. nvm is installed but the version is missing or unrecorded: load
#    nodelazy.sh in bash and run _nvm_lazy_load, which repairs or installs the
#    default version. It asks on the terminal when there is one, and never
#    prompts without one.
# 3. nvm is not installed, or step 2 could not produce a node: run the next
#    command of that name on PATH, if any, such as a system node. Otherwise
#    print how to install nvm and exit 1.
#
# fnm: exec $FNM_DIR/bin/fnm when it exists; otherwise _fnm_lazy_load (asks on
# a terminal before it downloads fnm); otherwise the next fnm on PATH.
#
# Step 2 sets NODE_SHIM_LOADER. When the loader finds no node, its final
# "node ..." lookup lands on this file again; with the variable set, this file
# skips step 2 and goes to step 3, so the two can never recurse.

name=${0##*/}
self_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd)

if [ -z "${NVM_DIR:-}${FNM_DIR:-}" ] && [ -f "$HOME/.allenv.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.allenv.sh"
fi

case $name in
  fnm)
    if [ -n "${FNM_DIR:-}" ]; then
      [ -x "$FNM_DIR/bin/fnm" ] && exec "$FNM_DIR/bin/fnm" "$@"
      if [ -z "${NODE_SHIM_LOADER:-}" ] && [ -f "$HOME/.nodelazy.sh" ] &&
          command -v bash >/dev/null 2>&1; then
        NODE_SHIM_LOADER=1
        export NODE_SHIM_LOADER
        exec bash -c '. "$HOME/.nodelazy.sh"; _fnm_lazy_load "$@"' bash \
          "$name" "$@"
      fi
    fi
    ;;
  *)
    if [ -n "${NVM_DIR:-}" ]; then
      version=$(cat "$NVM_DIR/.default-version" 2>/dev/null)
      bin_dir=$NVM_DIR/versions/node/$version/bin
      if [ -n "$version" ] && [ -x "$bin_dir/$name" ]; then
        PATH=$bin_dir:$PATH
        export PATH
        exec "$bin_dir/$name" "$@"
      fi
      if [ -z "${NODE_SHIM_LOADER:-}" ] && [ -s "$NVM_DIR/nvm.sh" ] &&
          [ -f "$HOME/.nodelazy.sh" ] && command -v bash >/dev/null 2>&1; then
        NODE_SHIM_LOADER=1
        export NODE_SHIM_LOADER
        exec bash -c '. "$HOME/.nodelazy.sh"; _nvm_lazy_load "$@"' bash \
          "$name" "$@"
      fi
    fi
    ;;
esac

# no tool cache install: use another $name on PATH, skipping this directory
old_ifs=$IFS
IFS=:
for dir in $PATH; do
  [ -n "$dir" ] || continue
  [ "$dir" = "$self_dir" ] && continue
  if [ -x "$dir/$name" ] && [ ! -d "$dir/$name" ]; then
    IFS=$old_ifs
    exec "$dir/$name" "$@"
  fi
done
IFS=$old_ifs

case $name in
  fnm) echo "fnm: not found. Run fnm in a terminal once to install it." >&2 ;;
  *) echo "$name: not found. nvm is not installed; run $name in a terminal" \
       "once to install nvm." >&2 ;;
esac
exit 1
