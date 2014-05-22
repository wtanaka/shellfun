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
                    SYS_HOST,{{altair.mili.eu.org}},{{/usr/etc/gale}},
                    SYS_HOST,{{dragontail.i}},{{/home/gale/etc/gale}},
                             {{/usr/local/etc/gale}})

{{
precmd()
{
   EXIT_STATUS=$?

   TODOFILE=
   for f in todo ~/todo; do
      [ -r "$f" ] && TODOFILE="$f"
      break
   done

   if [ -n "$TODOFILE" ]; then
      TODOLINES="0"
      {
         read LINE
         while [ -n "$LINE" ]; do
            #TODOLINES="$[ $TODOLINES + 1 ]"
            (( TODOLINES++ ))
            read LINE
         done
      } < "$TODOFILE"
      if [ $TODOLINES -gt 0 ]; then
         : "$RANDOM"
         NLINE="$[ $RANDOM % $TODOLINES + 1 ]"
         while [ ! "$NLINE" = "0" ]; do
            read PRE
            NLINE="$[ $NLINE - 1 ]"
         done < "$TODOFILE"
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
}}

ifelse(SYS_HOST,{{usw-pr-shell1}},praya=/home/groups/p/pr/praya
wohenchan=/home/groups/w/wo/wohenchan
cabal=/home/groups/c/ca/cabal
shellfun=/home/groups/s/sh/shellfun
bleepie=/home/groups/b/bl/bleepie
)dnl
ifelse(SYS_HOST,{{usw-pr-shell2}},praya=/home/groups/p/pr/praya
wohenchan=/home/groups/w/wo/wohenchan
cabal=/home/groups/c/ca/cabal
shellfun=/home/groups/s/sh/shellfun
bleepie=/home/groups/b/bl/bleepie
)dnl

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

zstyle ':completion:*' expand prefix suffix

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

vncviewerflags=(-h -listen -via -shared -noshared -viewonly -fullscreen -noraiseonbeep -passwd -encodings -bgr233 -owncmap -truecolour -depth -compresslevel -quality -nocursorshape)
compctl -f -k "($vncviewerflags)" \
        -x 'c[-1,-depth]' -k "(8 15 16 24 32)" \
        - 'c[-1,-compresslevel]' -k "(0 1 2 3 4 5 6 7 8 9)" \
        - 'c[-1,-quality]' -k "(0 1 2 3 4 5 6 7 8 9)" \
        -- vncviewer
unset vncviewerflags

javacflags=(-deprecation -verbose)
compctl -g "*.java" -k "($javacflags)" javac
unset javacflags

xscreensavercommandflags=( -demo -prefs -activate -deactivate -cycle -next -prev -select -exit -restart -lock -version -time )
compctl -k "($xscreensavercommandflags)" xscreensaver-command
unset xscreensavercommandflags

gnomemozremoteflags=(--disable-sound --enable-sound --espeaker= --version --help --usage --version --remote= --raise --noraise --local --newwin --display= --id= --sync)
compctl -k "($gnomemozremoteflags)" gnome-moz-remote
unset gnomemozremoteflags


hosts=(\
agora.ugcs.caltech.edu. \
altair.mili.eu.org. \
amatho.ugcs.caltech.edu. \
anglewing.i. \
arachno.ugcs.caltech.edu. \
auto.ugcs.caltech.edu. \
baht.ugcs.caltech.edu. \
barf.ugcs.caltech.edu. \
barter.ugcs.caltech.edu. \
beg.ugcs.caltech.edu. \
bolivar.ugcs.caltech.edu. \
cf.sourceforge.net. \
chunder.ugcs.caltech.edu. \
claustro.ugcs.caltech.edu. \
colostomy.bitfield.org. \
cruzeiro.ugcs.caltech.edu. \
dabney.caltech.edu. \
darkhorse.ispheres.com. \
dazzler.hero.catori.com. \
drachma.ugcs.caltech.edu. \
dragontail.i. \
euro.ugcs.caltech.edu. \
greenlantern.hero.catori.com. \
groat.ugcs.caltech.edu. \
hork.ugcs.caltech.edu. \
hulk.hero.catori.com. \
insanity.bitfield.org. \
intel.ugcs.caltech.edu. \
kind.cs.kun.nl \
krishna.i. \
krone.ugcs.caltech.edu. \
lek.ugcs.caltech.edu. \
lenin.dabney.caltech.edu. \
mark.ugcs.caltech.edu. \
mili.eu.org. \
mono.ugcs.caltech.edu. \
moth.i. \
myxo.ugcs.caltech.edu. \
necro.ugcs.caltech.edu. \
ngwee.ugcs.caltech.edu. \
ofb.net. \
pfennig.ugcs.caltech.edu. \
photo.ugcs.caltech.edu. \
pride.ugcs.caltech.edu. \
purchase.ugcs.caltech.edu. \
pyro.ugcs.caltech.edu. \
queen.i. \
regurgitate.ugcs.caltech.edu. \
retch.ugcs.caltech.edu. \
riyal.ugcs.caltech.edu. \
satyr.i. \
seniti.ugcs.caltech.edu. \
shell1.sourceforge.net. \
slashdot.org. \
snout.i. \
sourceforge.net. \
spew.ugcs.caltech.edu. \
spica.mili.eu.org. \
steal.ugcs.caltech.edu. \
triskaideka.ugcs.caltech.edu. \
upchuck.ugcs.caltech.edu. \
viceroy.i. \
yak.ugcs.caltech.edu. \
zloty.ugcs.caltech.edu. \
)

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
