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

shkill()
{
   if [ -f "$1" ]; then
      env SYS_HOST="$SYS_HOST" SYS_OS="$SYS_OS" SYS_OSVER="$SYS_OSVER" \
         SYS_TMP_DOMAINNAME="$SYS_TMP_DOMAINNAME" \
         RANDOM_SHELL="$RANDOM_SHELL" \
         sh "$1" > "$2"
   else
      echo missing "$1"
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
SYS_TMP_DOMAINNAME="(none)"
if [ -x /bin/domainname ]; then
   SYS_TMP_DOMAINNAME="`/bin/domainname`"
fi
RANDOM_SHELL='xterm'

if [ ! -d "$HOME/bin" ]; then
  mkdir "$HOME/bin"
fi

if [ ! -d "$HOME/etc" ]; then
  mkdir "$HOME/etc"
fi

catkill addpath.sh "$HOME/.addpath.sh"
# non-login interactive shells
catkill bashrc "$HOME/.bashrc"
# login interactive shells
catkill bashrc "$HOME/.bash_profile"
catkill allenv.sh "$HOME/.allenv.sh"
catkill aliases.sh "$HOME/.aliases.sh"
shkill zshenv.sh "$HOME/.zshenv"
shkill zshrc.sh "$HOME/.zshrc"
shkill zlogin.sh "$HOME/.zlogin"
shkill zlogout.sh "$HOME/.zlogout"
shkill xsession.sh "$HOME/.xsession"
shkill xresources.sh "$HOME/.Xresources"
catkill xdefaults "$HOME/.Xdefaults"
catkill gitconfig "$HOME/.gitconfig"
shkill vimrc.sh "$HOME/.vimrc"
if [ ! -e "$HOME/.wgetrc" ]; then
  catkill wgetrc "$HOME/.wgetrc"
fi
catkill screenrc "$HOME/.screenrc"
catkill tmux.conf "$HOME/.tmux.conf"
catkill dalifonts "$HOME/etc/dalifonts"
catkill quiltrc "$HOME/.quiltrc"
catkill quotes "$HOME/etc/quotes"
catkill d "$HOME/bin/d"
chmod a+x "$HOME/bin/d"
catkill newmoz "$HOME/bin/newmoz"
chmod a+x "$HOME/bin/newmoz"
catkill urlencode "$HOME/bin/urlencode"
chmod a+x "$HOME/bin/urlencode"
catkill urlfor "$HOME/bin/urlfor"
chmod a+x "$HOME/bin/urlfor"
catkill indent.pro "$HOME/.indent.pro"
catkill pydistutils.cfg "$HOME/.pydistutils.cfg"
(cd $HOME/etc ; 2>&1 strfile -r dalifonts dalifonts.dat) > /dev/null
(cd $HOME/etc ; 2>&1 strfile -r quotes quotes.dat) > /dev/null

shkill fvwm2rc.sh "$HOME/.fvwm2rc"
shkill fvwmrc.sh "$HOME/.fvwmrc"

if [ ! -d "$HOME/.ssh" ]; then
   mkdir "$HOME/.ssh"
fi
cp ssh.killagents "$HOME/.ssh/killagents"
ifrm ssh.killagents

crontab crontab
ifrm crontab
ifrm crontab~

shkill x.sh "$HOME/bin/x"
chmod a+x "$HOME/bin/x"
catkill genser "$HOME/bin/genser"
chmod a+x "$HOME/bin/genser"

ifrm gen~ 
ifrm x~

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
