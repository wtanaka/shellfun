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

export CARGO_HOME="$_tool_cache/cargo"
export RUSTUP_HOME="$_tool_cache/rustup"
export CARGO_TARGET_DIR="$_tool_cache/cargo-target"
export ELM_HOME="$_tool_cache/elm"
unset _tool_cache
