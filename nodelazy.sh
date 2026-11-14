# Lazy nvm and fnm for bash and zsh. Source this file from the shell startup
# script; it only defines functions, so shell startup stays fast. The first
# call of nvm, node, npm or npx (nvm) or of fnm (fnm) does the real work:
#   1. tool missing: explain, ask, and install into its directory only on "y".
#   2. no default Node version: ask, then install the latest LTS release.
#   3. default version damaged or reclaimed by the OS: reinstall it.
#   4. load the tool, select the default version, run the original command.
# After step 4 the stubs are gone and the commands run natively.
#
# The OS reclaims files in the tool cache by access time, one file at a time,
# so a Node version in daily use can still lose rarely read files. A marker
# written at install time cannot detect that. Instead each version directory
# gets a .manifest (list of its files) right after an install, and step 3
# compares the list to the directory: a missing file, or a failing
# `node --version`, deletes the version and reinstalls it. Files that appear
# later are ignored; only missing files count.
#
# Sharing: nvm ($NVM_DIR/versions/node/vX) and fnm ($FNM_DIR/node-versions/vX/
# installation) keep the same extracted tarball in different places. When both
# NVM_DIR and FNM_DIR are set, a complete version in one tool is hard-linked
# into the other (pax -rwl: links where the filesystem allows, copies
# otherwise), so the files exist once. A reinstall for one tool first tries to
# link a complete copy from the other tool, then downloads. A downloaded
# version also has files hard-linked to byte-identical files of older versions
# of the same tool (about 26 MB per extra Node 22 version). Files are then made
# read-only (see _nl_protect), because linked files are shared. The same steps
# run after `nvm install` and `fnm install` typed by hand (the loaded tool is
# wrapped), and a lock directory keeps shells that start together from
# changing the same version at once.
#
# The stubs are functions, not aliases, because they need logic. The shell
# startup file edits that the installers would make are skipped. Node is not on
# PATH before the first call, so a program started outside the shell (an
# editor, for example) does not see it.

# Alias expansion is off while this file is read (restored at the end): an
# alias such as mv="mv -i" or rm="rm -i" would otherwise be expanded inside the
# function bodies below, and mv -i prompts. zsh options are set with eval so
# that bash can parse this file.
_nl_aliases_were_on=
if [ -n "${ZSH_VERSION:-}" ]; then
  eval '[[ -o aliases ]] && _nl_aliases_were_on=1; setopt NO_ALIASES'
else
  shopt -q expand_aliases && _nl_aliases_were_on=1
  shopt -u expand_aliases
fi

_nl_ask() {   # _nl_ask PROMPT...: true on y/yes
  printf '%s [y/N] ' "$*" >&2
  read -r _nl_ans
  case $_nl_ans in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

# ---------------------------------------------------------------- directories

_nl_root() {   # directory with one subdirectory per version; empty if unset
  case $1 in
    nvm) [ -z "${NVM_DIR:-}" ] || echo "$NVM_DIR/versions/node" ;;
    fnm) [ -z "${FNM_DIR:-}" ] || echo "$FNM_DIR/node-versions" ;;
  esac
}
_nl_sub() { case $1 in nvm) echo ;; fnm) echo /installation ;; esac; }

# Newest installed directory in ROOT whose name starts with the version
# prefix: "v22" matches v22.3.0 but not v220.0.0.
_nl_find() {   # _nl_find ROOT SPEC
  [ -d "$1" ] || return 0
  ls -1 "$1" 2>/dev/null | grep -E "^$2(\\.|\$)" |
    LC_ALL=C sort -t. -k1.2,1n -k2,2n -k3,3n | tail -n 1
}

_nl_list() {   # _nl_list DIR: sorted relative paths of files and symlinks
  (cd "$1" && find . \( -type f -o -type l \) ! -name ".manifest*" |
    LC_ALL=C sort)
}

_nl_runs() { [ -x "$1/bin/node" ] && "$1/bin/node" --version >/dev/null 2>&1; }

_nl_record() {
  _nl_list "$1" >| "$1/.manifest.tmp.$$" &&
    mv "$1/.manifest.tmp.$$" "$1/.manifest"
}

