cat <<\TEMPLATEQUOTE
s()
{
   which gsub > /dev/null && gsub -K
   screen -A -x -fn -RR "$@"
}

addclasspath()
{
   OLDMANPATH="$MANPATH"
   MANPATH="$CLASSPATH"
   for i; do
      if [ -d "$i" -o -f "$i" ]; then
         for pathpart in $manpath; do
            if [[ "$pathpart" -ef "$i" ]]; then
               continue 2
            fi
         done
         if [ -z "${CLASSPATH}" ]; then
            export CLASSPATH="${i}"
         else
            export CLASSPATH="${CLASSPATH}:${i}"
         fi
      fi
   done
   export MANPATH="$OLDMANPATH"
}

edclasspath()
{
   FILENAME="`mktemp /tmp/edclasspath.XXXXXX`"
   if [ -z "$FILENAME" ]; then
      FILENAME="/tmp/edclasspath.$$"
   fi
   rm -f "$FILENAME"
   :>"$FILENAME"
   OIFS="$IFS"; IFS=":"; for pathpart in $CLASSPATH; do
      echo "$pathpart" >> "$FILENAME"
   done; IFS="$OIFS"
   if [ -z "$VISUAL" ]; then
      vi "$FILENAME"
   else
      "$VISUAL" "$FILENAME"
   fi
   export CLASSPATH=""
   while read LINE; do
      if [ -d "$LINE" -o -f "$LINE" ]; then
         if [ -z "${CLASSPATH}" ]; then
            export CLASSPATH="${LINE}"
         else
            export CLASSPATH="${CLASSPATH}:${LINE}"
         fi
      fi
   done < "$FILENAME"
   rm -f "$FILENAME"
}

preclasspath()
{
   for i; do
      if [ -d "$i" -o -f "$i" ]; then
         OIFS="$IFS"; IFS=":"; for pathpart in $CLASSPATH; do
            if [[ "$pathpart" -ef "$i" ]]; then
               IFS="$OIFS"
               continue 2
            fi
         done; IFS="$OIFS"
         if [[ -z "${CLASSPATH}" ]]; then
            export CLASSPATH="${i}"
         else
            export CLASSPATH="${i}:${CLASSPATH}"
         fi
      fi
   done
}

edpath()
{
   FILENAME="`mktemp /tmp/edpath.XXXXXX`"
   if [ -z "$FILENAME" ]; then
      FILENAME="/tmp/edpath.$$"
   fi
   rm -f "$FILENAME"
   for pathpart in $path; do
      echo "$pathpart" >>! "$FILENAME"
   done
   if [ -z "$VISUAL" ]; then
      vi "$FILENAME"
   else
      "$VISUAL" "$FILENAME"
   fi
   export PATH=""
   { while read LINE; do
      if [[ -d "$LINE" ]]; then
         if [[ -z "${PATH}" ]]; then
            export PATH="${LINE}"
         else
            export PATH="${PATH}:${LINE}"
         fi
      fi
   done } < "$FILENAME"
   rm -f "$FILENAME"
}

prepath()
{
   for i; do
      if [[ -d "$i" ]]; then
         for pathpart in $path; do
            if [[ "$pathpart" -ef "$i" ]]; then
               continue 2
            fi
         done
         if [[ -z "${PATH}" ]]; then
            export PATH="${i}"
         else
            export PATH="${i}:${PATH}"
         fi
      fi
   done
}

addpath()
{
   for i; do
      if [[ -d "$i" ]]; then
         for pathpart in $path; do
            if [[ "$pathpart" -ef "$i" ]]; then
               continue 2
            fi
         done
         if [[ -z "${PATH}" ]]; then
            export PATH="${i}"
         else
            export PATH="${PATH}:${i}"
         fi
      fi
   done
}

smv()
{
   if > /dev/null expr $# \<= 1; then
      echo need more than one argument
      ! :
      return
   fi

   while > /dev/null expr $# \> 1; do
      scp "$1" "$argv[$#]" && rm -f "$1"
      shift
   done
}

terminalname() { builtin print -n -P "\033]1;$*\007" }
terminalnametitle() { builtin print -n -P "\033]0;$*\007" }
terminaltitlename() { builtin print -n -P "\033]0;$*\007" }
terminaltitle() { builtin print -n -P "\033]2;$*\007" }
netscape-newwindow() { netscape -noraise -remote "openURL($*,new-window)" }

