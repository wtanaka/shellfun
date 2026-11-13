#!/bin/sh
# Environment setup script (cached). Runs before env vars exist, so it must not
# need a token. It installs tooling and a git credential helper that reads the
# token from the environment at git run time; tokens are never written to disk.
#
# Remotes come from the environment, read at session time (not at setup):
#   CLONE_REMOTES="NAME URL [NAME URL]..."
# One checkout with one git remote per NAME URL pair. The first pair is cloned;
# the others are added as remotes. Tokens: GH_TOKEN for github.com,
# GITLAB_TOKEN for gitlab.com, GIT_TOKEN for any other host.
#
# Paste these lines as the Claude Code cloud environment setup script
# (replace "master" with a commit hash to pin a version):
#
#   u=https://raw.githubusercontent.com/wtanaka/shellfun/master
#   f=$(mktemp) && curl -fsSL --retry 3 -o "$f" "$u/claude-cloud-init.sh" \
#     && sh "$f"
set -eu

GIT_USER=wtanaka
JJ_VERSION="${JJ_VERSION:-}"   # empty: latest release; set to pin, e.g. v0.47.1

# --- packages (cached with the environment) ---
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND
need=""
command -v git  >/dev/null 2>&1 || need="$need git"
command -v curl >/dev/null 2>&1 || need="$need curl"
command -v tar  >/dev/null 2>&1 || need="$need tar"
[ -e /etc/ssl/certs/ca-certificates.crt ] || need="$need ca-certificates"
# add other apt packages to $need here, e.g. need="$need jq build-essential"
if [ -n "$need" ]; then
  apt-get update -qq
  # shellcheck disable=SC2086
  apt-get install -y --no-install-recommends $need
fi

# --- jj (Jujutsu): static musl release binary, no token needed ---
if ! command -v jj >/dev/null 2>&1; then
  case "$(uname -m)" in
    x86_64)        JJ_ARCH=x86_64 ;;
    aarch64|arm64) JJ_ARCH=aarch64 ;;
    *) echo "unsupported arch for jj: $(uname -m)" >&2; exit 1 ;;
  esac
  if [ -z "$JJ_VERSION" ]; then
    # /releases/latest redirects to /releases/tag/<version>; no API token needed
    JJ_VERSION="$(curl -fsSL --retry 3 -o /dev/null -w '%{url_effective}' \
      https://github.com/jj-vcs/jj/releases/latest)"
    JJ_VERSION="${JJ_VERSION##*/}"
    case "$JJ_VERSION" in
      v[0-9]*) ;;
      *) echo "could not resolve latest jj release: $JJ_VERSION" >&2; exit 1 ;;
    esac
  fi
  JJ_TMP="$(mktemp -d)"
  curl -fsSL --retry 3 -o "$JJ_TMP/jj.tar.gz" \
    "https://github.com/jj-vcs/jj/releases/download/${JJ_VERSION}/jj-${JJ_VERSION}-${JJ_ARCH}-unknown-linux-musl.tar.gz"
  tar -xzf "$JJ_TMP/jj.tar.gz" -C "$JJ_TMP"
  install -m 755 "$(find "$JJ_TMP" -type f -name jj | head -n1)" /usr/local/bin/jj
  rm -rf "$JJ_TMP"
fi
jj --version

# --- credential helper: per-host token read from the environment on demand ---
cat > /usr/local/bin/git-credential-envtoken <<'HELPER'
#!/bin/sh
[ "$1" = get ] || exit 0
host=
while IFS='=' read -r k v; do [ "$k" = host ] && host=${v%%:*}; done
case "$host" in
  github.com) user=wtanaka; tok=${GH_TOKEN:-} ;;
  gitlab.com) user=oauth2;  tok=${GITLAB_TOKEN:-} ;;
  *)          user=git;     tok=${GIT_TOKEN:-} ;;
esac
case "$tok" in ""|proxy-injected) exit 0 ;; esac
echo "username=$user"
echo "password=$tok"
HELPER
chmod 755 /usr/local/bin/git-credential-envtoken

# system-wide so it survives any HOME. Scoped per host so a token never goes to
# an unlisted host; repo-clone adds any other host from CLONE_REMOTES.
for host in github.com gitlab.com; do
  git config --system "credential.https://$host.helper" \
    /usr/local/bin/git-credential-envtoken
  git config --system "credential.https://$host.useHttpPath" false