# A version without a manifest (installed by hand) is trusted when node runs,
# and gets its manifest now.
_nl_complete() {   # _nl_complete DIR
  _nl_runs "$1" || return 1
  [ -f "$1/.manifest" ] || _nl_record "$1"
  local cur missing
  cur=$(mktemp) || return 1
  _nl_list "$1" >| "$cur"
  # lines present in the manifest but not on disk
  missing=$(LC_ALL=C comm -23 "$1/.manifest" "$cur" | head -n 1)
  rm -f "$cur"
  [ -z "$missing" ]
}

# ------------------------------------------------------------ link and dedupe

# Hard-link the tree SRC into ROOT/VERSION/SUB. The copy is built under a
# hidden name in ROOT and renamed into place, so another shell never sees a
# half-copied version directory.
_nl_link_copy() {   # _nl_link_copy SRC ROOT VERSION SUB
  local tmp="$2/.nl-tmp.$$.$3" how
  # pax (POSIX; macOS has it, Ubuntu needs `apt install pax`), then GNU cp -al
  # (every Linux), then a plain copy that uses extra disk
  for how in pax cpal cp; do
    rm -rf "$tmp"
    mkdir -p "$tmp$4" || return 1
    case $how in
      pax)
        command -v pax >/dev/null 2>&1 &&
          (cd "$1" && pax -rwl . "$tmp$4") 2>/dev/null ;;
      cpal) cp -al "$1/." "$tmp$4" 2>/dev/null ;;
      cp)   cp -R "$1/." "$tmp$4" ;;
    esac && { mv "$tmp" "$2/$3"; return; }
  done
  rm -rf "$tmp"
  return 1
}

