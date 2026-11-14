#!/bin/sh
# Wrapper for node, npm and npx, installed three times into $HOME/bin (one
# file; the command name comes from $0). nodelazy.sh defines lazy shell
# functions with the same names, but functions exist only inside an
# interactive shell. A script, make, an editor or `ssh host node -v` never
# sees them, so this wrapper covers every program that looks node up on PATH.
# In an interactive shell the function still wins over this file.
#
# 1. Fast path: $NVM_DIR/.default-version (written by nodelazy.sh after the
#    default version passed its damage check) names a version directory that
#    still has the command: put its bin directory first on PATH and exec. The
#    fast path does not look for lost files; the interactive first call does.
#    Npm and npx are scripts with "#!/usr/bin/env node"; the PATH change
#    makes them find the matching node.
# 2. nvm is installed but the version is missing or unrecorded: load
#    nodelazy.sh in bash and run the command through its lazy function, which
#    repairs or installs the default version (no terminal, so no prompt).
# 3. nvm is not installed, or step 2 could not produce a node: run the next
#    command of that name on PATH, if any, such as a system node. Otherwise
#    print how to install nvm and exit 1.
#
# Step 2 sets NODE_SHIM_LOADER. When the loader finds no node, its final
# "node ..." lookup lands on this file again; with the variable set, this file
# skips step 2 and goes to step 3, so the two can never recurse.

name=${0##*/}
self_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd)

if [ -z "${NVM_DIR:-}" ] && [ -f "$HOME/.allenv.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.allenv.sh"
fi

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
    exec bash -c '. "$HOME/.nodelazy.sh"; "$@"' bash "$name" "$@"
  fi
fi

# no nvm: use another $name on PATH, skipping this directory
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

echo "$name: not found. nvm is not installed; run nvm in an interactive" \
  "shell once to install it." >&2
exit 1
