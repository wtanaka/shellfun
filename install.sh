#!/bin/sh
# Shellfun http://shellfun.sf.net/
# 
# Copyright (C) 2000-2014 Wesley Tanaka http://wtanaka.com/
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# This script installs files into their proper locations

ifrm()
{
   :
   #if [ -f "$1" ]; then rm "$1"; fi
}

m4kill()
{
   if [ -f "$1" ]; then
      m4 -DSYS_HOST="$SYS_HOST" -DSYS_OS="$SYS_OS" -DSYS_OSVER="$SYS_OSVER" \
         -DORIG_SYS_LAB="$LAB" -DSYS_TMP_DOMAINNAME="$SYS_TMP_DOMAINNAME" \
         "$1" > "$2"
   fi
   ifrm "$1"
	ifrm "$1~"
}

catkill()
{
   if [ -f "$1" ]; then
      cat "$1" > "$2"
   fi
   ifrm "$1"
   ifrm "$1~"
}

SYS_HOST="`uname -n`"
SYS_OS="`uname -s`"
SYS_OSVER="`uname -r`"
SYS_TMP_DOMAINNAME="`/bin/domainname`"

if [ ! -d "$HOME/bin" ]; then
  mkdir "$HOME/bin"
fi

if [ ! -d "$HOME/etc" ]; then
  mkdir "$HOME/etc"
fi

m4kill addpath.sh.m4 "$HOME/.addpath.sh"
# non-login interactive shells
m4kill bashrc.m4 "$HOME/.bashrc"
# login interactive shells
m4kill bashrc.m4 "$HOME/.bash_profile"
m4kill zshenv.m4 "$HOME/.zshenv"
m4kill zshrc.m4 "$HOME/.zshrc"
m4kill zlogin.m4 "$HOME/.zlogin"
m4kill zlogout.m4 "$HOME/.zlogout"
m4kill xsession.m4 "$HOME/.xsession"
m4kill xresources.m4 "$HOME/.Xresources"
m4kill xdefaults.m4 "$HOME/.Xdefaults"
m4kill vimrc.m4 "$HOME/.vimrc"
if [ ! -e "$HOME/.wgetrc" ]; then
  m4kill wgetrc.m4 "$HOME/.wgetrc"
fi
catkill screenrc "$HOME/.screenrc"
catkill dalifonts "$HOME/etc/dalifonts"
catkill quotes "$HOME/etc/quotes"
catkill d "$HOME/bin/d"
chmod a+x "$HOME/bin/d"
catkill newmoz "$HOME/bin/newmoz"
chmod a+x "$HOME/bin/newmoz"
catkill urlencode "$HOME/bin/urlencode"
chmod a+x "$HOME/bin/urlencode"
catkill indent.pro "$HOME/.indent.pro"
(cd $HOME/etc ; 2>&1 strfile -r dalifonts dalifonts.dat) > /dev/null
(cd $HOME/etc ; 2>&1 strfile -r quotes quotes.dat) > /dev/null

fvwm2as1()
{
   m4kill fvwm2rc.m4 "$HOME/.fvwmrc"
}

fvwm2()
{
   m4kill fvwm2rc.m4 "$HOME/.fvwm2rc"
}

fvwm()
{
   m4kill fvwmrc.m4 "$HOME/.fvwmrc"
}

case "$LAB" in
   UGCS) fvwm2as1 ;;
   CS) fvwm2; fvwm ;;
   DABNEY) fvwm2; fvwm ;;
   *)
      case "$SYS_HOST" in
         concombre.*|concombre) fvwm2 ;;
         lard.*|lard) fvwm ;;
         *) fvwm2; fvwm ;;
      esac
   ;;
esac
m4kill fvwmrc.m4 "/dev/null"
m4kill fvwm2rc.m4 "/dev/null"

if [ ! -d "$HOME/.ssh" ]; then
   mkdir "$HOME/.ssh"
fi
cp ssh.killagents "$HOME/.ssh/killagents"
ifrm ssh.killagents

crontab crontab
ifrm crontab
ifrm crontab~

m4kill x.m4 "$HOME/bin/x"
chmod a+x "$HOME/bin/x"
catkill genser "$HOME/bin/genser"
chmod a+x "$HOME/bin/genser"

ifrm functions.m4 
ifrm init.m4 
ifrm gen~ 
ifrm functions.m4~ 
ifrm init.m4~
ifrm x~
ifrm shells.m4
ifrm shells.m4~

if [ -f "$HOME/.netscape/preferences.js" ]; then
  if 2>&1 grep network.search.url "$HOME/.netscape/preferences.js" >/dev/null; then
    :
  else
    echo 'user_pref("network.search.url", "http://shellfun.sourceforge.net./cgi-bin/ns?");' >> $HOME/.netscape/preferences.js
  fi
fi


if [ -f "$HOME"/.mozilla/*/*/prefs.js ]; then
  if 2>&1 grep keyword.URL "$HOME"/.mozilla/*/*/prefs.js >/dev/null; then
    :
  else
    for i in "$HOME"/.mozilla/*/*/prefs.js; do
       echo 'user_pref("keyword.URL", "http://shellfun.sourceforge.net./cgi-bin/ns?keyword=");' >> "$i"
    done
  fi
fi

if [ -f "$HOME/.mozilla/wtanaka/"*"/prefs.js" ]; then
  if 2>&1 grep dom.disable_open_during_load "$HOME/.mozilla/wtanaka/"*"/prefs.js" >/dev/null; then
    :
  else
    for i in $HOME/.mozilla/wtanaka/*/prefs.js; do
       echo 'user_pref("dom.disable_open_during_load", true);' >> "$i"
    done
  fi
fi
#exec rm gen
