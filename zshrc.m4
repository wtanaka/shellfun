include(functions.m4)dnl
include(init.m4)dnl
changequote({{,}})dnl
PROMPT="%B%3c %#%b "
signal_names[129]=(`kill -l`)
ifelse(SYS_LAB,{{UGCS}},RRPROMPT="(%m) ugcs %B%T%b%(0?,, [exit %?])",
SYS_LAB,{{DABNEY}},RRPROMPT="(%m) dabney %B%T%b%(0?,, [exit %?])",
RRPROMPT="(%m) %B%T%b%(0?,, [exit %?])")
ifelse(SYS_HOST,{{castor.mongers.ml.org}},setopt NO_BEEP NO_HIST_BEEP NO_LIST_BEEP)
GALE_SYS_DIR=ifelse(SYS_LAB,{{UGCS}},{{/home/egnor/etc/gale}},
                    SYS_LAB,{{CS}},{{/home/jtr/etc/gale}},
                    SYS_HOST,{{altair.mili.eu.org}},{{/opt/gale-0.90c/etc/gale}},
                             {{/usr/local/etc/gale}})

precmd()
{
   EXIT_STATUS=$?
   if [ -r "todo" ]; then
      TODOFILE="todo"
   else 
      if [ -r "$HOME/todo" ]; then
         TODOFILE="$HOME/todo"
      else
         TODOFILE=""
      fi
   fi
   if [ -n "$TODOFILE" ]; then
      TODOLINES="0"
      {
         read LINE
         while [ -n "$LINE" ]; do
            TODOLINES="$[ $TODOLINES + 1 ]"
            read LINE
         done
      } < "$TODOFILE"
      if [ "$[ $TODOLINES > 0 ]" = "1" ]; then
         echo "$RANDOM" > /dev/null
         NLINE="$[ $RANDOM % $TODOLINES + 1 ]"
         {
         while [ ! "$NLINE" = "0" ]; do
            read PRE
            NLINE="$[ $NLINE - 1 ]"
         done
         } < "$TODOFILE"
         RPROMPT="${PRE%%[ ]} ${RRPROMPT}"
      else
         RPROMPT="${RRPROMPT}"
      fi
   else
      RPROMPT="${RRPROMPT}"
   fi
   if [ -n "$signal_names[$EXIT_STATUS]" ]; then
      RPROMPT="${RPROMPT} $signal_names[$EXIT_STATUS]"
   fi
}

# use compctl to override?
fignore=(.o .class .u .d \~)
REPORTTIME=10

setopt AUTO_MENU
setopt AUTO_LIST
unsetopt BG_NICE
setopt NO_CLOBBER
setopt COMPLETE_IN_WORD
setopt HIST_IGNORE_DUPS
setopt NO_HUP
setopt LIST_TYPES
setopt MAIL_WARNING
setopt AUTO_CD
setopt AUTO_PUSHD

bindkey -e
bindkey "\e[1~" beginning-of-line
bindkey "\e[2~" overwrite-mode
bindkey "\e[3~" delete-char
bindkey "\e[4~" end-of-line
bindkey "\e[A" up-line-or-search
bindkey "\eOA" up-line-or-search
bindkey "\e[B" down-line-or-search
bindkey "\eOB" down-line-or-search
bindkey "\eOD" backward-char
bindkey "\eOC" forward-char
bindkey " " magic-space

#compctl -x 'c[-1,-e]' -g "$GALE_SYS_DIR"'/auth/(cache|local)/*@*(:t)' -- gsend
compctl -ug "$GALE_SYS_DIR"'/auth/(cache|local)/*@*(:t)' gsend
compctl -ug "$GALE_SYS_DIR"'/auth/(cache|local)/*(:t)' gkinfo
compctl -g '(.[^/]*|[^C]*|C[^V]*|CV[^S]*|CVS[^/]*)(-/)' cd
compctl -s '`unsetopt`' setopt
compctl -s '`setopt`' unsetopt
compctl -g "(*.latex|*.tex)" latex
compctl -g "*.java" javac
compctl -g "*.java" jikes
compctl -g '* .*' rm
compctl -g '* .*' mv
compctl -g '*' ls
compctl -l '' -x 'p[1]' -f -- . source
compctl -l '' nohup noglob exec nice eval - time rusage
compctl -l '' -x 'p[1]' -eB -- builtin
compctl -l '' -x 'p[1]' -em -- command

###########################################################################
# find
###########################################################################
# Find is very system dependent, this one is for GNU find.
# Note that 'r[-exec,;]' must come first
if [[ -r /proc/filesystems ]]; then
    # Linux
    filesystems='"${${(f)$(</proc/filesystems)}#*       }"'
else
    filesystems='ufs 4.2 4.3 nfs tmp mfs S51K S52K'
fi
compctl -x 'r[-exec,;][-ok,;]' -l '' - \
   's[-]' -s 'daystart {max,min,}depth follow noleaf version xdev \
   {a,c,}newer {a,c,m}{min,time} empty false {fs,x,}type gid inum links \
        {i,}{l,}name {no,}{user,group} path perm regex size true uid used \
        exec {f,}print{f,0,} ok prune ls' - \
        'p[1]' -g '. .. *(-/)' - \
        'C[-1,-((a|c|)newer|fprint(|0|f))]' -f - \
        'c[-1,-fstype]' -s "$filesystems" - \
        'c[-1,-group]' -k groups - \
        'c[-1,-user]' -u -- find
unset filesystems

###########################################################################
# screen
###########################################################################
screenflags=(-fn)
#compctl -x 'p[1,-1]' -k "($screenflags)" -- \
#        -t+ + -x 'p[1,-1]' -l '' -- \
#        screen
compctl -x 'p[1,-1]' -l '' -- screen
unset screenflags

###########################################################################
# Completion control for netscape
###########################################################################
netscapeflags=(-help -version -display -geometry -visual -install -no-install -ncols -mono -iconic -xrm -remote -id -raise -noraise -nethelp -dont-force-window-stacking -no-about-splash -no-session-management -session-management -no-irix-session-management -irix-session-management -dont-save-geometry-prefs -ignore-geometry-prefs)
compctl -f -k "($netscapeflags)" \
        -x 'c[-1,-remote]' -k '(openURL\(http://my.yahoo.com/\) openURL\(http://my.yahoo.com/\,new-window\) reload\(super\) reload\(\) back\(\) forward\(\) stopLoading\(\) loadImages\(\))' \
        -  'c[-1,-display]' -K CompctlXDisplays \
        -- netscape
unset netscapeflags

javacflags=(-deprecation -verbose)
compctl -g "*.java" -k "($javacflags)" javac
unset javacflags

xscreensavercommandflags=( -demo -prefs -activate -deactivate -cycle -next -prev -select -exit -restart -lock -version -time )
compctl -k "($xscreensavercommandflags)" xscreensaver-command
unset xscreensavercommandflags

hosts=(freebsd.compile.sourceforge.net. linux.compile.sourceforge.net. sourceforge.net. shell1.sourceforge.net. altair.mili.eu.org. slashdot.org. dragontail.infospheres.com. viceroy.infospheres.com. anglewing.infospheres.com. greenlantern.hero.catori.com. snout.infospheres.com. queen.infospheres.com. moth.infospheres.com. lenin.dabney.caltech.edu. dabney.caltech.edu. hulk.hero.catori.com. mili.eu.org. spica.mili.eu.org. intel.ugcs.caltech.edu. dazzler.hero.catori.com.)

sshflags=(-l -n -a  -x -i -t -v -V -q -f -e -c -p -P -L -R -C -g -o)
compctl -k "($sshflags $hosts)" \
        -x 'c[-1,-o]' -k '(ForwardAgent\ yes)' \
        -- ssh
unset sshflags

compctl -k "($hosts)" mtr
compctl -k "($hosts)" traceroute
compctl -k "($hosts)" ping
compctl -k "($hosts)" nslookup

unset hosts

CompctlXDisplays()
{
   reply=(`xauth list | cut -d\  -f 1` $DISPLAY)
}

if which biff > /dev/null 2>&1; then
   biff y
fi
