cat <<\TEMPLATEQUOTE
if [ -n "$SSH_AGENT_PID" -a ! "$XTERMTYPE" = "utility" ]; then
   kill "$SSH_AGENT_PID"
fi
TEMPLATEQUOTE
