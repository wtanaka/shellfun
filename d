#!/bin/sh
# Shell Fun - Shell Tools for UNIX
# d - This script is a shortcut for displaying files.
# 
# Copyright (C) 2000 Wesley Tanaka
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
# USA.

urlencode()
{
   sed -e 's/ /%20/g'
}

urlfor()
{
   #if [ -z "$hostname" ]; then
      #hostname="`uname -n`"
   #fi
   for i
   do
      dirname="`dirname \"$i\"`"
      filename="`basename \"$i\"`"
      case "$dirname" in
         /*) URLFOR="file:$dirname/$filename" ;;
         *) URLFOR="file:`pwd`/$dirname/$filename" ;;
      esac
   done
   URLFOR="`echo $URLFOR | urlencode`"
}

snes()
{
   xset s off
   xset -dpms
   zsnes "$1"
   #|| gsnes9x -y -fs -joymap1 2 1 5 4 6 7 8 10 -joymap2 2 1 5 4 6 7 8 10 -hires "$1"
   xset s 120
   xset +dpms
}

nes()
{
   xset s off
   xset -dpms
   xmess nes -scale 2 -spooldir ~/.xmess/spool -joytype 4 \
      -sound -x11-mode 0 "$1"
   xset s 120
   xset +dpms
}

# netscape seems to set this, acroread is unhappy with it.
LD_PRELOAD=""
export LD_PRELOAD

for i in "$@"; do
   #echo displaying "$i"
   date=`date | cut -c12-19`
   ext=`basename "$i" | cut -d. -f2-`
   newfile="$date"."$ext"
   if [ -r "$i" ]; then
      case "$i" in
         *.[wW][aA][vV].gz)
            FILEINFO="`zcat \"$i\" | file -`"
            case "$FILEINFO" in
               *mono*) zcat "$i" | sox -t wav - -t sw -r 11025 - | esdcat -m -r 11025 ;;
               *) zcat "$i" | sox -t wav - -t sw -r 11025 - | esdcat -r 11025 ;;
            esac
         ;;
         # zip
         *.[Zz][Ii][Pp])
            if unzip -l "$i" | grep -i '\.smc$' > /dev/null 2>&1 ; then
               snes "$i"
            elif unzip -l "$i" | grep -i '\.sfc$' > /dev/null 2>&1 ; then
               snes "$i"
            elif unzip -l "$i" | grep -i '\.fig$' > /dev/null 2>&1 ; then
               snes "$i"
            elif unzip -l "$i" | grep -i '\.nes$' > /dev/null 2>&1 ; then
               nes "$i"
            else
               unzip -l "$i"
            fi
         ;;
         *.gz)
            len=`echo ${#ext}-3 | bc`
            preext=`echo $ext | cut -c-$len`
            cp "$i" /tmp/"$newfile"
            pushd /tmp > /dev/null
            gunzip "$newfile"
            #echo Looking for ${date}.${preext}
            if [ -r ${date}.${preext} ]; then
               #echo Uncompressing $i
               $0 "${date}.${preext}"
               rm -f ${date}.${preext}
            fi
            popd > /dev/null
         ;;
         # smc
         *.[Ss][Mm][Cc])
            snes "$i"
         ;;
         # nes
         *.[Nn][Ee][Ss])
            nes "$i"
         ;;
         # gb/gbc
         *.[Gg][Bb]|*.[Gg][Bb][Cc])
            xset s off
            xset -dpms
            xgnuboy "$i"
            xset s 120
            xset +dpms
         ;;
         # smd
         *.[Ss][Mm][Dd])
            xset s off
            xset -dpms
            dgen -n 1 -f -j "$i"
            xset s 120
            xset +dpms
         ;;
         *.tex)
            cp "$i" /tmp/"$date".tex
            pushd /tmp > /dev/null
            tex "$date".tex
            if [ -r "$date".dvi ]; then
               $0 "$date".dvi
               rm -f "$date".*
            fi
            popd > /dev/null
         ;;
         *.latex)
            cp "$i" /tmp/"$date".latex
            pushd /tmp > /dev/null
            latex "$date".latex
            if [ -r "$date".dvi ]; then
               $0 "$date".dvi
               rm -f "$date".*
            fi
            popd > /dev/null
         ;;
         *.dvi)
            xdvi $i 
         ;;
         # mid, midi
         *.[mM][iI][dD]|*.[mM][iI][dD][iI])
            timidity "$i" || playmidi "$i"
         ;;
         *.mod)
            s3mod $i
         ;;
         # it
         *.[Ii][Tt])
            mikmod "$i"
         ;;
         # s3m
         *.[Ss]3[Mm])
            xmp $i || s3mod $i
         ;;
         # wav
         *.[wW][aA][vV])
            FILEINFO="`file \"$i\"`"
            play "$i" || esdcat "$i"
#            case "$FILEINFO" in
#               *mono*) sox -t wav "$i" -t sw -r 11025 - | esdcat -m -r 11025 ;;
#               *) sox -t wav "$i" -t sw -r 11025 - | esdcat -r 11025 ;;
#            esac
         ;;
         # rm, ra, ram
         *.[Rr][Aa]|*.[Rr][Mm]|*.[Rr][Aa][Mm])
            realplay "$i" || rvplayer "$i"
         ;;
         # xwd, bmp, png, jpg, jpeg, gif, xpm, tga
         *.[Xx][Ww][Dd]|*.[xX][pP][mM]|*.[bB][mM][pP]|*.[pP][nN][gG]|*.[jJ][pP][eE][gG]|*.[jJ][pP][gG]|*.[gG][iI][fF]|*.[Tt][Gg][Aa])
            if [ -n "$DISPLAY" ]; then
               ee "$i"  || xv "$i"
            elif [ "$TERM" = "linux" ]; then
               zgv "$i"
            else
               convert "$i" /tmp/"$i".ppm && aview /tmp/"$i".ppm
            fi
         ;;
         *.ps)
            ghostview $i
         ;;
         *.xcf|*.xcf.bz2|*.xcf.gz)
            gimp $i 
         ;;
         # mpg, mpeg
         *.[Mm][Pp][Gg]|*.[Mm][Pp][Ee][Gg])
            if which mtv 2>&1 > /dev/null && grep REGISTRATION $HOME/.mtvrc 2>&1 > /dev/null ; then
               MTVP_AUDIO_OSS_DELAY_METHOD=2 mtv -ac0 "$i"
            elif which mtvp 2>&1 > /dev/null; then
               MTVP_AUDIO_OSS_DELAY_METHOD=2 mtvp -ac0 "$i"
            else
               xanim +Ae +Ak +B +f +Sr +l0 "$i" 
            fi
         ;;
         # .asf, .avi
         *.[Aa][Ss][Ff]|*.[Aa][Vv][Ii])
            xmms "$i" || if which aviplay 2>&1 > /dev/null; then
               aviplay "$i"
            else
               xanim +Ae +Ak +B +f +Sr +l0 "$i" 
            fi
         ;;
         *.qt|*.mov)
            xanim +Ae +Ak +B +f +Sr +l0 "$i" 
         ;;
         *.pdf|*.[Pp][Dd][Ff]) # pdf files
            acroread "$i" || xpdf "$i" 
         ;;
         # .mp2 .mp3
         *.[mM][pP]2|*.[mM][pP]3)
            if [ -n "$DISPLAY" ]; then
               xmms "$i" || x11amp "$i"
            else
               FILEDATA="`mp3info -- \"$i\"`"
               echo "$i"
               echo "$FILEDATA"
               case "$FILEDATA" in
                  *single-ch*) mpg123 -b 50 -r 44100 -s -- "$i" | esdcat -m ;;
                  *j-stereo*) mpg123 -b 50 -r 44100 -s -- "$i" | esdcat ;;
                  *) mpg123 -b 50 -r 44100 -s -- "$i" | esdcat ;;
               esac
            fi
         ;;
         *.m3u)
            if [ -n "$DISPLAY" ]; then
               xmms "$i" || x11amp "$i"
            fi
         ;;
         *.au)
            FILEDATA="`file \"$i\"`"
            OIFS=$IFS; IFS=":" set -- $FILEDATA; IFS=$OIFS
            shift
            case "$@" in
               "Sun/NeXT audio data:"*8-bit*mono*) sox "$i" -c 1 -r 8000 -t ub - | esdcat -b -m -r 8000 ;;
               "Sun/NeXT audio data:"*16-bit*mono*) sox "$i" -c 1 -r 8000 -t sw - | esdcat -m -r 11025 ;;
               *) sox "$i" -c 1 -r 8000 -t ub - | esdcat -b -m -r 8000 ;;
            esac
            #sox "$i" -c 1 -r 11025 -t sw
            #play "$i"
         ;;
         *.asc)
            pgpv "$i" 
         ;;
         *.[0-9]|*.n|*.man|*.1x)
            if [ `echo \`file -L "$i"\` | cut -d\  -f2` = "troff" ]; then
               groff -s -p -t -e -Tascii -mandoc "$i" | less
            fi
         ;;
         *.info)
            info --file "$i"
         ;;
         *.html|*.htm)
            if [ -n "$DISPLAY" ]; then
               urlfor "$i"
               netscape -noraise -remote "openURL($URLFOR)" || netscape "$URLFOR"
            else
               lynx "$i"
            fi
         ;;
         *.uue)
            uudecode "$i"
         ;;
         *)
            file "$i" | cut -d: -f2
            echo File type ."$ext" not found.
         ;;
      esac
   else
      case "$i" in
         file://*|https://*|http://*|ftp://*|www.*|*.com|*.org|*.net)
            if which gnome-moz-remote; then
               gnome-moz-remote "$i"
            else
               netscape -noraise -remote "openURL($i)" || \
               netscape "$i" &
            fi
            ;;
         #*) echo "$i" not found or not readable. ;;
      esac
   fi
done