scpfor()
{
   hostname=`uname -n`
   for i ; do
      dirname=`dirname "$i"`
      filename=`basename "$i"`
      if [[ $dirname == /* ]]; then
         echo "${hostname}:$dirname/$filename"
      else
         echo "${hostname}:`pwd`/$dirname/$filename"
      fi
   done | sed -e 's/[^A-Za-z0-9/.:]/\\&/g'
}

umask 022

HISTSIZE=1000
setopt HIST_ALLOW_CLOBBER
setopt HIST_IGNORE_DUPS
setopt HIST_NO_STORE
setopt SH_WORD_SPLIT

#export JAVA_COMPILER=NONE
which fastjar >& /dev/null && export JAR=fastjar
which jikes >& /dev/null && export JAVAC=jikes\ +P
if [ -f "$HOME/.allenv.sh" ]; then
  . "$HOME/.allenv.sh"
fi
autoload zmv
fpath=($fpath $HOME/bin/zshf)
if [ -d "$HOME/bin/zshf" ]; then
   if [ -n "`ls $HOME/bin/zshf`" ]; then
      OWD="`pwd`"
      cd "$HOME/bin/zshf"
      autoload *
      cd "$OWD"
   fi
fi

if [ -n "`which arch | grep -v not\ found`" ]; then
   export ARCH=`arch`
fi
if [ -n "`which uname | grep -v not\ found`" ]; then
   export OSNAME=`uname -s`
fi

if [ -f "$HOME/.aliases.sh" ]; then
  . "$HOME/.aliases.sh"
fi

alias dir="ls -lstr"
if [ "$OSNAME" = "Linux" ]; then
   alias dir="ls --color=tty -lstr"
fi

Rd() { cvs -d `cat $@/CVS/Root` release -d $@ }

READNULLCMD=""

. $HOME/.addpath.sh

if [ -f $HOME/.localenv.sh ]; then
  . $HOME/.localenv.sh
fi

### Lab Specific Stuff

export LAB="SYS_LAB"

if [ -f /opt/boxen/env.sh ]; then
  . /opt/boxen/env.sh
fi

TEMPLATEQUOTE

if [ "$SYS_LAB" = 'UGCS' ]; then
  cat <<\TEMPLATEQUOTE
   autoload g gale_private gale_public gwrite message message_cleanup z zephyr_private zephyr_public zwe
   alias w="uptime; hoo -m `uname -n`"
   alias zwrite="zwe"
   alias zf="zfixed wtanaka"
   alias w="uptime; hoo -m $HOST"
   alias vf="~granny/bin/vf"
   alias lpr="print"
   alias lpq="lpstat"
   alias ls="gls -F"
   alias leastload="hoo|tail +3|guniq -w 9|cut -c11-22|sort|uniq -c|sort -nr"
   export ARCH=`/usr/ug/bin/arch`
   export SCREENDIR=/ug/tmp/wtanaka/screen
#      LaTeX stuff
   export TEXINPUTS=.:/home/mid/tex/inputs//:/usr/ug/lib/texmf/tex//:/home/mid/tex/latex/contrib/other//
#      export TEXFONTS=.:/home/mid/tex/fonts//tfm:/usr/ug/lib/texmf/fonts//tfm
   export TEXFORMATS=.:/home/mid/tex/formats:/usr/ug/lib/texmf/ini:/usr/ug/share/tex-6.2/lib/texmf/ini/
#      export DVIPSFONTS=/home/mid/tex/fonts//
#      export XDVIFONTS=/home/mid/tex/fonts//
   export MOZILLA_HOME="/usr/ug/${ARCH}/netscape-4.03"
   if [[ $TERM == screen ]]; then
      export TERM=vt100
   fi
   if [[ $ARCH == irix* ]]; then
#     export SGI_ABI=-n32
      export PATH="/usr/ug/bin:/bin:/usr/bin:/usr/bsd:/usr/sbin:/etc:/usr/etc:/usr/contrib/bin:/home/wtanaka/bin:/home/cs3/bin:/home/wtanaka/cs2/bin:$FPATH"
      export LD_LIBRARYN32_PATH=/usr/lib32:/lib32
      export LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:/usr/ug/lib:/home/cs1/lib/${ARCH}
      export JAVA_HOME=/usr/ug/irix6/jdk
      #alias avida="~charles/avida.prim.sgi"
      #alias avida="~wtanaka/tmp/avida/avida-0.1b/avida/avida.irix6"
      alias uptime="/usr/bsd/uptime"
      alias xanim="~tots/jk/irix6/bin/xanim"
   elif [[ $ARCH == hp* ]]; then
      #alias avida="~wtanaka/tmp/avida/avida-0.1b/avida/avida"
      alias avida="echo Warning, this is avida 0.4b|figlet; sleep 1; /home/cns175/bin/hp9000s700/avida-0.4b"
   fi
   addpath "/home/cs1/bin/$ARCH" "/home/cs1/bin/scripts" "/usr/X11R6/bin"
TEMPLATEQUOTE
fi

cat <<\TEMPLATEQUOTE
make_commands_reset_terminal_title()
{
   for i in "$@"; do
      eval "$i() { command $i \"\$@\" ; resetterminaltitle }"
   done
}
if [ ! "$TERM" = "linux" -a ! "$XTERMTYPE" = "utility" ]; then
   make_commands_reset_terminal_title ssh telnet rlogin pine vim screen su torify
fi

unfunction make_commands_reset_terminal_title

eval 'resetterminaltitle() { if [[ -z "$NOSETTERMINALNAME" && -o interactive ]]; then terminalname "'`uname -n`!`whoami`'"; terminaltitle "'`uname -n`!`whoami` '('`uname -s` `uname -r`') ('`tty`')"; fi }'
TEMPLATEQUOTE
