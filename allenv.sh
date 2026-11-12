#export ESPEAKER="mili.eu.org:5001"
export CVSROOT="$HOME/cvsroot"
export CVS_RSH="ssh"
export PAGER="less -ieXw"
export VISUAL=vi
if which vim > /dev/null 2>&1; then
  export VISUAL=vim
fi
export WWW_HOME="http://wtanaka.com/"
export TEXEDIT='vim +%d %s'
export CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES="1024x768"
# Debian packaging
export DEBEMAIL="${DEBEMAIL}@yahoo.com"
export DEBEMAIL="wtanaka"
export DEBFULLNAME="Wesley Tanaka"
# Go language external libraries
export GOPATH="$HOME/dl/gocode"

# Where tool homes, toolchains and caches live.
#   macOS: the per-user temp dir (getconf DARWIN_USER_TEMP_DIR, the "T" dir),
#     which the OS reclaims when unused. Taken from getconf, not $TMPDIR,
#     because sudo, CI and sandboxes override $TMPDIR. Used only if this user
#     owns it and nobody else has access (mode 700).
#   elsewhere: ${XDG_CACHE_HOME:-$HOME/.cache} (under $HOME, so private).
# If no safe directory is found, _tool_cache stays empty: no tool variable is
# exported, so tools use their own defaults, and nothing extra reaches PATH.
_tool_cache=
if [ "$(uname -s)" = Darwin ]; then
  _tool_tmp="$(getconf DARWIN_USER_TEMP_DIR 2>/dev/null)"
  _tool_tmp="${_tool_tmp%/}"
  if [ -n "$_tool_tmp" ] &&
    [ -n "$(find "$_tool_tmp" -prune -type d -user "$(id -u)" -perm 700 \
      2>/dev/null)" ]; then
    _tool_cache="$_tool_tmp"
  else
    echo "allenv.sh: no private temp dir, leaving tool dirs at defaults" >&2
  fi
  unset _tool_tmp
else
  _tool_cache="${XDG_CACHE_HOME:-$HOME/.cache}"
  [ -d "$_tool_cache" ] || mkdir -p -m 700 "$_tool_cache" 2>/dev/null
fi
# Resolve symlinks (macOS /var -> /private/var): some Rust crates, e.g. askama
# via uniffi_bindgen, compute relative paths against the canonical spelling
# and fail to find files when CARGO_HOME goes through the symlink
if [ -n "$_tool_cache" ]; then
  _tool_cache_real="$(cd -P "$_tool_cache" 2>/dev/null && pwd -P)" &&
    _tool_cache="$_tool_cache_real"
  unset _tool_cache_real
fi
[ -n "$_tool_cache" ] && [ -d "$_tool_cache" ] || {
  unset _tool_cache
  return 0
}

export CARGO_HOME="$_tool_cache/cargo"
export RUSTUP_HOME="$_tool_cache/rustup"
export CARGO_TARGET_DIR="$_tool_cache/cargo-target"
export ELM_HOME="$_tool_cache/elm"
# WebAssembly
export EMSDK="$_tool_cache/emsdk"
export EM_CACHE="$_tool_cache/emscripten-cache"
export EM_CONFIG="$EMSDK/.emscripten"
# JavaScript
export npm_config_cache="$_tool_cache/npm"
export YARN_CACHE_FOLDER="$_tool_cache/yarn"
export PNPM_HOME="$_tool_cache/pnpm"
# pnpm's store/cache/state/global dirs live in its config.yaml (written by
# install.sh); npm_config_* env vars would make npm warn about unknown config
export BUN_INSTALL="$_tool_cache/bun"
export BUN_INSTALL_CACHE_DIR="$_tool_cache/bun/install/cache"
export NVM_DIR="$_tool_cache/nvm"
# nvm refuses to run if npm_config_prefix is set; with nvm, globals already
# go under $NVM_DIR/versions/node/<version>/
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  export npm_config_prefix="$_tool_cache/npm-global"
fi
# JVM (MAVEN_ARGS needs Maven 3.9+)
export MAVEN_ARGS="-Dmaven.repo.local=$_tool_cache/m2/repository"
export GRADLE_USER_HOME="$_tool_cache/gradle"
# Python
export PIP_CACHE_DIR="$_tool_cache/pip"
export UV_CACHE_DIR="$_tool_cache/uv"
# uv tool: venvs under UV_TOOL_DIR, command shims in UV_TOOL_BIN_DIR (on PATH
# via addpath.sh)
export UV_TOOL_DIR="$_tool_cache/uv-tools"
export UV_TOOL_BIN_DIR="$UV_TOOL_DIR/bin"
export POETRY_CACHE_DIR="$_tool_cache/poetry"
# pipx: venvs under PIPX_HOME, command shims in PIPX_BIN_DIR (on PATH via
# addpath.sh)
export PIPX_HOME="$_tool_cache/pipx"
export PIPX_BIN_DIR="$PIPX_HOME/bin"
# Go
export GOCACHE="$_tool_cache/go-build"
export GOMODCACHE="$_tool_cache/go-mod"
# Android
export ANDROID_HOME="$_tool_cache/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME="$_tool_cache/android"
# Misc
export COMPOSER_CACHE_DIR="$_tool_cache/composer"
export CCACHE_DIR="$_tool_cache/ccache"
export PLAYWRIGHT_BROWSERS_PATH="$_tool_cache/ms-playwright"
unset _tool_cache
