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

case "$TMPDIR" in
  # macOS per-user private cache dir (getconf DARWIN_USER_CACHE_DIR)
  /var/folders/*/T/) _tool_cache="${TMPDIR%T/}C" ;;
  *) _tool_cache="${XDG_CACHE_HOME:-$HOME/.cache}" ;;
esac
# Resolve symlinks (macOS /var -> /private/var): some Rust crates, e.g. askama
# via uniffi_bindgen, compute relative paths against the canonical spelling
# and fail to find files when CARGO_HOME goes through the symlink
_tool_cache_real="$(cd -P "$_tool_cache" 2>/dev/null && pwd -P)" &&
  _tool_cache="$_tool_cache_real"
unset _tool_cache_real

export CARGO_HOME="$_tool_cache/cargo"
export RUSTUP_HOME="$_tool_cache/rustup"
export CARGO_TARGET_DIR="$_tool_cache/cargo-target"
export ELM_HOME="$_tool_cache/elm"
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
export POETRY_CACHE_DIR="$_tool_cache/poetry"
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
