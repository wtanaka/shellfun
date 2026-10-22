#!/bin/sh
cat <<\TEMPLATEQUOTE
SETTERMINALNAME=true
if [ "$TERM" = "linux" -o "$XTERMTYPE" = "utility" ]; then
   SETTERMINALNAME=false
fi
TEMPLATEQUOTE

if [ "$SYS_LAB" = 'UGCS' ]; then
  cat <<\TEMPLATEQUOTE
if [[ -o interactive ]]; then
   if [ -z "`echo /ug/adm/login/current/\`hostname\`.\`whoami\`.$$*(N)`" ]; then
      exec login -q -q -f -p -h $DISPLAY wtanaka -c "$SHELL -l"
   fi
   inc -file /home/wtanaka/mail/iinbox -truncate +iinbox |& grep -v "^inc: no mail"
   inc -file /home/wtanaka/mail/rin -truncate +rin |& grep -v "^inc: no mail"
   inc -file /home/wtanaka/mail/cs3 -truncate +cs3 |& grep -v "^inc: no mail"
   inc -file /home/wtanaka/mail/todo -truncate +todo |& grep -v "^inc: no mail"
   sortm -limit 0 -textfield subject +todo
   scan +todo | head
   gsub 
fi
TEMPLATEQUOTE
fi

cat <<\TEMPLATEQUOTE
TMOUT=60
TRAPALRM()
{
   echo -n '\e[0m'
}

if [[ -o interactive ]]; then
   if [[ $SETTERMINALNAME == true ]]; then
      if [ ! "$TERM" = linux ]; then
         resetterminaltitle
      fi
   fi           
   ssh-add -l >/dev/null 2>&1   # exit 2: no agent
   if (( $? == 2 )); then
      TMPFILE="/tmp/ssh-agent-list$$"
      eval `ssh-agent` 2>&1 > "$TMPFILE"
      cat "$TMPFILE" |& cut -d\  -f3 | sed -e "s/$/ $$/" \
         >>! $HOME/.ssh/agentlist-`hostname`
      /bin/rm "$TMPFILE"
      ssh-add -l >/dev/null 2>&1
      if (( $? == 2 )); then
         echo Agent not found, trying again
         exec ssh-agent "$SHELL" -l
      fi
   else
      export SSH_AGENT_PID=""
   fi
fi
:
TEMPLATEQUOTE
