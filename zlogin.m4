include(functions.m4)dnl
include(init.m4)dnl
changequote({{, }})dnl
SETTERMINALNAME=true
if [ "$TERM" = "linux" -o "$XTERMTYPE" = "utility" ]; then
   SETTERMINALNAME=false
fi
ifelse(SYS_LAB, {{UGCS}}, {{if [[ -o interactive ]]; then
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
fi}})

TMOUT=60
{{
TRAPALRM()
{
   echo -n '\e[0m'
}
}}

if [[ -o interactive ]]; then
   if [[ $SETTERMINALNAME == true ]]; then
      if [ ! "$TERM" = linux ]; then
         resetterminaltitle
      fi
   fi           
   if [ -n "`ssh-add -l 2>&1 | grep -i \"could not.*connect\"`" ]; then
      TMPFILE="/tmp/ssh-agent-list$$"
      eval `ssh-agent` 2>&1 > "$TMPFILE"
      cat "$TMPFILE" |& cut -d\  -f3 | sed -e "s/$/ $$/" \
         >>! $HOME/.ssh/agentlist-`hostname`
      /bin/rm "$TMPFILE"
   else
      export SSH_AGENT_PID=""
   fi
   if [ -n "`ssh-add -l 2>&1 | grep -i \"could not.*connect\"`" ]; then
      echo Agent not found, trying again
      exec ssh-agent "$SHELL" -l
   fi
fi
:
