#!/bin/sh

# 1. Configuration
GROUP_NAME="main"  # The shared pool of windows

# 2. Prevent nesting
if [ -n "$TMUX" ]; then
    echo "Error: Already inside a tmux session."
    exit 1
fi

# 3. Get the Portal ID (e.g., "1", "2", "3")
if [ -z "$1" ]; then
    echo "Usage: tm [number]"
    exit 1
fi
PORTAL_ID="$1"
VIEW_NAME="view_${PORTAL_ID}"
TARGET_DIR="${HOME}"

# 4. Ensure the Main Group exists
if ! tmux has-session -t "$GROUP_NAME" 2>/dev/null; then
    # Create the group and the first window
    tmux new-session -d -s "$GROUP_NAME" -n "temp"
fi

# 5. Ensure the specific Window for this clone exists in the Group
if ! tmux list-windows -t "$GROUP_NAME" | grep -q "^${PORTAL_ID}:"; then
    # Create the window, name it by ID, and set the starting directory
    tmux new-window -t "$GROUP_NAME:${PORTAL_ID}" -n "${PORTAL_ID}" -c "$TARGET_DIR"
fi

# 6. Handle the Portal Session (The View)
# If the view session doesn't exist, create it linked to the group.
if ! tmux has-session -t "$VIEW_NAME" 2>/dev/null; then
    tmux new-session -d -s "$VIEW_NAME" -t "$GROUP_NAME"
    # Restrict bells to only the session currently viewing the active window
    tmux set-option -t "$VIEW_NAME" bell-action current
fi

# 7. Force this specific view to look at the correct window
tmux select-window -t "${VIEW_NAME}:${PORTAL_ID}"

# 8. Attach to the portal session
tmux attach-session -t "$VIEW_NAME"