_nl_hash_tree() {   # "hash  ./path" for each regular file
  (cd "$1" && find . -type f ! -name ".manifest*" -exec sh -c \
    'if command -v sha256sum >/dev/null 2>&1; then sha256sum "$@";
     else shasum -a 256 "$@"; fi' _ {} +)
}

# Replace each file of NEW that has the same path and the same SHA-256 in OLD
# by a hard link to OLD's file (the link keeps OLD's mode). Batched: one
# `xargs rm` removes the duplicates from NEW and one `pax -rwl` links them from
# OLD, so the work does not fork once per file. Without pax, falls back to one
# `ln -f` per file.
_nl_dedupe() {   # _nl_dedupe NEW OLD
  local oldh newh list f
  oldh=$(mktemp) || return 1
  newh=$(mktemp) || return 1
  list=$(mktemp) || return 1
  _nl_hash_tree "$2" >| "$oldh"
  _nl_hash_tree "$1" >| "$newh"
  awk 'NR==FNR { h=$1; $1=""; sub(/^ +/, ""); old[$0]=h; next }
       { h=$1; $1=""; sub(/^ +/, "")
         if (($0 in old) && old[$0]==h) print $0 }' \
    "$oldh" "$newh" >| "$list"
  if [ -s "$list" ]; then
    if command -v pax >/dev/null 2>&1; then
      (cd "$1" && tr '\n' '\0' < "$list" | xargs -0 rm -f) &&
        (cd "$2" && pax -rwl "$1" < "$list") 2>/dev/null
    else
      false
    fi ||
      while IFS= read -r f; do
        [ "$1/$f" -ef "$2/$f" ] || ln -f "$2/$f" "$1/$f"
      done < "$list"
  fi
  rm -f "$oldh" "$newh" "$list"
}

# Make every file of DIR read-only. Version directories share files through
# hard links, so an in-place write (open for writing, truncate) would change
# every version that links the file; the mode bits live in the shared inode,
# so one chmod protects all of them. Replacing a file by rename, which npm
# does, still works because that needs write permission on the directory, not
# on the file. Directories stay writable. Root ignores the read-only bit.
_nl_protect() {   # _nl_protect DIR
  find "$1" -type f ! -name ".manifest*" -exec chmod a-w {} +
}

# ----------------------------------------------------------------- the lock

# Shells that start together must not install, remove or link the same version
# at once. The lock is a directory ($NVM_DIR.lock or $FNM_DIR.lock, shared by
# both tools) holding a token "pid-random" of the owning shell. The lock is
# broken when the owner's pid is dead, or when the lock is older than 30
# minutes (a killed owner that never wrote a token, or a reused pid).
# The depth counter lets a locked function call another locked function.
# An interrupted function (Ctrl-C) leaves the counter above 0, so each prompt
# resets it and releases the lock (_nl_prompt_cleanup: at a prompt no function
# is running, so a held lock is stale). Background jobs and subshells share the
# shell's pid on bash 3.2, so the lock never treats "same pid" as "same owner".
_nl_depth=0
_nl_token=
_nl_lockdir() { echo "${NVM_DIR:-${FNM_DIR:-}}.lock"; }

_nl_lock() {
  local d tok pid why n=0
  if [ "$_nl_depth" -gt 0 ]; then _nl_depth=$((_nl_depth + 1)); return 0; fi
  d=$(_nl_lockdir)
  while ! mkdir "$d" 2>/dev/null; do
    tok=$(cat "$d/token" 2>/dev/null); pid=${tok%%-*}
    why=
    if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
      why="owner pid $pid is not running"
    elif [ -n "$(find "$d" -maxdepth 0 -mmin +30 2>/dev/null)" ]; then
      why="lock is older than 30 minutes"
    fi
    if [ -n "$why" ]; then
      echo "node lock: taking over $d ($why)" >&2
      # re-read right before removing: the lock may have changed hands
      [ "$(cat "$d/token" 2>/dev/null)" = "$tok" ] && rm -rf "$d"
      continue
    fi
    # first message at once, then one every 10 s
    if [ $((n % 10)) -eq 0 ]; then
      echo "node lock: waiting ${n} s for pid ${pid:-unknown}" \
        "(lock $d, token ${tok:-none})" >&2
    fi
    if [ "$n" -eq 60 ]; then
      echo "node lock: no other shell is installing? remove: rm -rf $d" >&2
    fi
    n=$((n + 1))
    if [ "$n" -gt 600 ]; then
      echo "node lock: gave up after 600 s; if pid ${pid:-unknown} is gone," \
        "run: rm -rf $d" >&2
      return 1
    fi
    sleep 1
  done
  _nl_token="$$-$RANDOM$RANDOM"
  echo "$_nl_token" >| "$d/token"
  _nl_depth=1
}

_nl_unlock() {
  local d
  _nl_depth=$((_nl_depth - 1))
  [ "$_nl_depth" -le 0 ] || return 0
  _nl_depth=0
  d=$(_nl_lockdir)
  [ "$(cat "$d/token" 2>/dev/null)" = "$_nl_token" ] && rm -rf "$d"
}

# Runs before every prompt: no function is running, so a held lock is stale.
_nl_prompt_cleanup() {
  [ "$_nl_depth" -gt 0 ] || return 0
  _nl_depth=1
  _nl_unlock
}
if [ -n "${ZSH_VERSION:-}" ]; then
  eval 'precmd_functions+=(_nl_prompt_cleanup)'
else
  case ";${PROMPT_COMMAND:-};" in
    *";_nl_prompt_cleanup;"*) ;;
    *) PROMPT_COMMAND="_nl_prompt_cleanup${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
fi

# A version directory with no manifest that changed in the last minute may be
# in the middle of an extraction by another shell's `nvm install` or
# `fnm install`, which this lock does not cover. ctime, not mtime: tar sets
# the mtime of extracted files to the archive's dates.
_nl_busy() {   # _nl_busy VERSION_TREE_DIR
  [ ! -f "$1/.manifest" ] &&
    [ -n "$(find "$1" -cmin -1 2>/dev/null | head -n 1)" ]
}

# ---------------------------------------------------------------- the guard

# Finish a version directory that has just been installed: link files that
# are identical in the tool's other versions, make the files read-only, and
# record the manifest.
_nl_finish() {   # _nl_finish TOOL VERSION_DIR_NAME
  local root sub ov
  root=$(_nl_root "$1"); sub=$(_nl_sub "$1")
  ls -1 "$root" 2>/dev/null | while IFS= read -r ov; do
    [ "$ov" = "$2" ] || ! _nl_runs "$root/$ov$sub" ||
      _nl_dedupe "$root/$2$sub" "$root/$ov$sub"
  done
  _nl_protect "$root/$2$sub"
  _nl_record "$root/$2$sub"
}

