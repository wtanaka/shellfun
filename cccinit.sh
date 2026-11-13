#!/bin/sh
# cccinit (Claude Code cloud init): per-session init. Run inside a session (or
# from a SessionStart hook), when the environment variables exist. Each step
# runs only if its inputs are set.
# Installed to $HOME/.cccinit.sh by install.sh; claude-cloud-init.sh
# also copies the script to /usr/local/bin/cccinit.
set -eu

# --- step: clone remotes (CLONE_REMOTES="NAME URL [NAME URL]...") ---
# Result: a jj repo colocated with git in $HOME/<repo name>, with every remote.
if [ -n "${CLONE_REMOTES:-}" ]; then
  # shellcheck disable=SC2086
  set -- $CLONE_REMOTES
  [ $(( $# % 2 )) -eq 0 ] ||
    { echo "CLONE_REMOTES: odd word count" >&2; exit 1; }
  first_name=$1; first_url=$2
  name=${first_url##*/}; name=${name%.git}
  DEST="$HOME/$name"
  helper=/usr/local/bin/git-credential-envtoken
  hostof() { r=${1#*://}; r=${r#*@}; echo "${r%%/*}"; }
  export GIT_TERMINAL_PROMPT=0
  all="$*"
  while [ $# -gt 0 ]; do
    case "$2" in
      https://*)
        h=$(hostof "$2")
        git config --global "credential.https://$h.helper" "$helper"
        git config --global "credential.https://$h.useHttpPath" false ;;
    esac
    shift 2
  done
  # shellcheck disable=SC2086
  set -- $all
  # only https remotes use the token helper; other URLs use their own auth
  case "$first_url" in
    https://*)
      h=$(hostof "$first_url")
      if ! printf 'host=%s\n\n' "$h" | "$helper" get | grep -q .; then
        echo "no token for $h in the environment" >&2; exit 1
      fi ;;
  esac
  if [ -d "$DEST/.jj" ]; then
    :
  elif [ -d "$DEST/.git" ]; then
    # existing plain-git clone: convert to colocated jj
    (cd "$DEST" && jj git init --colocate)
  else
    jj git clone --colocate --remote "$first_name" "$first_url" "$DEST"
  fi
  # make every configured remote exist with the right URL
  remotes=""
  while [ $# -gt 0 ]; do
    if jj -R "$DEST" git remote list | grep -q "^$1 "; then
      jj -R "$DEST" git remote set-url "$1" "$2"
    else
      jj -R "$DEST" git remote add "$1" "$2"
    fi
    remotes="$remotes $1"
    shift 2
  done
  # fetch each remote on its own: one unreachable remote must not stop the rest
  for r in $remotes; do
    jj -R "$DEST" git fetch --remote "$r" ||
      echo "fetch from remote $r failed; continuing" >&2
  done
  jj -R "$DEST" git remote list
  jj -R "$DEST" log -r '@ | trunk()' --limit 3
else
  echo "CLONE_REMOTES unset; skipping clone" >&2
fi
