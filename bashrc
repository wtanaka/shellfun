if [ -n "$PS1" ]; then
PS1='(\h) \t \w \$ '
fi
unset HISTFILE

addpath()
{
   for i; do
      if [ -d "$i" ]; then
         TOADD="$i"
         ADDME="y"
         OIFS=$IFS
         IFS=:
         for pathpart in $PATH; do
            if [ "$pathpart" = "$TOADD" ]; then
               ADDME="n"
            fi
         done
         IFS=$OIFS
         if [ "$ADDME" = "y" ]; then
            if [ -z "${PATH}" ]; then
               PATH="${TOADD}"
            else
               PATH="${PATH}:${TOADD}"
            fi
            export PATH
         fi
         unset ADDME
         unset OIFS
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
   :>"$FILENAME"
   OIFS="$IFS"; IFS=":"; for pathpart in $PATH; do
      echo "$pathpart" >> "$FILENAME"
   done; IFS="$OIFS"
   if [ -z "$VISUAL" ]; then
      vi "$FILENAME"
   else
      "$VISUAL" "$FILENAME"
   fi
   export PATH=""
   while read LINE; do
      if [ -d "$LINE" -o -f "$LINE" ]; then
         if [ -z "${PATH}" ]; then
            export PATH="${LINE}"
         else
            export PATH="${PATH}:${LINE}"
         fi
      fi
   done < "$FILENAME"
   rm -f "$FILENAME"
}

addclasspath()
{
   for i; do
      if [ -d "$i" -o -f "$i" ]; then
         TOADD="$i"
         ADDME="y"
         OIFS=$IFS
         IFS=:
         for i in $CLASSPATH; do
            if [ "$i" = "$TOADD" ]; then
               ADDME="n"
            fi
         done
         IFS=$OIFS
         if [ "$ADDME" = "y" ]; then
            if [ -z "${CLASSPATH}" ]; then
               CLASSPATH="${TOADD}"
            else
               CLASSPATH="${CLASSPATH}:${TOADD}"
            fi
            export CLASSPATH
         fi
         unset ADDME
         unset OIFS
      fi
   done
}

preclasspath()
{
   for i; do
      if [ -d "$i" -o -f "$i" ]; then
         TOADD="$i"
         ADDME="y"
         OIFS=$IFS
         IFS=:
         for i in $CLASSPATH; do
            if [ "$i" = "$TOADD" ]; then
               ADDME="n"
            fi
         done
         IFS=$OIFS
         if [ "$ADDME" = "y" ]; then
            if [ -z "${CLASSPATH}" ]; then
               CLASSPATH="${TOADD}"
            else
               CLASSPATH="${TOADD}:${CLASSPATH}"
            fi
            export CLASSPATH
         fi
         unset ADDME
         unset OIFS
      fi
   done
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


terminalname()
{
   echo -ne "\033]1;$*\007" 
}
terminalnametitle() 
{ 
   echo -ne "\033]0;$*\007" 
}
terminaltitlename() 
{ 
   echo -ne "\033]0;$*\007" 
}
terminaltitle() 
{
   echo -ne "\033]2;$*\007" 
}
netscape-newwindow() 
{ 
   netscape -noraise -remote "openURL($*,new-window)" 
}

umask 022
HISTSIZE=1000
if [ -f "$HOME/.allenv.sh" ]; then
  . "$HOME/.allenv.sh"
fi

if [ -f "$HOME/.aliases.sh" ]; then
  . "$HOME/.aliases.sh"
fi

eval 'resetterminaltitle()
{
if [ -z "$NOSETTERMINALNAME" -a -n "$PS1" ];
then terminalname "'`uname -n`!`whoami`'";
terminaltitle "'`uname -n`!`whoami` '('`uname -s` `uname -r`') ('`tty`')";
fi
}'

resetterminaltitle

set show-all-if-ambiguous On

. $HOME/.addpath.sh

if [ -f $HOME/.localenv.sh ]; then
  . $HOME/.localenv.sh
fi