# Give the other tool a hard-linked copy of a complete version.
_nl_share() {   # _nl_share TOOL VERSION_DIR_NAME
  local other root sub oroot osub
  case $1 in nvm) other=fnm ;; *) other=nvm ;; esac
  root=$(_nl_root "$1"); sub=$(_nl_sub "$1")
  oroot=$(_nl_root "$other"); osub=$(_nl_sub "$other")
  [ -n "$oroot" ] || return 0
  if [ ! -d "$oroot/$2$osub" ] || ! _nl_complete "$oroot/$2$osub"; then
    rm -rf "${oroot:?}/$2"
    echo "$1: linking Node $2 into $other" >&2
    _nl_link_copy "$root/$2$sub" "$oroot" "$2" "$osub" ||
      echo "$1: link into $other failed" >&2
  elif [ ! "$root/$2$sub/bin/node" -ef "$oroot/$2$osub/bin/node" ]; then
    # both copies are complete but separate (one tool reinstalled): relink
    echo "$1: linking Node $2 into $other copy" >&2
    _nl_dedupe "$root/$2$sub" "$oroot/$2$osub" ||
      echo "$1: link into $other failed" >&2
  fi
}

# Finish and share every version directory of TOOL that has no manifest yet:
# a version installed by hand with `nvm install` or `fnm install`. A directory
# that changed within the last minute may still be extracting in another shell,
# so it is skipped unless FORCE is 1 (the caller has just run the install).
_nl_adopt() {   # _nl_adopt TOOL [FORCE]
  # zsh NO_CLOBBER would make nvm's own > redirects fail inside these calls
  [ -z "${ZSH_VERSION:-}" ] || eval 'setopt local_options clobber'
  local root sub v
  root=$(_nl_root "$1"); sub=$(_nl_sub "$1")
  [ -d "$root" ] || return 0
  _nl_lock || return 1
  ls -1 "$root" 2>/dev/null | while IFS= read -r v; do
    [ -f "$root/$v$sub/.manifest" ] && continue
    _nl_runs "$root/$v$sub" || continue
    if [ "${2:-0}" != 1 ] && _nl_busy "$root/$v$sub"; then
      continue
    fi
    _nl_finish "$1" "$v"
    _nl_share "$1" "$v"
  done
  _nl_unlock
}

# Make sure a complete Node version matching SPEC exists for TOOL (and for the
# other tool, when its directory variable is set). The tool must be loaded
# (nvm function defined, or fnm on PATH). Prints the tool's installation dir.
_nl_ensure() {   # _nl_ensure nvm|fnm SPEC
  # zsh NO_CLOBBER would make nvm's own > redirects fail inside these calls
  [ -z "${ZSH_VERSION:-}" ] || eval 'setopt local_options clobber'
  local tool=$1 spec=$2 other root sub oroot osub v ov rc=0 n
  case $spec in v*) ;; *) spec=v$spec ;; esac
  case $tool in nvm) other=fnm ;; *) other=nvm ;; esac
  root=$(_nl_root "$tool"); sub=$(_nl_sub "$tool")
  oroot=$(_nl_root "$other"); osub=$(_nl_sub "$other")
  [ -n "$root" ] || return 1
  _nl_lock || return 1

  v=$(_nl_find "$root" "$spec")
  # another shell may be extracting this version: wait instead of removing it
  n=0
  while [ -n "$v" ] && _nl_busy "$root/$v$sub" && [ "$n" -lt 150 ]; do
    [ "$n" -eq 0 ] &&
      echo "$tool: Node $v is being installed by another shell; waiting" >&2
    n=$((n + 1)); sleep 2
  done
  if [ -n "$v" ] && ! _nl_complete "$root/$v$sub"; then
    echo "$tool: Node $v is incomplete; removing" >&2
    rm -rf "${root:?}/$v"
    v=
  fi

  if [ -z "$v" ] && [ -n "$oroot" ]; then
    ov=$(_nl_find "$oroot" "$spec")
    if [ -n "$ov" ] && _nl_complete "$oroot/$ov$osub"; then
      echo "$tool: linking Node $ov from $other" >&2
      _nl_link_copy "$oroot/$ov$osub" "$root" "$ov" "$sub" || rc=1
      v=$ov
    fi
  fi

  if [ "$rc" -eq 0 ] && [ -z "$v" ]; then
    case $tool in
      nvm) nvm install "$spec" >&2 || rc=1 ;;
      fnm) fnm install "${spec#v}" >&2 || rc=1 ;;
    esac
    if [ "$rc" -eq 0 ]; then
      v=$(_nl_find "$root" "$spec")
      # the tool's wrapper may have finished the version already
      if [ -n "$v" ] && _nl_runs "$root/$v$sub"; then
        [ -f "$root/$v$sub/.manifest" ] || _nl_finish "$tool" "$v"
      else
        rc=1
      fi
    fi
  fi

  if [ "$rc" -eq 0 ]; then
    _nl_share "$tool" "$v"
    echo "$root/$v$sub"
  fi
  _nl_unlock
  return "$rc"
}

