#!/bin/sh
#
# Shell Fun - Shell Tools for UNIX
# ns.cgi - This script is a handler for netscape's network.search.url
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


#echo Content-type: text/plain
#echo

#echo Default Behavior:
#echo Location: http://keyword.netscape.com/$QUERY_STRING

forwardto()
{
   echo "Location: $@"
   echo
}

urldecode()
{
   sed \
      -e 's/%2F/\//g'
}

#echo Infoseek with my own keywords:
case $QUERY_STRING in
   dnshelp/*)
      DNS=`echo $QUERY_STRING | cut -c9-`
      echo "Location: http://www.google.com/search?q=$DNS"
      ;;
   [Kk][Ee][Yy][Ww][Oo][Rr][Dd][/=]-%20*)
      KEYWORD=`echo $QUERY_STRING | cut -c13- | tr A-Z a-z`
      ORIGKEYWORD=`echo $QUERY_STRING | cut -c13-`
      ;;
   [Kk][Ee][Yy][Ww][Oo][Rr][Dd][/=]%[0-9A-F][0-9A-F]%20*)
      KEYWORD=`echo $QUERY_STRING | cut -c15- | tr A-Z a-z`
      ORIGKEYWORD=`echo $QUERY_STRING | cut -c15-`
      ;;
   [Kk][Ee][Yy][Ww][Oo][Rr][Dd][/=]*)
      KEYWORD=`echo $QUERY_STRING | cut -c9- | tr A-Z a-z`
      ORIGKEYWORD=`echo $QUERY_STRING | cut -c9-`
      ;;
esac

case "${KEYWORD}" in
   # re-search
   dict%20*) forwardto "http://m-w.com./cgi-bin/dictionary?va=`echo ${ORIGKEYWORD} | cut -c8-`" ;;
   thes%20*) forwardto "http://m-w.com./cgi-bin/thesaurus?va=`echo ${ORIGKEYWORD} | cut -c8-`" ;;
   caltech%20*) forwardto "http://www.search.caltech.edu/CIT_Search/action.lasso?-database=CIT_Search&-noResults=/CIT_Search/No_Result_Found.html&-response=/CIT_Search/Hit_List_CIT_Search.html&-layout=Search_Layout&-maxRecords=100&Search_Field=`echo ${ORIGKEYWORD} | cut -c11-`&-search" ;;
   map%20*) %2F
      ARG=`echo ${ORIGKEYWORD} | cut -c7- | urldecode`
      ADDR=`echo ${ARG} | cut -d\/ -f1`
      CSZ=`echo ${ARG} | cut -d\/ -f2`
      forwardto "http://maps.yahoo.com/py/maps.py?Pyt=Tmap&addr=$ADDR&csz=$CSZ&country=us&Get%A0Map=Get+Map"
      ;;
#   java%20lang*%20spec*) echo Location: http://java.sun.com./docs/books/jls/html/index.html ;;
#   servlet%20api) echo Location: http://www.javasoft.com/products/servlet/2.1/api/packages.html ;;
#   jtextarea) echo Location: http://java.sun.com/products/jfc/swingdoc-api-1.1/javax/swing/JTextArea.html ;;
#   joptionpane) echo Location: http://java.sun.com/products/jfc/swingdoc-api-1.1/javax/swing/JOptionPane.html ;;
#   maps*yahoo) echo 'Location: http://maps.yahoo.com/' ;;
#   yahoo%20inbox) echo 'Location: http://f1.mail.yahoo.com/ym/us/ShowFolder?rb=Inbox' ;;
#   caltech*credit*union) echo Location: http://www.caltech.edu/~cefcu/ ;;
#   rpmfind) echo Location: http://rpmfind.net/linux/rpm2html/rpmfind.html ;;
#   my%20netscape) echo Location: http://my.netscape.com/ ;;
#   cvs%20bubbles) echo Location: http://www.loria.fr/%7Emolli/cvs-index.html ;;
#   pike) echo Location: http://pike.idonex.se/ ;;
#   soar) echo Location: http://soar.berkeley.edu/recipes/ ;;
   mail%20*) forwardto "http://f1.mail.yahoo.com/py/ymTo.py?&To=`echo ${ORIGKEYWORD} | cut -c8-`" ;;
#   c%2b%2bstandard) echo Location: http://www.cygnus.com/misc/wp/nov97/ ;;
#   md5%20rfc) echo Location: http://www.cis.ohio-state.edu/htbin/rfc/rfc1321.html ;;
#   yahoo%20mail|email|mail) echo Location: http://mail.yahoo.com/ ;;
#                    html%20spefi*|html%20reference|html%20spec*|html%204%20spec|html%204%20specification) echo Location: http://www.w3.org/TR/REC-html40/ ;;
#                       xscreensaver) echo Location: http://www.jwz.org/xscreensaver/ ;;
#                       cvs) echo Location: http://www.loria.fr/~molli/cvs-index.html ;;
#                       musixtex|mutex|musictex) echo Location: http://www.gmd.de/Misc/Music/ ;;
#                       rfc%20*) echo Location: http://www.cis.ohio-state.edu/htbin/rfc/${KEYWORD}.html | sed -e 's/%20//' ;;
#                       rfc*) echo Location: http://www.cis.ohio-state.edu/htbin/rfc/${KEYWORD}.html ;;
#                       altima) echo Location: http://www.altima.org./ ;;
#                       calendar) echo Location: http://calendar.yahoo.com/ ;;
#                    caltech%20postal%20service|caltech%20post%20office|mail%20services|caltech%20mail%20services) echo Location: http://www.caltech.edu/departmentdirectory/Mail_Services.html ;;
#                       academic%20calendar|caltech%20academic%20calendar) echo Location: 
#                    http://www.caltech.edu/acalendar ;;
#                       cdnow) echo Location: http://www.cdnow.com./ ;;
#                       cs1%20grades|cs%201%20grades) echo Location: 
#                    http://www.ugcs.caltech.edu/~cs1/status ;;
#                       cs1status|cs%201%20status|cs1%20status|cs%201status) echo Location: 
#                    http://www.ugcs.caltech.edu/~cs1/status ;;
#                       cs1%20section|cs%201%20section) echo Location: 
#                    http://www.ugcs.caltech.edu/~cs1/sections#8b ;;
#                       cs141|cs%20141) echo Location: http://www.cs.caltech.edu./~cs141/ ;;
#                       cs1|cs%201) echo Location: http://www.ugcs.caltech.edu/~cs1/ ;;
#                       cs2|cs%202) echo Location: http://www.ugcs.caltech.edu/~cs2/ ;;
#                       cs3|cs%203) echo Location: http://www.ugcs.caltech.edu/~cs3/ ;;
#                       cs286|cs%20286) echo Location: 
#                    http://www.vision.caltech.edu./bond/coursegs.html ;;
#                       esound) echo Location: http://www.tux.org/~ricdude/EsounD.html ;;
#                       eterm) echo Location: http://www.tcserv.com./Eterm/ ;;
#                       freshmeat) echo Location: http://www.freshmeat.net./ ;;
#                       gale%20log) echo Location: http://www.ugcs.caltech.edu./~jtr/gale/log/ ;;
#                       gale) echo Location: http://www.gale.org./ ;;
#                       gimp) echo Location: http://www.gimp.org./ ;;
#                       gnome) echo Location: http://www.gnome.org./ ;;
#                       guavac) echo Location: 
#                    ftp://ftp.yggdrasil.com/pub/dist/devel/compilers/guavac ;;
#                       javax%20swing*) echo Location: 
#                    http://java.sun.com./products/jdk/1.2/docs/api/${ORIGKEYWORD}.html | sed -e 
#                    's/%20/\//g' ;;
#                       javax%20servlet*) echo Location: 
#                    http://jserv.javasoft.com/products/java-server/documentation/webserver1.0.2/apidoc/${ORIGKEYWORD}.html 
#                    | sed -e 's/%20/./g' ;;
#                       java%202%20api) echo Location: 
#                    http://java.sun.com./products/jdk/1.2/docs/api/index.html ;;
#                       java%201.0%20api|java1.0api|"java 1.0 api"|"java 1.0.2 
#                    api"|java%201.0.2%20api) echo Location: http://java.sun.com./products/jdk/1.0.2/api/ ;;
#                       java%201.2%20api) echo Location: 
#                    http://java.sun.com./products/jdk/1.2/docs/api/index.html ;;
#                       java%20api) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/packages.html ;;
#                       java%201.1%20api) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/packages.html ;;
#                       java%20awt%20event) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/Package-java.awt.event.html ;;
#                       java%20awt) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/Package-java.awt.html ;;
#                       java%20util) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/Package-java.util.html ;;
#                       java%20util%20zip) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/Package-java.util.zip.html ;;
#                       java%20rmi) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/Package-java.rmi.html ;;
#                       java%20lang) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/Package-java.lang.html ;;
#                       java%20net) echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/Package-java.net.html ;;
#                       
#                    java%20applet%20*|java%20awt%20*|java%20awt%20datatransfer%20*|java%20awt%20event%20*|java%20awt%20image%20*|java%20beans%20*|java%20io%20*|java%20lang%20*|java%20lang%20reflect%20*|java%20math%20*|java%20net%20*|java%20rmi%20*|java%20rmi%20dgc%20*|java%20rmi%20registry%20*|java%20rmi%20server%20*|java%20security%20*|java%20security%20acl%20*|java%20security%20interfaces%20*|java%20sql%20*|java%20text%20*|java%20util%20*|java%20util%20zip%20*) 
#                    echo Location: 
#                    http://java.sun.com./products/jdk/1.1/docs/api/${ORIGKEYWORD}.html#_top_ | sed -e 's/%20/./g' ;;
#                       gridlayout) echo Location: 
#                    http://java.sun.com./products/jdk/1.2/docs/api/java/awt/GridLayout.html ;;
#                       gridbaglayout) echo Location: 
#                    http://java.sun.com./products/jdk/1.2/docs/api/java/awt/GridBagLayout.html ;;
#                       jtextcomponent) echo Location: 
#                    http://java.sun.com/products/jfc/swingdoc-api-1.1/javax/swing/text/JTextComponent.html 
#                    ;;
#                       jcomponent) echo Location: 
#                    http://java.sun.com/products/jfc/swingdoc-api-1.1/javax/swing/JComponent.html 
#                    ;;
#                       jtable%20tutorial) echo Location: 
#                    http://java.sun.com./docs/books/tutorial/ui/swing/table.html ;;
#                       me115|me115a|me%20115a|me%20115) echo Location: 
#                    http://robby.caltech.edu./~jwb/courses/ME115/ME115.html ;;
#                       mediafind) echo Location: http://194.95.209.6/ ;;
#                       mpi_recv) echo Location: 
#                    http://www.mcs.anl.gov/Projects/mpi/www/www3/MPI_Recv.html ;;
#                       mpi_send) echo Location: 
#                    http://www.idiap.ch./~bornet/docs/mpiwww/www3/MPI_Send.html ;;
#                       netwatch) echo Location: ftp://ftp.slctech.org./pub/ ;;
#                       nautilus) echo Location: http://www.lila.com/nautilus/ ;;
#                       praya) echo Location: http://praya.netpedia.net./ ;;
#                       python) echo Location: http://www.python.org./ ;;
#                       qmail) echo Location: http://www.qmail.org./top.html ;;
#                       replay) echo Location: http://replay.linuxpower.org./ ;;
#                       robocup) echo Location: http://www.csl.sony.co.jp./RoboCup/New/ ;;
#                       scour) echo Location: http://www.scour.net/ ;;
#                       snarf) echo Location: http://xach.dorknet.com./snarf/ ;;
#                       soccer%20server) echo Location: 
#                    http://ci.etl.go.jp./~noda/soccer/server/index.html ;;
#                       spk) echo Location: ftp://screech.alfred.edu./pub/spk/ ;;
#                       swing%20api) echo Location: 
#                    http://java.sun.com./products/jfc/swingdoc-api/index.html ;;
#                       swing%20connection) echo Location: http://java.sun.com./products/jfc/tsc/ ;;
#                       swing%20tutorial) echo Location: 
#                    http://java.sun.com./docs/books/tutorial/ui/swing/index.html ;;
#                       vim) echo Location: http://www.vim.org./ ;;
#                       webster) echo Location: http://www.m-w.com./ ;;
#                       wm2) echo Location: http://www.all-day-breakfast.com/wm2/ ;;
#                       wmx) echo Location: http://www.all-day-breakfast.com/wmx/ ;;
#                       #imdbc%20*) echo Location: http:
#                       x11amp) echo Location: http://x11amp.org/ ;;
#                       yahoo|my|myyahoo|my%20yahoo) echo Location: http://my.yahoo.com/ ;;
   %2b*)
      forwardto "http://www.google.com./search?q=$ORIGKEYWORD"
      ;;
   *%20*)
      forwardto "http://www.google.com./search?q=$ORIGKEYWORD"
      ;;
   *)
      forwardto "http://www.$ORIGKEYWORD.com"
      #if grep -i ${KEYWORD} list; then
         #echo Location: http://keyword.netscape.com./keyword/${ORIGKEYWORD}
      #else
         #echo "Location: http://www.$ORIGKEYWORD.com"
      #fi
      ;;
esac
