include(functions.m4)dnl
include(init.m4)dnl
changequote({{, }})dnl
if [ -n "$SSH_AGENT_PID" -a ! "$XTERMTYPE" = "utility" ]; then
   kill "$SSH_AGENT_PID"
fi