# Copy function NAME to NEWNAME (bash and zsh), so a wrapper can call the
# original after the tool's own script defined it.
_nl_save_fn() {   # _nl_save_fn NAME NEWNAME
  if [ -n "${ZSH_VERSION:-}" ]; then
    functions[$2]=$functions[$1]
  else
    eval "$2() $(declare -f "$1" | tail -n +2)"
  fi
}

# --------------------------------------------------------------------- nvm

_nvm_lazy_stubs() {
  local c
  for c in nvm node npm npx; do
    eval "$c() { _nvm_lazy_load $c \"\$@\"; }"
  done
}

# Install nvm under the lock. Another shell may have installed it while this
# shell waited for the answer or for the lock, so check again inside the lock.
_nvm_install_tool() {   # _nvm_install_tool CMD
  local tmp rc=0 ver
  _nl_lock || return 1
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    _nl_unlock
    return 0
  fi
  # the installer runs npm, which fails when its global prefix tree is missing
  mkdir -p "$NVM_DIR" "${npm_config_prefix:-$NVM_DIR}/lib/node_modules" &&
    tmp=$(mktemp) || { _nl_unlock; return 1; }
  # /releases/latest redirects to /releases/tag/<version>: no API token needed
  ver=$(curl -fsSL -o /dev/null -w '%{url_effective}' \
    https://github.com/nvm-sh/nvm/releases/latest) && ver=${ver##*/}
  case $ver in
    v[0-9]*) ;;
    *)
      echo "$1: could not resolve the latest nvm release: $ver" >&2
      rm -f "$tmp"
      _nl_unlock
      return 1
      ;;
  esac
  echo "$1: installing nvm $ver" >&2
  curl -fsSL -o "$tmp" \
    "https://raw.githubusercontent.com/nvm-sh/nvm/$ver/install.sh" &&
    PROFILE=/dev/null sh "$tmp" || rc=1
  rm -f "$tmp"
  _nl_unlock
  [ "$rc" -eq 0 ] || echo "$1: nvm install failed" >&2
  return "$rc"
}

