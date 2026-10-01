# Copyright (C) 2026 Wesley Tanaka
# Sourced by Claude Code before every Bash command.  claude-config.sh
# arranges this via a SessionStart hook that appends a line to
# $CLAUDE_ENV_FILE, so edits here apply without restarting Claude.
#
# Keep this POSIX sh: the shell may be zsh or bash.  Environment
# variables, PATH and aliases, plus the two shell options noted below.

# Environment variables, including the per-user cache dir ones
# (CARGO_HOME, PNPM_HOME, BUN_INSTALL, ANDROID_HOME, ...).
. "$HOME/.allenv.sh"

# Fallbacks for when the shell snapshot did not supply these (bash).
if ! command -v addpath >/dev/null 2>&1; then
  addpath()
  {
    for _d; do
      [ -d "$_d" ] || continue
      case ":$PATH:" in *":$_d:"*) continue ;; esac
      PATH="${PATH:+$PATH:}$_d"
    done
    unset _d
    export PATH
  }
fi
command -v addclasspath >/dev/null 2>&1 || addclasspath() { :; }
command -v preclasspath >/dev/null 2>&1 || preclasspath() { :; }

# Directories that do not exist are skipped, so this is safe to source whole.
. "$HOME/.addpath.sh"

. "$HOME/.aliases.sh"
# The -i aliases prompt for confirmation, which hangs a non-interactive agent.
unalias rm cp mv 2>/dev/null

# "set +C" turns the noclobber option off (zsh: unsetopt NO_CLOBBER).  With
# noclobber on, "cmd > file" refuses to overwrite an existing file unless
# written ">| file".  .zshrc turns it on and the shell snapshot carries it into
# Claude's shell, which makes ordinary redirects fail.
set +C
# zsh only: stop "=word" from expanding to a command path (e.g. "=cmd"), which
# mangles arguments that happen to start with "=".  Carried over from the old
# CLAUDECODE block in zshenv.sh.
[ -n "$ZSH_VERSION" ] && unsetopt equals

# Fail loudly instead of opening an interactive editor or pager.  This must
# come after .allenv.sh (which sets VISUAL=vim).  git and jj prefer
# GIT_EDITOR/JJ_EDITOR over VISUAL/EDITOR, so set those too.
export VISUAL=false EDITOR=false GIT_EDITOR=false JJ_EDITOR=false
export GIT_SEQUENCE_EDITOR=false
export PAGER=cat GIT_PAGER=cat GH_PAGER=cat
