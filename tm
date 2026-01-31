#!/bin/sh
BASE_SESSION="main"

# 0. Define Cleanup Function
cleanup() {
    # Reset the terminal (fixes staircase/alignment issues)
    stty sane 2>/dev/null
    
    # Cleanup grouped session if it was auto-generated
    case "$TAB_ID" in
        auto_*) tmux kill-session -t "$TAB_ID" 2>/dev/null ;;
    esac
}

# Register trap: run cleanup on EXIT (normal) and INT/TERM (interrupts)
# Note: In POSIX sh, trap EXIT might not catch signals like INT, 
# so we list them explicitly.
trap cleanup EXIT INT TERM

# 1. Prevent nesting
if [ -n "$TMUX" ]; then
    echo "Error: Already inside a tmux session."
    exit 1
fi

# 2. Ensure base session exists
if ! tmux has-session -t "$BASE_SESSION" 2>/dev/null; then
    tmux new-session -d -s "$BASE_SESSION"
fi

# 3. Handle ID Selection
if [ -n "$1" ]; then
    TAB_ID="$1"
else
    echo "Active views for '$BASE_SESSION':"
    tmux list-sessions -F '#{session_name} #{?session_grouped,(group #{session_group}),}' 2>/dev/null | grep "(group $BASE_SESSION)" || echo "  (none)"
    printf "\nEnter view name (or press enter for auto): "
    read -r input
    TAB_ID="${input:-auto_$(date +%s)_$$}"
fi

# 4. Attach to grouped session
# This is where the script "blocks" until you exit tmux.
tmux new-session -t "$BASE_SESSION" -s "$TAB_ID" -A

# Note: stty sane and session killing are now handled by the trap above.