_nvm_lazy_load() {
  # zsh NO_CLOBBER would make nvm's own > redirects fail inside these calls
  [ -z "${ZSH_VERSION:-}" ] || eval 'setopt local_options clobber'
  local cmd=$1 target ver
  shift
  if [ -z "${NVM_DIR:-}" ]; then
    echo "$cmd: NVM_DIR is not set" >&2
    return 1
  fi
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    if [ ! -t 0 ] || [ ! -t 2 ]; then
      echo "$cmd: nvm is not installed in $NVM_DIR" >&2
      return 1
    fi
    cat >&2 <<EOF
nvm is not installed. Installing will:
  - download the installer of the latest nvm release from github.com/nvm-sh/nvm
  - put nvm in $NVM_DIR, Node versions in $NVM_DIR/versions and global npm
    packages in ${npm_config_prefix:-$NVM_DIR/npm-global}
  - leave your shell startup files alone
$NVM_DIR is in the OS-reclaimed tool cache: Node versions are shared by all
projects, and the OS may delete files there. The next call of nvm, node, npm or
npx then reinstalls whatever is missing.
EOF
    _nl_ask "Install nvm now?" || {
      echo "$cmd: nvm not installed; it asks again on the next call" >&2
      return 1
    }
    _nvm_install_tool "$cmd" || return 1
  fi

  # npm fails when its global prefix tree does not exist yet
  [ -z "${npm_config_prefix:-}" ] ||
    mkdir -p "$npm_config_prefix/lib/node_modules" 2>/dev/null

  # Real nvm replaces the stubs. --no-use: pick the version below, after the
  # damage check.
  unset -f nvm node npm npx
  . "$NVM_DIR/nvm.sh" --no-use || { _nvm_lazy_stubs; return 1; }
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

  # `nvm install X` by hand: finish and share the new version afterwards
  _nl_save_fn nvm _nl_nvm_orig
  # The install runs under the lock, so two shells never extract into the same
  # version directory at once.
  nvm() {
    local rc
    [ -z "${ZSH_VERSION:-}" ] || eval 'setopt local_options clobber'
    if [ "${1:-}" = install ]; then
      _nl_lock || return 1
      _nl_nvm_orig "$@"
      rc=$?
      _nl_adopt nvm 1
      _nl_unlock
    else
      _nl_nvm_orig "$@"
      rc=$?
    fi
    return "$rc"
  }

  target=$(nvm_alias default 2>/dev/null)
  ver=$(nvm version default 2>/dev/null)
  case $ver in
    ''|N/A)
      if [ -n "$target" ]; then
        echo "nvm: default Node $target is missing; reinstalling" >&2
        # the sidecar names the exact version, so a copy can be linked from
        # fnm instead of downloaded; without it, nvm resolves the alias online
        if [ -s "$NVM_DIR/.default-version" ]; then
          _nl_ensure nvm "$(cat "$NVM_DIR/.default-version")" >/dev/null ||
            nvm install "$target" >&2
        else
          nvm install "$target" >&2
        fi
      elif [ -t 0 ] && _nl_ask \
          "No default Node version. Install the latest LTS" \
          "and make it the default?"; then
        # another shell may have set a default meanwhile: check inside the lock
        _nl_lock && {
          [ -n "$(nvm_alias default 2>/dev/null)" ] || nvm install --lts >&2
          _nl_unlock
        }
      fi
      ;;
  esac
  # damage check, manifest for a fresh install, and sharing with fnm
  ver=$(nvm version default 2>/dev/null)
  case $ver in
    ''|N/A) ;;
    *) _nl_ensure nvm "$ver" >/dev/null &&
         echo "$ver" >| "$NVM_DIR/.default-version.$$" &&
         mv "$NVM_DIR/.default-version.$$" "$NVM_DIR/.default-version" ;;
  esac
  nvm use default >/dev/null 2>&1

  if [ "$cmd" = nvm ] && [ $# -eq 0 ]; then
    return 0
  fi
  "$cmd" "$@"
}

# --------------------------------------------------------------------- fnm

# The "default" alias can point at another alias (lts-latest), which points at
# the installation directory: follow the chain, print the version directory
# name (empty if there is no default alias).
_fnm_default_version() {
  local p="$FNM_DIR/aliases/default" n=0 t
  [ -L "$p" ] || return 0
  while [ -L "$p" ] && [ "$n" -lt 5 ]; do
    t=$(readlink "$p")
    case $t in /*) p=$t ;; *) p=$(dirname "$p")/$t ;; esac
    n=$((n + 1))
  done
  p=${p%/installation}
  echo "${p##*/}"
}

# Install the fnm binary under the lock; check again inside the lock, as for
# nvm. The binary is installed by rename, so a shell never runs a half-written
# file.
_fnm_install_tool() {   # _fnm_install_tool ZIP_NAME
  local tmp rc=0
  _nl_lock || return 1
  if [ -x "$FNM_DIR/bin/fnm" ]; then
    _nl_unlock
    return 0
  fi
  mkdir -p "$FNM_DIR/bin" && tmp=$(mktemp -d) || { _nl_unlock; return 1; }
  curl -fsSL -o "$tmp/fnm.zip" \
    "https://github.com/Schniz/fnm/releases/latest/download/$1" &&
    unzip -q -o "$tmp/fnm.zip" -d "$tmp" &&
    install -m 755 "$tmp/fnm" "$FNM_DIR/bin/.fnm.$$" &&
    mv "$FNM_DIR/bin/.fnm.$$" "$FNM_DIR/bin/fnm" || rc=1
  rm -rf "$tmp"
  _nl_unlock
  [ "$rc" -eq 0 ] || echo "fnm: install failed" >&2
  return "$rc"
}

