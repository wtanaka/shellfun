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
#echo

forwardto()
{
   echo "Location: $@"
   echo
}

printwebpage()
{
   echo "Content-type: text/plain"
   echo
   echo "$@"
   exit 0
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
   # re-search / fake command line
   google%20*) forwardto "http://www.google.com./search?q=`echo ${ORIGKEYWORD} | cut -c10-`" ;;
   dict%20*) forwardto "http://m-w.com./cgi-bin/dictionary?book=Dictionary&va=`echo ${ORIGKEYWORD} | cut -c8-`" ;;
   thes%20*) forwardto "http://m-w.com./cgi-bin/thesaurus?book=Thesaurus&va=`echo ${ORIGKEYWORD} | cut -c8-`" ;;
   map%20*) %2F
      ARG=`echo ${ORIGKEYWORD} | cut -c7- | urldecode`
      ADDR=`echo ${ARG} | cut -d\/ -f1`
      CSZ=`echo ${ARG} | cut -d\/ -f2`
      forwardto "http://maps.yahoo.com/py/maps.py?Pyt=Tmap&addr=$ADDR&csz=$CSZ&country=us&Get%A0Map=Get+Map"
      ;;
   mail%20*) forwardto "http://f1.mail.yahoo.com/py/ymTo.py?&To=`echo ${ORIGKEYWORD} | cut -c8-`" ;;
   rfc%20*) forwardto http://www.cis.ohio-state.edu/htbin/rfc/${KEYWORD}.html | sed -e 's/%20//' ;;
   rfc*) forwardto http://www.cis.ohio-state.edu/htbin/rfc/${KEYWORD}.html ;;
   caltech%20*) forwardto "http://www.search.caltech.edu/CIT_Search/action.lasso?-database=CIT_Search&-noResults=/CIT_Search/No_Result_Found.html&-response=/CIT_Search/Hit_List_CIT_Search.html&-layout=Search_Layout&-maxRecords=100&Search_Field=`echo ${ORIGKEYWORD} | cut -c11-`&-search" ;;

   ###################################################################
   # Programming: Languages
   ###################################################################
   # java stuff: hardcoded
   swing%20api) forwardto http://java.sun.com./products/jfc/swingdoc-api/index.html ;;
   servlet%20api) forwardto http://www.javasoft.com/products/servlet/2.1/api/packages.html ;;
   java%20lang*%20spec*) forwardto http://java.sun.com./docs/books/jls/html/index.html ;;

   # java APIs
   java%20lang) forwardto http://java.sun.com./products/jdk/1.1/docs/api/Package-java.lang.html ;;
   java%202%20api) forwardto http://java.sun.com./products/jdk/1.2/docs/api/index.html ;;
   java%201.0%20api|java1.0api|"java 1.0 api"|"java 1.0.2 api"|java%201.0.2%20api) forwardto http://java.sun.com./products/jdk/1.0.2/api/ ;;
   java%201.2%20api) forwardto http://java.sun.com./products/jdk/1.2/docs/api/index.html ;;
   java%20api) forwardto http://java.sun.com./products/jdk/1.1/docs/api/packages.html ;;
   java%201.1%20api) forwardto http://java.sun.com./products/jdk/1.1/docs/api/packages.html ;;
   java%20awt%20event) forwardto http://java.sun.com./products/jdk/1.1/docs/api/Package-java.awt.event.html ;;
   java%20awt) forwardto http://java.sun.com./products/jdk/1.1/docs/api/Package-java.awt.html ;;
   java%20util) forwardto http://java.sun.com./products/jdk/1.1/docs/api/Package-java.util.html ;;
   java%20util%20zip) forwardto http://java.sun.com./products/jdk/1.1/docs/api/Package-java.util.zip.html ;;
   java%20rmi) forwardto http://java.sun.com./products/jdk/1.1/docs/api/Package-java.rmi.html ;;
   java%20net) forwardto http://java.sun.com./products/jdk/1.1/docs/api/Package-java.net.html ;;
   java%20lang%20reflect) forwardto http://java.sun.com./products/jdk/1.1/docs/api/Package-java.lang.reflect.html ;;
   javax%20swing) forwardto http://java.sun.com./products/jfc/swingdoc-api-1.1/javax/swing/package-summary.html ;;
   # Java: any class
   java%20applet%20*|java%20awt%20*|java%20awt%20datatransfer%20*|java%20awt%20event%20*|java%20awt%20image%20*|java%20beans%20*|java%20io%20*|java%20lang%20*|java%20lang%20reflect%20*|java%20math%20*|java%20net%20*|java%20rmi%20*|java%20rmi%20dgc%20*|java%20rmi%20registry%20*|java%20rmi%20server%20*|java%20security%20*|java%20security%20acl%20*|java%20security%20interfaces%20*|java%20sql%20*|java%20text%20*|java%20util%20*|java%20util%20zip%20*) forwardto http://java.sun.com./products/jdk/1.1/docs/api/${ORIGKEYWORD}.html#_top_ | sed -e 's/%20/./g' ;;
   javax%20swing*) forwardto http://java.sun.com./products/jfc/swingdoc-api-1.1/${ORIGKEYWORD}.html | sed -e 's/%20/\//g' ;;
   javax%20servlet*) forwardto http://jserv.javasoft.com/products/java-server/documentation/webserver1.0.2/apidoc/${ORIGKEYWORD}.html | sed -e 's/%20/./g' ;;
   # Java: Special cases
   gridlayout) forwardto http://java.sun.com./products/jdk/1.2/docs/api/java/awt/GridLayout.html ;;
   gridbaglayout) forwardto http://java.sun.com./products/jdk/1.2/docs/api/java/awt/GridBagLayout.html ;;
   jtextcomponent) forwardto http://java.sun.com/products/jfc/swingdoc-api-1.1/javax/swing/text/JTextComponent.html ;;
   jcomponent) forwardto http://java.sun.com/products/jfc/swingdoc-api-1.1/javax/swing/JComponent.html ;;
   jtable%20tutorial) forwardto http://java.sun.com./docs/books/tutorial/ui/swing/table.html ;;
   jtextarea) forwardto http://java.sun.com/products/jfc/swingdoc-api-1.1/javax/swing/JTextArea.html ;;
   joptionpane) forwardto http://java.sun.com/products/jfc/swingdoc-api-1.1/javax/swing/JOptionPane.html ;;


   # Java compilers
   guavac) forwardto ftp://ftp.yggdrasil.com/pub/dist/devel/compilers/guavac ;;

   # Pike
   pike) forwardto http://pike.idonex.se/ ;;

   # MPI
   mpi_recv) forwardto http://www.mcs.anl.gov/Projects/mpi/www/www3/MPI_Recv.html ;;
   mpi_send) forwardto http://www.idiap.ch./~bornet/docs/mpiwww/www3/MPI_Send.html ;;

   # Python
   python) forwardto http://www.python.org./ ;;

   #################################################################
   # Programming: Source Control
   #################################################################
   cvs) forwardto http://www.loria.fr/~molli/cvs-index.html ;;
   cvs%20bubbles) forwardto http://www.loria.fr/%7Emolli/cvs-index.html ;;

   #################################################################
   # Other stuff
   #################################################################

   # BART stations
   bart*station*) forwardto http://bart.gov./riding/stations/ ;;
   bart*schedule*) forwardto http://bart.gov./riding/planning/ ;;
   powell*bart*) forwardto http://bart.gov./riding/stations/POWEL/ ;;
   12*bart*) forwardto http://bart.gov./riding/stations/12ST/ ;;
   16*bart*) forwardto http://bart.gov./riding/stations/16ST/ ;;
   19*bart*) forwardto http://bart.gov./riding/stations/19ST/ ;;
   24*bart*) forwardto http://bart.gov./riding/stations/24ST/ ;;
   montgomery*bart*) forwardto http://bart.gov./riding/stations/MONTG/ ;;
   embarcadero*bart*) forwardto http://bart.gov./riding/stations/EMBAR/ ;;
   civic*center*bart*) forwardto http://bart.gov./riding/stations/CIVIC/ ;;
   union*city*bart*) forwardto http://bart.gov./riding/stations/UCITY/ ;;
   ashby*bart*) forwardto http://bart.gov./riding/stations/ASHBY/ ;;
   fruitvale*bart*) forwardto http://bart.gov./riding/stations/FRTVL/ ;;
   coliseum*bart*) forwardto http://bart.gov./riding/stations/COLIS/ ;;

   # Yahoo
   yahoo%20inbox) forwardto 'http://f1.mail.yahoo.com/ym/us/ShowFolder?rb=Inbox' ;;
   maps*yahoo|yahoo*maps) forwardto 'http://maps.yahoo.com/' ;;
   yahoo%20mail|email|mail) forwardto http://mail.yahoo.com/ ;;
   yahoo|my|myyahoo|my%20yahoo) forwardto http://my.yahoo.com/ ;;
   calendar) forwardto http://calendar.yahoo.com/ ;;

   # Other
   kernel*traffic) forwardto http://www.kt.linuxcare.com/kernel-traffic/latest.epl ;;
   freshmeat) forwardto http://www.freshmeat.net./ ;;
   swing%20tutorial) forwardto 'http://java.sun.com./docs/books/tutorial/ui/swing/index.html' ;;
   html%20spefi*|html%20reference|html%20spec*|html%204%20spec|html%204%20specification) forwardto http://www.w3.org/TR/REC-html40/ ;;
   swing%20connection) forwardto http://java.sun.com./products/jfc/tsc/ ;;
   xscreensaver) forwardto http://www.jwz.org/xscreensaver/ ;;
   caltech*credit*union) forwardto http://www.caltech.edu/~cefcu/ ;;
   rpmfind) forwardto http://rpmfind.net/linux/rpm2html/rpmfind.html ;;
   my%20netscape) forwardto http://my.netscape.com/ ;;
   soar) forwardto http://soar.berkeley.edu/recipes/ ;;
   c%2b%2bstandard) forwardto http://www.cygnus.com/misc/wp/nov97/ ;;
   md5%20rfc) forwardto http://www.cis.ohio-state.edu/htbin/rfc/rfc1321.html ;;
   musixtex|mutex|musictex) forwardto http://www.gmd.de/Misc/Music/ ;;
   altima) forwardto http://www.altima.org./ ;;
   cdnow) forwardto http://www.cdnow.com./ ;;
   esound) forwardto http://www.tux.org/~ricdude/EsounD.html ;;
   eterm) forwardto http://www.tcserv.com./Eterm/ ;;
   gale%20log) forwardto http://www.ugcs.caltech.edu./~jtr/gale/log/ ;;
   gale) forwardto http://www.gale.org./ ;;
   gimp) forwardto http://www.gimp.org./ ;;
   gnome) forwardto http://www.gnome.org./ ;;
   mediafind) forwardto http://194.95.209.6/ ;;
   netwatch) forwardto ftp://ftp.slctech.org./pub/ ;;
   nautilus) forwardto http://www.lila.com/nautilus/ ;;
   praya) forwardto http://praya.sourceforge.net./ ;;
   qmail) forwardto http://www.qmail.org./top.html ;;
   replay) forwardto http://replay.linuxpower.org./ ;;
   robocup) forwardto http://www.csl.sony.co.jp./RoboCup/New/ ;;
   scour) forwardto http://www.scour.net/ ;;
   snarf) forwardto http://xach.dorknet.com./snarf/ ;;
   soccer%20server) forwardto http://ci.etl.go.jp./~noda/soccer/server/index.html ;;
   spk) forwardto ftp://screech.alfred.edu./pub/spk/ ;;
   vim) forwardto http://www.vim.org./ ;;
   webster) forwardto http://www.m-w.com./ ;;
   wm2) forwardto http://www.all-day-breakfast.com/wm2/ ;;
   wmx) forwardto http://www.all-day-breakfast.com/wmx/ ;;
   x11amp) forwardto http://x11amp.org/ ;;

   # Caltech stuff
   caltech%20postal%20service|caltech%20post%20office|mail%20services|caltech%20mail%20services) forwardto http://www.caltech.edu/departmentdirectory/Mail_Services.html ;;
   academic%20calendar|caltech%20academic%20calendar) forwardto http://www.caltech.edu/acalendar ;;
   cs1%20grades|cs%201%20grades) forwardto http://www.ugcs.caltech.edu/~cs1/status ;;
   cs1status|cs%201%20status|cs1%20status|cs%201status) forwardto http://www.ugcs.caltech.edu/~cs1/status ;;
   cs1%20section|cs%201%20section) forwardto http://www.ugcs.caltech.edu/~cs1/sections#8b ;;
   cs141|cs%20141) forwardto http://www.cs.caltech.edu./~cs141/ ;;
   cs1|cs%201) forwardto http://www.ugcs.caltech.edu/~cs1/ ;;
   cs2|cs%202) forwardto http://www.ugcs.caltech.edu/~cs2/ ;;
   cs3|cs%203) forwardto http://www.ugcs.caltech.edu/~cs3/ ;;
   cs286|cs%20286) forwardto http://www.vision.caltech.edu./bond/coursegs.html ;;
   me115|me115a|me%20115a|me%20115) forwardto http://robby.caltech.edu./~jwb/courses/ME115/ME115.html ;;

   %2b*)
      #forwardto "http://www.google.com./search?q=$ORIGKEYWORD"
      forwardto "http://infoseek.go.com/Titles?qt=$ORIGKEYWORD"
      ;;
   *%20*)
      #forwardto "http://www.google.com./search?q=$ORIGKEYWORD"
      forwardto "http://infoseek.go.com/Titles?qt=$ORIGKEYWORD"
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
