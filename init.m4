changequote({{, }})dnl
dnl M4_MAKE_SYSCMD({{SYS_HOST}}, {{uname -n}})dnl
dnl M4_MAKE_SYSCMD({{SYS_OS}}, {{uname -s}})dnl
dnl M4_MAKE_SYSCMD({{SYS_OSVER}}, {{uname -r}})dnl
dnl M4_MAKE_SYSCMD({{ORIG_SYS_LAB}}, {{ if [ -z "$LAB" ]; echo NONE; else; echo "$LAB"; fi }})dnl
dnl -----------------------------------------------------------------------
dnl M4_MAKE_SYSCMD({{SYS_TMP_DOMAINNAME}}, {{/bin/domainname}})dnl
define({{SYS_LAB}}, 
	ifelse( SYS_TMP_DOMAINNAME, {{house.of.sin}}, 
					{{UGCS}}, 
			  SYS_TMP_DOMAINNAME, {{cs.caltech.edu}}, 
					{{CS}}, 
           SYS_TMP_DOMAINNAME, {{dabney}},
               {{DABNEY}},
			  ORIG_SYS_LAB))dnl
undefine(SYS_TMP_DOMAINNAME)dnl
dnl -----------------------------------------------------------------------
define(PIXMAPPATH, ifelse(SYS_LAB, {{UGCS}}, {{/usr/include/X11/pixmaps:/usr/ug/include/X11/pixmaps:/home/wtanaka/pixmaps:/net/smonger/drop/pixmaps}},
   SYS_HOST, {{lard}}, {{/usr/X11/include/X11/pixmaps:/net/smonger/drop/pixmaps:/usr/lib/TheNextLevel/pixmaps}},
   SYS_LAB, {{DABNEY}}, {{/usr/include/X11/pixmaps:/home/wtanaka/pixmaps}},
   SYS_LAB, {{CS}}, {{/usr/X11/lib/X11/pixmaps:/ufs/students/wtanaka/pixmaps}},
   SYS_HOST, {{fruity.dabney.caltech.edu}}, {{/usr/include/X11/pixmaps:/home/wtanaka/pixmaps}},
   SYS_HOST, {{concombre.dabney.caltech.edu}}, {{/usr/include/X11/pixmaps:/net/smonger/drop/pixmaps}},
   SYS_HOST, {{smonger.mongers.ml.org}}, {{/usr/export/drop/pixmaps}},
   SYS_HOST, {{castor.mongers.ml.org}}, {{/usr/local/export/drop/pixmaps:/usr/include/X11/pixmaps}},
   SYS_HOST, {{spica.mili.eu.org}}, {{/usr/local/export/drop/pixmaps}},
                  {{/usr/include/X11/pixmaps:/home/wtanaka/pixmaps}}))dnl
define(ICONPATH, ifelse(SYS_LAB, {{UGCS}}, {{/usr/include/X11/bitmaps:/usr/ug/include/X11/bitmaps:/net/smonger/drop/bitmaps}},
                SYS_LAB, {{DABNEY}}, {{/usr/include/X11/pixmaps:/net/smonger/drop/pixmaps}},
                SYS_LAB, {{CS}}, {{/ufs/students/wtanaka/pixmaps}},
                 {{/usr/include/X11/bitmaps}}))dnl
changequote(`, ')dnl