done

# --- session-time clone script (needs env vars, so it runs later, not here) ---
# Quoted heredoc: nothing is expanded now; $HOME and the variables resolve when
# the script runs.
cat > /usr/local/bin/repo-clone <<'CLONE'
#!/bin/sh
# Run inside a session (or from a SessionStart hook). Reads CLONE_REMOTES.
# Result: $DEST is a jj repo colocated with git, with every configured remote.
set -eu
[ -n "${CLONE_REMOTES:-}" ] || { echo "CLONE_REMOTES unset" >&2; exit 1; }
# shellcheck disable=SC2086
set -- $CLONE_REMOTES
[ $(( $# % 2 )) -eq 0 ] || { echo "CLONE_REMOTES: odd word count" >&2; exit 1; }
first_name=$1; first_url=$2
name=${first_url##*/}; name=${name%.git}
DEST="$HOME/$name"
helper=/usr/local/bin/git-credential-envtoken
hostof() { r=${1#*://}; r=${r#*@}; echo "${r%%/*}"; }
export GIT_TERMINAL_PROMPT=0
all="$*"
while [ $# -gt 0 ]; do
  h=$(hostof "$2")
  git config --global "credential.https://$h.helper" "$helper"
  git config --global "credential.https://$h.useHttpPath" false
  shift 2
done
# shellcheck disable=SC2086
set -- $all
h=$(hostof "$first_url")
if ! printf 'host=%s\n\n' "$h" | "$helper" get | grep -q .; then
  echo "no token for $h in the environment" >&2; exit 1
fi
if [ -d "$DEST/.jj" ]; then
  :
elif [ -d "$DEST/.git" ]; then
  # existing plain-git clone: convert to colocated jj
  (cd "$DEST" && jj git init --colocate)
else
  jj git clone --colocate --remote "$first_name" "$first_url" "$DEST"
fi
# make every configured remote exist with the right URL
while [ $# -gt 0 ]; do
  if jj -R "$DEST" git remote list | grep -q "^$1 "; then
    jj -R "$DEST" git remote set-url "$1" "$2"
  else
    jj -R "$DEST" git remote add "$1" "$2"
  fi
  shift 2
done
jj -R "$DEST" git fetch --all-remotes
jj -R "$DEST" git remote list
jj -R "$DEST" log -r '@ | trunk()' --limit 3
CLONE
chmod 755 /usr/local/bin/repo-clone

# --- new login/interactive shells start in the checkout, if it exists ---
# (a script can't change its caller's cwd, so this is done via shell startup)
cat > /etc/profile.d/repo-cd.sh <<'PROFILE'
# only when starting in $HOME, so an explicit cwd is never overridden
if [ "$PWD" = "$HOME" ] && [ -n "${CLONE_REMOTES:-}" ]; then
  # shellcheck disable=SC2086
  set -- $CLONE_REMOTES
  d=${2##*/}; d="$HOME/${d%.git}"
  [ -d "$d" ] && cd "$d"
fi
PROFILE
chmod 644 /etc/profile.d/repo-cd.sh
for rc in /etc/bash.bashrc; do
  [ -f "$rc" ] && ! grep -q repo-cd "$rc" &&
    echo '. /etc/profile.d/repo-cd.sh # repo-cd' >> "$rc"
done

# --- run the script published at bit.ly/shellfun ---
# Downloaded to a file first (not piped) so a failed/partial download never
# executes. Tokens are stripped from its environment; failure is non-fatal.
SHELLFUN="$(mktemp)"
if curl -fsSL --retry 3 -o "$SHELLFUN" \
    https://raw.githubusercontent.com/wtanaka/shellfun/master/boot.sh; then
  env -u GH_TOKEN -u GITLAB_TOKEN -u GIT_TOKEN sh "$SHELLFUN" ||
    echo "shellfun exited non-zero" >&2
else
  echo "could not download bit.ly/shellfun; skipping" >&2
fi
rm -f "$SHELLFUN"

# --- clone now if a token happens to be present (usually it isn't yet) ---
if [ -n "${CLONE_REMOTES:-}" ]; then
  # non-fatal: a clone failure must not break the cached environment setup
  repo-clone ||
    echo "repo-clone did not run at setup; rerun it in the session" >&2
fi

echo "setup done"