_fnm_lazy_load() {
  # zsh NO_CLOBBER would make nvm's own > redirects fail inside these calls
  [ -z "${ZSH_VERSION:-}" ] || eval 'setopt local_options clobber'
  local cmd=$1 zip ver shell_name
  shift
  if [ -z "${FNM_DIR:-}" ]; then
    echo "$cmd: FNM_DIR is not set" >&2
    return 1
  fi
  case ":$PATH:" in *":$FNM_DIR/bin:"*) ;; *) PATH="$FNM_DIR/bin:$PATH" ;; esac
  if ! [ -x "$FNM_DIR/bin/fnm" ]; then
    if [ ! -t 0 ] || [ ! -t 2 ]; then
      echo "fnm: not installed in $FNM_DIR/bin" >&2
      return 1
    fi
    case "$(uname -s)-$(uname -m)" in
      Darwin-*)                  zip=fnm-macos.zip ;;
      Linux-x86_64)              zip=fnm-linux.zip ;;
      Linux-aarch64|Linux-arm64) zip=fnm-arm64.zip ;;
      *) echo "fnm: no release for $(uname -s)-$(uname -m)" >&2; return 1 ;;
    esac
    cat >&2 <<EOF
fnm is not installed. Installing will:
  - download $zip from the latest fnm release on github.com/Schniz/fnm
  - put the fnm binary in $FNM_DIR/bin and Node versions in
    $FNM_DIR/node-versions
  - leave your shell startup files alone
$FNM_DIR is in the OS-reclaimed tool cache: the OS may delete files there. The
next call of fnm then reinstalls whatever is missing.
EOF
    _nl_ask "Install fnm now?" || {
      echo "fnm: not installed; it asks again on the next call" >&2
      return 1
    }
    _fnm_install_tool "$zip" || return 1
  fi

  unset -f fnm
  [ -z "${npm_config_prefix:-}" ] ||
    mkdir -p "$npm_config_prefix/lib/node_modules" 2>/dev/null

  ver=$(_fnm_default_version)
  if [ -z "$ver" ] && [ -t 0 ] && _nl_ask \
      "No default Node version. Install the latest LTS" \
      "and make it the default?"; then
    # another shell may have set a default meanwhile: check inside the lock
    _nl_lock && {
      [ -n "$(_fnm_default_version)" ] ||
        {
          fnm install --lts >&2 && fnm default lts-latest >&2 &&
            _nl_adopt fnm 1
        }
      _nl_unlock
    }
    ver=$(_fnm_default_version)
  fi
  [ -z "$ver" ] || _nl_ensure fnm "$ver" >/dev/null

  case ${ZSH_VERSION:+zsh} in zsh) shell_name=zsh ;; *) shell_name=bash ;; esac
  eval "$(fnm env --shell "$shell_name")"
  [ -z "$ver" ] || fnm use "${ver#v}" >/dev/null 2>&1

  # `fnm install X` by hand (or a `use` that installs): same, under the lock
  fnm() {
    local rc
    [ -z "${ZSH_VERSION:-}" ] || eval 'setopt local_options clobber'
    case ${1:-} in
      install|use|exec|default)
        _nl_lock || return 1
        command fnm "$@"
        rc=$?
        _nl_adopt fnm 1
        _nl_unlock
        ;;
      *) command fnm "$@"; rc=$? ;;
    esac
    return "$rc"
  }
  fnm "$@"
}

_nvm_lazy_stubs
fnm() { _fnm_lazy_load fnm "$@"; }

# restore alias expansion
if [ -n "${ZSH_VERSION:-}" ]; then
  eval '[[ -n $_nl_aliases_were_on ]] && setopt ALIASES'
else
  [ -z "$_nl_aliases_were_on" ] || shopt -s expand_aliases
fi
unset _nl_aliases_were_on
