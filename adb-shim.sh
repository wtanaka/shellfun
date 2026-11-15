#!/bin/sh
# Wrapper for adb, installed as $HOME/bin/adb. The Android platform-tools live
# in the OS-reclaimed tool cache ($ANDROID_PLATFORM_TOOLS_DIR, set by
# allenv.sh), not in Homebrew. When the OS has reclaimed the directory, or
# on first use, the wrapper asks before downloading Google's platform-tools
# zip (about 15 MB). Without a terminal it never downloads: it prints how
# to install and exits 1.

if [ -z "${ANDROID_PLATFORM_TOOLS_DIR:-}" ] && [ -f "$HOME/.allenv.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.allenv.sh"
fi

dir=${ANDROID_PLATFORM_TOOLS_DIR:-}
if [ -z "$dir" ]; then
  echo "adb: no tool cache directory (see allenv.sh)" >&2
  exit 1
fi

if [ ! -x "$dir/platform-tools/adb" ]; then
  case $(uname -s) in
    Darwin) os=darwin ;;
    *) os=linux ;;
  esac
  url=https://dl.google.com/android/repository/platform-tools-latest-$os.zip
  if [ ! -t 0 ] || [ ! -t 2 ]; then
    echo "adb: not installed; run adb in a terminal once to install it." >&2
    exit 1
  fi
  cat >&2 <<MSG
adb is not installed. Installing will:
  - download $url
  - unpack it into $dir
The directory is in the OS-reclaimed tool cache: the OS may delete files
there. The next adb call asks again.
MSG
  printf 'Install adb now? [y/N] ' >&2
  read -r ans
  case $ans in
    [yY]|[yY][eE][sS]) ;;
    *) echo "adb: not installed" >&2; exit 1 ;;
  esac
  tmp=$(mktemp -d "$dir.XXXXXX" 2>/dev/null) || {
    mkdir -p "$(dirname "$dir")" && tmp=$(mktemp -d "$dir.XXXXXX") || exit 1
  }
  if curl -fsSL -o "$tmp/pt.zip" "$url" &&
      unzip -q -o "$tmp/pt.zip" -d "$tmp/x" &&
      [ -x "$tmp/x/platform-tools/adb" ]; then
    rm -rf "$dir"
    mv "$tmp/x" "$dir" || exit 1
    rm -rf "$tmp"
  else
    echo "adb: download or unpack failed" >&2
    rm -rf "$tmp"
    exit 1
  fi
fi

PATH=$dir/platform-tools:$PATH
export PATH
exec "$dir/platform-tools/adb" "$@"
