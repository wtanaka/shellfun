include(functions.m4)dnl
include(init.m4)dnl
changequote({{, }})dnl
#!/bin/sh
{{
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
}}
ifelse(SYS_LAB, {{UGCS}}, {{xset m 10 3}},
       SYS_HOST, {{spica.mili.eu.org}}, {{xset m 6 4}},
       SYS_LAB, {{CS}}, {{xset m 8 4}},
       SYS_HOST, {{concombre.dabney.caltech.edu}}, {{xset m 5 4}})
xset fp+ /usr/ug/share/X11R6.1/lib/fonts/freefont/
xset fp+ /usr/ug/share/X11R6.1/lib/fonts/sharefont/
#xset fp+ tcp/mili.eu.org:7100
#xset fp+ inet/mili.eu.org:7101
#xset fp+ tcp/auto.ugcs.caltech.edu:7100
xrdb ifelse(SYS_LAB, {{UGCS}}, {{-load}}, {{-merge}}) $HOME/.Xresources
if [ "`uname`" = "Linux" ]; then
   xmodmap -e "keycode 22 = BackSpace" -e "keycode 107 = Delete"
fi

ifelse(SYS_LAB, {{UGCS}}, {{eval "`fortune $HOME/bin/rootwindows`"}},
       SYS_LAB, {{CS}}, {{xearth -pos 34.08 -118.08}},
       SYS_HOST, {{altair.mili.eu.org}}, {{nice -20 xplanetbg -nice 19 -wait 300 -fuzz 20 -image day_clouds.png  -labelpos +15+15 -latitude 34.08 -longitude -118.08 -night_image night_clouds.png -projection orthographic}},
       {{xearth}}) &

ifelse(SYS_LAB, {{UGCS}}, {{}},
       SYS_HOST, {{smonger}}, {{xmailbox & xload -geometry 30x40+60+20 &}},
       SYS_HOST, {{lard}}, {{xbiff -geometry +0+20 & xload -geometry 85x48+48+20 &}}
       )

ifelse(SYS_LAB, {{UGCS}}, 
{{xterm -fg "#77aaee" -bg black -geometry 80x50+0+0 & 
}},
SYS_HOST, {{altair.mili.eu.org}}, 
{{xterm -fg "#bbddff" -bg black -geometry 80x50+0+0 & 
}})dnl
ifelse(SYS_LAB, {{UGCS}}, 
{{xterm -fg "#88eeaa" -bg black -geometry 80x43+490+100 & 
}},
SYS_HOST, {{altair.mili.eu.org}}, 
{{xterm -fg "#bbffdd" -bg black -geometry 80x50+490+0 & 
}})dnl
ifelse(SYS_LAB, {{UGCS}}, 
{{xterm -fg "#ee88aa" -bg black -geometry 80x25+0-0 & 
}},
SYS_HOST, {{altair.mili.eu.org}}, 
{{xterm -fg "#ffbbdd" -bg black -geometry 80x45+0-0 & 
}})dnl

ifelse(SYS_LAB, {{UGCS}}, {{fvwm & 4va -s50 `fortune 4vafiles` -geometry150x150+`expr $XSIZE - 150`+`expr $YSIZE - 150` &}},
       SYS_HOST, {{lard}}, {{fvwm &}},
{{fvwm2 &}}
)

ifelse(SYS_HOST, {{altair.mili.eu.org}}, {{xset s 120}},
       {{xscreensaver &}})

if [ "`uname`" = "Linux" ]; then
  xset m 4 4
fi

xset r rate 400 60

xdaliclock -geometry 119x20-0+0
kill "$SSH_AGENT_PID"
