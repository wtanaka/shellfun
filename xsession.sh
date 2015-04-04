cat <<\TEMPLATEQUOTE
#!/bin/sh
eval `xdpyinfo | \
   awk '/vendor string:/ { print "VENDOR="$3 }
   /dimensions:/ { split($2,a,"x");print "XSIZE="a[1]";YSIZE="a[2] }
   /resolution:/ { split($2,a,"x");print "XRES="a[1]";YRES="a[2] }
   /depth of root window:/ { print "DEPTH="$5;exit }'` 

if [ -n "`ssh-add -l 2>&1 | grep -i \"could not.*connect\"`" ]; then
  TMPFILE="/tmp/ssh-agent-list$$"
  eval `ssh-agent` 2>&1 > "$TMPFILE"
  cat "$TMPFILE" 2>&1 | cut -d\  -f3 | sed -e "s/$/ $$/" \
     >> $HOME/.ssh/agentlist-`hostname`
  /bin/rm "$TMPFILE"
  ssh-add < /dev/null
fi

xset +dpms
TEMPLATEQUOTE

if [ "$SYS_LAB" = 'UGCS' ]; then
   cat <<\TEMPLATEQUOTE
xset m 10 3
TEMPLATEQUOTE
elif [ "$SYS_HOST" = 'spica.mili.eu.org' ]; then
   cat <<\TEMPLATEQUOTE
xset m 6 4
TEMPLATEQUOTE
elif [ "$SYS_LAB" = 'CS' ]; then
   cat <<\TEMPLATEQUOTE
xset m 8 4
TEMPLATEQUOTE
else
   cat <<\TEMPLATEQUOTE
xset m 6 4
TEMPLATEQUOTE
fi

cat <<\TEMPLATEQUOTE
xset fp+ /usr/ug/share/X11R6.1/lib/fonts/freefont/
xset fp+ /usr/ug/share/X11R6.1/lib/fonts/sharefont/
#xset fp+ tcp/mili.eu.org:7100
#xset fp+ inet/mili.eu.org:7101
#xset fp+ tcp/auto.ugcs.caltech.edu:7100

xrdb -merge $HOME/.Xresources

if [ "`uname`" = "Linux" ]; then
   xmodmap -e "keycode 22 = BackSpace" -e "keycode 107 = Delete"
fi

if [ -r "$HOME/etc/latlon" ]; then
  . "$HOME/etc/latlon"
fi

if [ -r "$HOME/bin/rootwindows" ]; then
  eval "`fortune $HOME/bin/rootwindows`"
elif which xplanet 2> /dev/null; then
  nice xplanet -config $HOME/.xplanet -wait 300 -labelpos +15+15 -latitude "$LATITUDE" -longitude "$LONGITUDE" &
elif which xearth 2> /dev/null; then
  xearth -pos 34.08 -118.08 &
elif which xplanetbg 2> /dev/null; then
  nice -20 xplanetbg -nice 19 -wait 300 -fuzz 20 -image day_clouds.png  -labelpos +15+15 -latitude 34.08 -longitude -118.08 -night_image night_clouds.png -projection orthographic
else
  xearth &
fi

fvwm2 &

xscreensaver &

if [ "`uname`" = "Linux" ]; then
  xset m 4 4
fi

xset r rate 400 60

xdaliclock -geometry 119x20-0+0
kill "$SSH_AGENT_PID"
TEMPLATEQUOTE
