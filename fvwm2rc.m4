include(functions.m4)dnl
include(init.m4)dnl
include(shells.m4)dnl
changequote({{, }})dnl
define({{LOGIN}},
   ifelse(SYS_HOST, {{smonger}}, {{SSHXTERM}},
          SYS_HOST, {{castor.mili.eu.org}}, {{RXVTSSH}},
                                 {{XTERMSSH}}))dnl
define({{MENUFONT}},
   ifelse(SYS_LAB, {{UGCS}}, {{-*-lucidabright-medium-r-*-*-12-*-*-*-*-*-*-*}},
                             {{-*-lucidabright-medium-r-*-*-12-*-*-*-*-*-*-*}}))dnl
# Samples at ftp://ftp.best.com/pub/tdgilman/Fvwmrcs
ModulePath /usr/libexec/fvwm/2.2:/usr/lib/X11/fvwm2:/usr/X11/lib/X11/fvwm2:/usr/ug/arch/fvwm-2.2/libexec/fvwm/2.2
PixmapPath PIXMAPPATH
IconPath ICONPATH 

EdgeResistance 0 10
EdgeScroll 100 100
ClickTime 100
OpaqueMoveSize 10

# make sure these fonts exist on your system:
WindowFont ifelse(SYS_HOST, {{castor.mili.eu.org}},
{{"-*-fixed-*-*-*-*-7-*-*-*-*-*-*-*"}},
{{"-*-comicscartoon-*-*-*-*-14-*-*-*-*-*-*-*"}})
IconFont -*-lucida-medium-r-*-*-12-*-*-*-*-*-*-*

HilightColor black lightSteelBlue
DeskTopSize 4x3
MenuStyle black grey60 grey40 MENUFONT win anim

ColormapFocus FollowsFocus

# small up triangle
# ButtonStyle 2 4 50x35@1 65x65@0 35x65@0 50x35@1
# small down triangle
# ButtonStyle 4 4 50x65@1 35x35@1 65x35@1 50x65@0
# large up triangle
# ButtonStyle 2 4 50x25@1 75x75@0 25x75@0 50x25@1
# large down triangle
# ButtonStyle 4 4 50x75@1 25x25@1 75x25@1 50x75@0
# big box
# ButtonStyle 2 5 25x25@1 25x75@1 75x75@0 75x25@0 25x25@1
# little box
# ButtonStyle 8 5 40x40@1 60x40@1 60x60@0 40x60@0 40x40@1
# tall box
# ButtonStyle 6 5 40x25@1 60x25@1 60x75@0 40x75@0 40x25@1
# dot
# ButtonStyle 4 5 45x45@1 55x45@1 55x55@0 45x55@0 45x45@1
# an up arrow:
# ButtonStyle 2 8 40x80@1 40x50@1 20x50@1 50x20@1 80x50@0 60x50@0 60x80@0 40x80@0
# an X
# ButtonStyle 3 13 26x29@1 34x21@1 50x35@1 70x21@1 79x29@1 63x48@0 79x65@1 70x75@

# default Styles:
Style "*"           BorderWidth 0, HandleWidth ifelse(
SYS_HOST, {{castor.mili.eu.org}}, {{3}}, 
{{4}})
Style "*"           Icon Unknown.xpm, Color LightSteelBlue/#002244
Style "*"           MWMFunctions, MWMDecor, HintOverride
#Style "*"           NoPPosition
Style "*"           IconBox -120 120 -1 -1
Style "*"           FocusFollowsMouse
Style "*"           RandomPlacement, SmartPlacement
#Style "*"           DecorateTransient

Style "jgsub puff"    WindowListSkip, ClickToFocus
Style "jgsub puff"    Sticky, BorderWidth 2, CirculateSkip
Style "zwgc"         WindowListSkip, ClickToFocus
Style "zwgc"         Sticky, BorderWidth 2, CirculateSkip
Style "xgsubrc"      WindowListSkip, ClickToFocus
Style "xgsubrc"      Sticky, BorderWidth 2, CirculateSkip, NoTitle

# Styles for various Fvwm modules:
Style "Fvwm*"       NoTitle,  Sticky, WindowListSkip
Style "Fvwm*"       BorderWidth 2, CirculateSkipIcon, CirculateSkip
Style "FvwmPager"   StaysOnTop, BorderWidth 0, HandleWidth 0
Style "FvwmBanner"  StaysOnTop
Style "FvwmButtons" Icon toolbox.xpm, ClickToFocus

# Styles for your common terminal emulator programs:
Style "XTerm"       Icon xterm.xpm, SloppyFocus
Style "rxvt"        Icon term.xpm, SloppyFocus
Style "rxvt"        MWMBorder, MWMButtons
Style "Utility xterm" Sticky, NoTitle, Handlewidth 3,CirculateHitIcon

Style "XMix"     CirculateSkip

# Styles for various common programs:
Style "xload"  NoTitle, NoHandles, Sticky, WindowListSkip, ClickToFocus,
Style "xload"  CirculateSkip, StaysOnTop
Style "xeyes"  NoTitle, NoHandles, CirculateSkip, ClickToFocus,
Style "xeyes"  WindowListSkip
Style "*lock"  NoTitle, NoHandles, Sticky, WindowListSkip, ClickToFocus,
Style "*lock"  CirculateSkip, StaysOnTop
Style "xbiff"  NoTitle, NoHandles, Sticky, WindowListSkip, ClickToFocus,
Style "xbiff"  CirculateSkip, StaysOnTop
Style "xmailbox"  NoTitle, NoHandles, Sticky, WindowListSkip, ClickToFocus,
Style "xmailbox"  CirculateSkip, StaysOnTop
Style "4va*"   NoTitle, NoHandles, Sticky, WindowListSkip, ClickToFocus,
Style "4va*"   CirculateSkip
Style "xcalc"       Icon xcalc.xpm, NoButton 2,RandomPlacement,ClickToFocus
Style "xmh"         Icon mail1.xpm, NoIconTitle,StickyIcon
Style "xmh"	    RandomPlacement, NoButton 2
Style "xman"	    Icon xman.xpm, RandomPlacement, ClickToFocus
Style "xmag"	    Icon mag_glass.xpm, RandomPlacement, ClickToFocus
Style "xgraph"      Icon graphs.xpm, RandomPlacement, ClickToFocus
Style "xmosaic"     Color Green/Yellow, ClickToFocus

Style "*atori*"       Icon rndcatori.xpm
Style "*Praya*"         Icon rndpraya.xpm

Style "*BSD*"        Icon rndaemon.xpm
Style "*HP-UX*"      Icon HPMonitor.xpm
Style "*IRIX*"       Icon rndsgi.xpm
Style "*(Linux*"     Icon rndpeng.xpm
Style "*SunOS*"      Icon rndsun.xpm
Style "*(Paragon*"   Icon rndintel.xpm

Style "*Oberon *"       Icon rndoberon.xpm
Style "Gimp"         Icon rndwilb.xpm
Style "GnomeHelpBrowser"  Icon rndgnome.xpm
Style "XMathematica"  Icon rndmath.xpm
Style "soccermonitor" Icon rndsoccer.xpm
Style "Netscape"      Icon rndscape.xpm
Style "Calendar"          Icon rndical.xpm
Style "Reminder"          Icon rndical.xpm
Style "Gnomecal"      Icon rndcal.xpm
Style "aumix"         Icon rndmix.xpm
Style "GV"            Icon rndghost.xpm
Style "x11amp"        Icon rndxamp.xpm
Style "Icq"           Icon rndicq.xpm
Style "Gtkicq"        Icon rndicq.xpm
Style "LinPopUp"      Icon rndlinpop.xpm
Style "Gmem"          Icon rndgmem.xpm
Style "XDvi"          Icon rndxdvi.xpm
Style "ee"            Icon rndee.xpm
Style "MapleV*"       Icon rndmaple.xpm
Style "AcroRead"      Icon rndpdf.xpm
Style "Tkquerypr*"    Icon rndgnatq.xpm
Style "Tkgnats*"      Icon rndgnats.xpm
Style "Tksendpr*"     Icon rndgnatspr.xpm
Style "gnp+"          Icon rndnote.xpm
Style "soffice"       Icon rndstar.xpm
Style "gtcd"          Icon rndgtcd.xpm
Style GnomeCard       Icon rndcard.xpm
Style xmms            Icon rndxmms.xpm
Style ugh             Icon rndflow.xpm
Style "gnome-napster" Icon rndnapster.xpm
Style "Gnapster"      Icon rndnapster.xpm
Style "xmame*"         Icon rndmame.xpm
Style "pine"          Icon rndpine.xpm
Style "*Snes9X*"      Icon rndsnes.xpm
Style "*Snes9x*"      Icon rndsnes.xpm
Style "Fugu"          Icon rndfugu.xpm
Style "lyX"           Icon rndlyx.xpm
Style "xclipboard"    Icon rndclip.xpm
Style "*colorsel"     Icon rndcolor.xpm
Style "Vmw"           Icon rndvmware.xpm
Style "RealPlay*"     Icon rndreal.xpm
Style "Mozilla-bin"   Icon rndmozilla.xpm
Style "Dia"           Icon rnddia.xpm
Style "Gtk_gnutella"  Icon rndgnut.xpm
Style "*MpegTV *"      Icon rndmtv.xpm
Style "XEphem"        Icon rndxephem.xpm
Style "wo3 hen3 chan2" Icon rndchan.xpm
Style "gmc"           Icon rndgnome.xpm

define({{MAGIC}},
   ifelse(
      SYS_HOST, {{spica.mili.eu.org}}, {{4}},
      SYS_HOST, {{fruity.dabney.caltech.edu}}, {{4}},
      SYS_HOST, {{castor.mili.eu.org}}, {{4}},
      SYS_HOST, {{altair.mili.eu.org}}, {{4}},
      SYS_HOST, {{dragontail.i}}, {{4}},
      SYS_HOST, {{monarch.infospheres.com}}, {{4}},
      SYS_HOST, {{socrates.cs.caltech.edu}}, {{4}},
      SYS_HOST, {{lenin.dabney.caltech.edu}}, {{4}},
                                 {{M}}))dnl

define({{MAGIC_K}},
   ifelse(
      SYS_HOST, {{fruity.dabney.caltech.edu}}, {{4}},
      SYS_HOST, {{spica.mili.eu.org}}, {{4}},
      SYS_HOST, {{castor.mili.eu.org}}, {{4}},
      SYS_HOST, {{altair.mili.eu.org}}, {{4}},
      SYS_HOST, {{dragontail.i}}, {{4}},
      SYS_HOST, {{monarch.infospheres.com}}, {{4}},
      SYS_HOST, {{socrates.cs.caltech.edu}}, {{4}},
      SYS_HOST, {{lenin.dabney.caltech.edu}}, {{4}},
                                 {{CM}}))dnl

#   Key     Context  Modifiers   Function
#   ----------------------------------------------------------------
Key z       A        MAGIC_K     Restart fvwm2
Key m       A        MAGIC_K     Move
dnl Key Tab     A        MAGIC           Next [CurrentScreen CurrentDesk !Sticky] Function FocusRaiseWarp
dnl Key Tab     A        S{{}}MAGIC          Prev [CurrentScreen CurrentDesk !Sticky] Function FocusRaiseWarp
Key Tab     A        MAGIC           Next [CurrentDesk CurrentScreen] Function FocusRaiseWarp
Key Tab     A        S{{}}MAGIC          Prev [CurrentDesk CurrentScreen] Function FocusRaiseWarp
Key c       135ITWFS MAGIC_K     Close
Key i       135ITWFS MAGIC_K     Iconify
Key h       A        MAGIC_K     CursorMove -1 +0
Key j       A        MAGIC_K     CursorMove +0 +1
Key k       A        MAGIC_K     CursorMove +0 -1
Key l       A        MAGIC_K     CursorMove +1 +0
Key u       A        MAGIC_K     UtilityFunction
Key space   135ITWFS MAGIC_K     RaiseLower
Key Return  135ITWFS MAGIC_K     Function FocusRaiseWarp
Key r       A        MAGIC_K     Resize
Key w       A        MAGIC_K     WindowList
Key n       A        MAGIC_K     Menu Logins
Key s       A        MAGIC_K     Stick
Key F1      A        MAGIC       GotoPage 0 0
Key F2      A        MAGIC       GotoPage 1 0
Key F3      A        MAGIC       GotoPage 2 0
Key F4      A        MAGIC       GotoPage 3 0
Key F5      A        MAGIC       GotoPage 0 1
Key F6      A        MAGIC       GotoPage 1 1
Key F7      A        MAGIC       GotoPage 2 1
Key F8      A        MAGIC       GotoPage 3 1
Key F9      A        MAGIC       GotoPage 0 2
Key F10     A        MAGIC       GotoPage 1 2
Key F11     A        MAGIC       GotoPage 2 2
Key F12     A        MAGIC       GotoPage 3 2
Key F1      A        CS          DeskAndPagerAbsolute 0
Key F2      A        CS          DeskAndPagerAbsolute 1
Key F3      A        CS          DeskAndPagerAbsolute 2
Key F4      A        CS          DeskAndPagerAbsolute 3
Key F5      A        CS          DeskAndPagerAbsolute 4
Key F6      A        CS          DeskAndPagerAbsolute 5
Key F7      A        CS          DeskAndPagerAbsolute 6
Key F8      A        CS          DeskAndPagerAbsolute 7
Key F9      A        CS          DeskAndPagerAbsolute 8
Key F10     A        CS          DeskAndPagerAbsolute 9
Key F11     A        CS          DeskAndPagerAbsolute 10
Key F12     A        CS          DeskAndPagerAbsolute 11

#  Button   Context  Modifiers   Function
#  ---------------------------------------------------------------------
Mouse 1     R        N           WindowList
Mouse 2     R        N           Menu RootMenu Nop
Mouse 1     R        M           Menu RootMenu Nop
Mouse 3     R        N           Menu Logins Nop
Mouse 1     R        C           Menu Logins Nop

#Mouse 0     1        A           Menu Window-Ops2 Close
#Mouse 0     3        A          Maximize-Func
Mouse 1     T        A           Main-Titlebar-Click
Mouse 1     ITWFS    MAGIC       Main-Titlebar-Click
Mouse 2     FST      A           Menu Window-Ops2 Close
Mouse 2     ITWFS    MAGIC       Menu Window-Ops2 Close
Mouse 3     FST      A           Iconify
Mouse 3     ITWFS    MAGIC       Iconify
Mouse 1     FS       A           Resize-or-Raise
Mouse 1     I        N           Iconify

#   for other parts of the window/borders/icons:

######################## Initialization Functions ############################
AddToFunc InitFunction 	  "I" Module FvwmPager 0 0
#+			  "I" exec xsetroot -mod 2 2 -fg \#554055 -bg \#705070

AddToFunc RestartFunction "I" Module FvwmPager 0 0
#+			  "I" exec xsetroot -mod 2 2 -fg \#554055 -bg \#705070


######################## Menus ###################
AddToMenu RootMenu	"Root Menu"	Title
+			"Move"		Move
+			"Resize"	Resize
+			"Raise"		Raise
+			"Lower"		Lower 
+		 	"(De)Iconify"	Iconify
+			"(Un)Stick"	Stick		
+			"(Un)Maximize"	Maximize
+			""		Nop
+			"Close"		Close
+			"Delete"	Delete
+			"Destroy"	Destroy
+			""		Nop
+			"Fvwm Modules"	          Popup Module-Popup
+                       "Fvwm Simple Config Ops"  Popup Misc-Ops
+			""		Nop
+                       "Refresh Screen"   Refresh
+                       "Recapture Screen" Recapture
+			""		Nop
+			"Exit Fvwm"	Popup Quit-Verify

AddToMenu Utilities     "Utilities" Title
+			"Top"		Exec exec xterm -T Top -n Top -e top
+			"Calculator"	Exec exec xcalc
+			"Xman"		Exec exec xman
+			"Xmag"		Exec exec xmag
+                       "Editres"       Exec exec editres
+			""		Nop
+			"XEmacs"	Exec exec xemacs
+                       "Mail"          MailFunction xmh "-font fixed"
+			""		Nop
+                       "XLock"         Exec exec xlock -mode random
+			""		Nop
+                       "Reset X defaults" Exec xrdb -load $HOME/.Xdefaults 

AddToMenu Misc-Ops "Misc Config Opts" Title
+                  "Full Paging"         EdgeScroll 100 100
+                  "Half Paging"         EdgeScroll 50 50
+                  "Tenth Paging"         EdgeScroll 10 10
+                  "No Paging"         EdgeScroll 0 0
+                  "Horizontal Paging" EdgeScroll 100 0
+                  "Vertical Paging"   EdgeScroll 0 100
+                  "Full Paging && Edge Wrap" EdgeScroll 100000 100000
+                  "" Nop
+                  "Colormap Follows Mouse" ColormapFocus FollowsMouse
+                  "Colormap Follows Focus" ColormapFocus FollowsFocus
+                  "" Nop
+                  "Sloppy Focus"        ChangeDefaultFocus SloppyFocus
+                  "Click To Focus"      ChangeDefaultFocus ClickToFocus
+                  "Focus Follows Mouse" ChangeDefaultFocus FocusFollowsMouse

AddToMenu Window-Ops	"Window Ops"	Title		
+			"Move"		Move
+			"Resize"	Resize
+			"Raise"		Raise
+			"Lower"		Lower 
+		 	"(De)Iconify"	Iconify
+			"(Un)Stick"	Stick		
+			"(Un)Maximize"	Maximize
+			""		Nop
+			"Close"		Close
+			"Delete"	Delete
+			"Destroy"	Destroy
+			""		Nop
+			"Refresh Window" RefreshWindow

AddToMenu Window-Ops2	"&Move"		Move
+                       "&Resize"   Resize
+                       "(Un)&Stick"   Stick 
+                       "(De)&Iconify"   Iconify    
+                       "(Un)Ma&ximize" Maximize
+                       "R&aise"   Raise      
+                       "&Lower"   Lower      
+                       ""      Nop        
+                       "&Close"   Close
+                       "&Delete"   Delete   
+                       "Destroy"   Destroy    
+                       ""      Nop
+                       "ScrollBar"    Module FvwmScroll 2 2   
+                       "Print"         PrintFunction
+                       "Print Reverse" PrintReverseFunction

# be sure to fill these in with your correct machine names:
AddToMenu Remote-Logins	"dopey"	 Exec rsh dopey rxvt -display $HOSTDISPLAY &
+			"snoopy" Exec rsh snoopy rxvt -display $HOSTDISPLAY &
+			"grumpy" Exec rsh grumpy rxvt -display $HOSTDISPLAY &
+			"happy"	 Exec rsh happy rxvt -display $HOSTDISPLAY &
+			"bailey" Exec rsh bailey rxvt -display $HOSTDISPLAY &
+			"barnum" Exec rsh barnum rxvt -display $HOSTDISPLAY &
+			"joker"	 Exec rsh joker rxvt -display $HOSTDISPLAY &
+			"signal" Exec rxterm signal

AddToMenu Module-Popup	"FvwmModules"	Title
+			"Identify"	Module	FvwmIdent
+			"Talk"  	Module	FvwmTalk
+			""		Nop
+			"Button-Bar"	Module	FvwmButtons
+			"Pager"		Module  FvwmPager 0 0
+			"Pager (4 desks)" Module  FvwmPager 0 3
+			"WinList"	Module  FvwmWinList
+			""		Nop
+			"Banner"	Module	FvwmBanner
+                       "ScrollBar"     Module  FvwmScroll 50 50
+			"Background"	Module  FvwmBacker
+                       "AutoRaise"     Module  FvwmAuto 200 Raise Nop
+                       "Stop AutoRaise" KillModule FvwmAuto
+			""		Nop
+			"IconBox"	Module	FvwmIconBox
+                       "IconMan"       Module  FvwmIconMan
+			""		Nop
+                       "Form - Rlogin"      Module FvwmForm Rlogin
+                       "Form - MyFvwmTalk"  Module FvwmForm MyFvwmTalk
+                       "Form - QuitVerify"  Module FvwmForm QuitVerify

AddToMenu Quit-Verify 	"Really Quit Fvwm?" Title	
+		      	"Yes, Really Quit"  Quit	
+		      	""		    Nop	
+                       "Restart Fvwm2"     Restart fvwm2
+		      	"Restart Fvwm"	    Restart fvwm
+		      	"Restart wm2"	    Restart wm2
+		      	""		    Nop	
+		      	"Start twm"         Restart twm
+		      	"Start ctwm"        Restart ctwm
+		        "Start tvtwm"       Restart tvtwm
+		        "Start vtwm"        Restart vtwm
+		      	"Start mwm"    	    Restart mwm
+	      	      	"Start olwm"        Restart /usr/openwin/bin/olwm
+		      	""		    Nop	
+		      	"Start dummy"       Restart xterm
+		      	""		    Nop	
+		      	"No, Don't Quit"    Nop	

AddToMenu UGHP    "hp"                Function LOGIN hp.ugcs SteelBlue1 HP-UX
AddToMenu UGSGI   "sgi"               Function LOGIN sgi.ugcs SteelBlue1 IRIX

AddToMenu CCO     "morocco"          Function LOGIN morocco.cco red2 SunOS
AddToMenu CS      "fast"             Popup CS-P2
AddToMenu CS-P2   "cezanne"          Function LOGIN cezanne.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "chagall"          Function LOGIN chagall.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "da-vinci"         Function LOGIN da-vinci.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "gainsborough"     Function LOGIN gainsborough.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "gaugain"          Function LOGIN gaugain.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "michelangelo"     Function LOGIN michelangelo.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "monet"            Function LOGIN monet.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "picasso"          Function LOGIN picasso.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "raphael"          Function LOGIN raphael.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "rembrandt"        Function LOGIN rembrandt.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "renoir"           Function LOGIN renoir.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "rubens"           Function LOGIN rubens.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "toulouse-lautrec" Function LOGIN toulouse-lautrec.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "vangogh"          Function LOGIN vangogh.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "varese"           Function LOGIN varese.cs.caltech.edu. GoldenRod1 BSD
AddToMenu CS-P2   "velasquez"        Function LOGIN velasquez.cs.caltech.edu. GoldenRod1 BSD
AddToMenu DABNEY  "lenin"            Function LOGIN dabney.caltech.edu. green2 Linux
AddToMenu DABNEY  "fruity"           Function LOGIN fruity.dabney.caltech.edu. MediumSpringGreen Linux
AddToMenu INFO    "info"             Function LOGIN info.cs.caltech.edu. PaleGoldenrod SunOS
AddToMenu INFO    "sphere"           Function LOGIN sphere.cs.caltech.edu. PaleGoldenrod SunOS
AddToMenu UGHP    "gluttony"         Function LOGIN gluttony.ugcs.caltech.edu. SteelBlue1 HP-UX
AddToMenu UGHPS   "mince"            Function LOGIN mince.ugcs.caltech.edu. SteelBlue1 HP-UX
AddToMenu UGSGI   "auto"             Function LOGIN auto.ugcs.caltech.edu. SteelBlue1 IRIX
AddToMenu UGSGI   "taphe"            Function LOGIN taphe.ugcs.caltech.edu. SteelBlue1 IRIX
AddToMenu USGI133 "amatho"           Function LOGIN amatho.ugcs.caltech.edu. SteelBlue1 IRIX
AddToMenu USGI133 "mono"             Function LOGIN mono.ugcs.caltech.edu. SteelBlue1 IRIX
AddToMenu USGI133 "necro"            Function LOGIN necro.ugcs.caltech.edu. SteelBlue1 IRIX
AddToMenu USGI133 "pyro"             Function LOGIN pyro.ugcs.caltech.edu. SteelBlue1 IRIX

AddToMenu UGHP    "Slower"    Popup    UGHPS
AddToMenu UGSGI   "Slower"    Popup    USGI133

AddToMenu UGCS    "to.ugcs"  Function LOGIN to.ugcs.caltech.edu. SteelBlue1 ?
+                 "SGI"      Popup    UGSGI
+                 "HP"       Popup    UGHP

AddToMenu MILIEU  "spica"    Function LOGIN spica.mili.eu.org. thistle2 Linux 
+                 "smonger"  Function LOGIN smonger.mili.eu.org. thistle2 Linux 
+                 "fmonger"  Function LOGIN fmonger.mili.eu.org. thistle2 Linux 
+                 "castor"   Function LOGIN castor.mili.eu.org. thistle2 Linux 

AddToMenu Logins  "random"      Exec     RANDOM_SHELL
+                 "milieu"      Popup    MILIEU
+                 "catori"      Exec     x catori
+                 "Dabney"      Popup    DABNEY
+                 "UGCS"        Popup    UGCS
+                 "CS"          Popup    CS
+                 "Infospheres" Popup    INFO
+                 "CCO"         Popup    CCO

######################## Sample Functions ##########################

AddToFunc DeskAndPagerAbsolute   "I" Desk 0 $0
+                                "I" Next [FvwmPager] Close
+                                "I" Module FvwmPager $0 $0

AddToFunc MailFunction	   "I" Next [$0] Iconify -1
+		           "I" Next [$0] Focus
+			   "I" None [$0] Exec $0 $1

AddToFunc UtilityFunction "I" Next [iconic Utility?xterm] Iconify -1
+           "I" Next [Utility?xterm] FocusRaise
+           "I" None [Utility?xterm] Exec env XTERMTYPE=utility xterm -ls -geometry 80x15-0-0 -n "Utility xterm" -T "Utility xterm"

AddToFunc Main-Titlebar-Click    "M" Move
+                                "M" Raise
+                                "C" RaiseLower
+                                "D" WindowShade

AddToFunc Move-or-Raise-or-Shade "I" Raise
+                                "I" Move
+                                "D" WindowShade

AddToFunc Move-or-Raise2	"M" Raise
+				"M" Move
+  				"D" Lower

AddToFunc Maximize-Func		"M" Maximize	 0 100
+				"C" Maximize	 0 80
+				"D" Maximize	 100 100

AddToFunc Move-or-Iconify	"I" Raise
+				"M" Move
+				"D" Iconify

AddToFunc Resize-or-Raise	"I" Raise
+				"M" Resize
+				"D" Lower

AddToFunc Resize-or-Raise2	"M" Raise
+				"M" Resize
+				"D" Lower

AddToFunc PrintFunction		"I" Raise
+				"I" Exec xdpr -id $w

AddToFunc PrintReverseFunction  "I" Raise
+                               "I" Exec xdpr 1/2 -h -rv -id $w

AddToFunc Iconify-and-Raise     "I" Iconify
+                               "I" Raise

AddToFunc SSHXTERM "I" Exec ssh -f $0 xterm -ls -fg "$1" -bg black -T \"$0 \($2\)\" -n $0

AddToFunc XTERMSSH "I" Exec xterm -ls -fg "$1" -bg black -T "$0 ($2)" -n $0 -e ssh $0

AddToFunc RXVTSSH "I" Exec rxvt -ls -fg "$1" -bg black -T "$0 ($2)" -n $0 -e ssh $0

# RLOGIN machine fg bg
AddToFunc RLOGIN "I" Exec xterm -fg $1 -bg $2 -e rlogin $0 -8

# TELNET machine fg bg
AddToFunc TELNET "I" Exec xterm -fg $1 -bg $2 -e telnet $0

AddToFunc FocusRaise       "I" Focus
+                          "I" Raise

AddToFunc FocusRaiseWarp   "I" Focus
+                          "I" Raise
+                          "I" WarpToWindow 0 100
+                          "I" WarpToWindow 100 0
+                          "I" WarpToWindow 5 1

AddToFunc FocusAndWarp "I" Focus
+                      "I" WarpToWindow 0 100
+                      "I" WarpToWindow 100 0
+                      "I" WarpToWindow 95 5

#AddToFunc FocusAndWarp "I" Focus
#+                      "I" WarpToWindow 2p 2p

AddToFunc DeiconifyFocusAndWarp "I" Iconify -1
+                               "I" FocusAndWarp

AddToFunc ChangeDefaultFocus "I" Style "*" $0
+                            "I" Recapture

# Turns on Audio
*FvwmAudioPlayCmd ifelse(SYS_LAB, {{DABNEY}}, {{/home/wtanaka/bin/d}},
                   {{builtin-rplay}})
*FvwmAudioDir /net/smonger/drop/audio
*FvwmAudioRplayPriority 0
*FvwmAudioRplayVolume 127
*FvwmAudio add_window utopia_open.wav
*FvwmAudio deiconify utopia_maximize.wav
*FvwmAudio destroy_window utopia_close.wav
*FvwmAudio end_windowlist utopia_exclamation.wav
*FvwmAudio iconify utopia_minimize.wav
*FvwmAudio lower_window utopia_restore_down.wav
*FvwmAudio raise_window utopia_resotre_up.wav
*FvwmAudio shutdown utopia_windows_exit.wav
*FvwmAudio startup utopia_windows_start.wav
*FvwmAudio focus_change utopia_menu_popup.wav
#*FvwmAudio configure_window utopia_critical_stop.wav
#*FvwmAudio new_desk Jungle_Asterisk.wav
#*FvwmAudio new_page Jungle_Asterisk.wav
#*FvwmAudio res_class beep.au
#*FvwmAudio res_name beep.au
#*FvwmAudio icon_name I_Want_To_Buy_Some_Cheese.au
#*FvwmAudio window_name beep.au
#*FvwmAudio unknown doh.au

ifelse(SYS_LAB,{{DABNEY}},{{Module FvwmAudio}},
       SYS_HOST,{{smonger}},{{Module FvwmAudio}})

################## FvwmButtons button-bar ################################
*FvwmButtonsBack lightsteelblue
*FvwmButtons(Frame 1 Padding 2 2 Container(Rows 1 Frame 1 Padding 0 0 \
                          Elvis_Left.au                 Swallow(Respawn)))
*FvwmButtons(Frame 1 Swallow(Respawn,UseOld) wmtime \
       `Exec exec wmtime`, Action 'Exec wmtime')
#*FvwmButtons(3x1 Back darkolivegreen Fore white Frame 2 Padding 2 2 Container(Rows 1 Frame -2 Padding 1 1 Back darkolivegreen))
#*FvwmButtons(Frame 2 Title(Side,Right) Mail Fore white 
#         Swallow(UseOld,NoRespawn)\
#         xbiff `Exec exec xbiff -bg darkolivegreen -geometry +200+200`)
#*FvwmButtons(2x1 Swallow (NoHints) "FvwmTalk" "FvwmTalk")
#*FvwmButtons(End)
*FvwmButtons(End)


########################## Window-Identifier ###############################
# Just choose colors and a fonts
*FvwmIdentBack MidnightBlue
*FvwmIdentFore Yellow
*FvwmIdentFont -adobe-helvetica-medium-r-*-*-12-*-*-*-*-*-*-*

########################### Pager #########################################
*FvwmPagerBack #908090
*FvwmPagerFore #484048
*FvwmPagerFont -adobe-helvetica-bold-r-*-*-10-*-*-*-*-*-*-*
*FvwmPagerHilight #cab3ca
*FvwmPagerGeometry 120x80-0+20
*FvwmPagerLabel 0 wtanaka
*FvwmPagerLabel 1 Maker
*FvwmPagerLabel 2 Mail
*FvwmPagerLabel 3 Matlab
*FvwmPagerSmallFont 5x8

##########################FvwmWinList##################################
*FvwmWinListBack #908090
*FvwmWinListFore Black
*FvwmWinListFont -adobe-helvetica-bold-r-*-*-10-*-*-*-*-*-*-*
*FvwmWinListAction Click1 Iconify -1,Focus
*FvwmWinListAction Click2 Iconify
*FvwmWinListAction Click3 Module "FvwmIdent" FvwmIdent
*FvwmWinListUseSkipList
*FvwmWinListGeometry +0-1
                                      

*FvwmBackerDesk 0 -solid steelblue
*FvwmBackerDesk 1 -solid midnightblue

*FvwmScrollBack grey40
*FvwmScrollFore green
	
############################################################
############################################################
# Note that icons are shown in the module
#    only if NoIcon commnand is applied.
#Style     "*"  NoIcon

############################################################
*FvwmIconBoxIconBack    #cfcfcf
*FvwmIconBoxIconHiFore  black
*FvwmIconBoxIconHiBack  LightSkyBlue
*FvwmIconBoxBack        #5f9ea0
#*FvwmIconBoxFore       blue
*FvwmIconBoxGeometry    5x1+0+0
*FvwmIconBoxMaxIconSize 64x38
*FvwmIconBoxFont        -adobe-helvetica-medium-r-*-*-12-*-*-*-*-*-*-*
*FvwmIconBoxSortIcons   IconName
*FvwmIconBoxPadding     4
*FvwmIconBoxLines       10
*FvwmIconBoxSBWidth     11
*FvwmIconBoxPlacement   Left Top
*FvwmIconBoxPixmap      fvwm.xpm
#*FvwmIconBoxHideSC Horizontal
*FvwmIconBoxSetWMIconSize
*FvwmIconBoxHilightFocusWin
#*FvwmIconBoxResolution          Desk
*FvwmIconBoxMouse       1       Click           RaiseLower
*FvwmIconBoxMouse       1       DoubleClick     Iconify
*FvwmIconBoxMouse       2       Click           Iconify -1, Focus
*FvwmIconBoxMouse       3       Click           Module FvwmIdent
*FvwmIconBoxKey         r       RaiseLower
*FvwmIconBoxKey         space   Iconify
*FvwmIconBoxKey         d       Close
*FvwmIconBoxKey         n       Next
*FvwmIconBoxKey         p       Prev
*FvwmIconBoxKey         h       Left
*FvwmIconBoxKey         j       Down
*FvwmIconBoxKey         k       Up
*FvwmIconBoxKey         l       Right
#
# Icon file specifications
#
# Mostly, you don't have to specify icon files, as FvwmIconBox now
# reads icon files specified in Style commands.
#
*FvwmIconBox            "Fvwm*"         -

# FvwmForm alias - rlogin or telnet to host via xterm
*RloginWarpPointer
*RloginFont         *helvetica*m*r*n*12*
*RloginButtonFont   *helvetica*m*o*n*12*
*RloginInputFont    *cour*m*r*n*12*
*RloginFore         Black
*RloginBack         Light Gray
*RloginItemFore          Wheat
*RloginItemBack          Gray50
# begin items
*RloginLine         center
*RloginText         "Login to Remote Host"
*RloginLine         center
*RloginText         "Host:"
*RloginInput        HostName  30   ""
*RloginLine         center
*RloginSelection    meth single
*RloginChoice       TN TN off "telnet"
*RloginChoice       RL RL on "rlogin"
*RloginSelection    UserSel   single
#*RloginChoice       Default   Default   on   "same user"
#*RloginChoice       Custom    Custom    off  "user:"
*RloginText         "(Userid:"
*RloginInput        UserName  10   ""
*RloginText         ")"
*RloginLine         center
*RloginText         "FG:"
*RloginInput        FgColor 15 ""
*RloginText         "BG:"
*RloginInput        BgColor 15 ""
*RloginLine         expand
*RloginButton       quit "Login" ^M
*RloginCommand Exec xterm  $(FgColor?-fg $(FgColor)) $(BgColor?-bg $(BgColor)) -T xterm@$(HostName) -e $(RL?rlogin) $(TN?telnet) $(HostName) $(RL?-8 $(UserName?-l $(UserName)))
*RloginButton       restart   "Clear"
*RloginCommand Beep
*RloginButton       quit "Cancel"
*RloginCommand Nop

# FvwmForm alias - query exit ala mwm
*QuitVerifyGrabServer
*QuitVerifyWarpPointer
*QuitVerifyFont          *helvetica*m*r*n*14*
#*QuitVerifyButtonFont    *helvetica*m*o*n*14*
*QuitVerifyButtonFont    7x13bold
*QuitVerifyFore          Black
*QuitVerifyBack          Light Gray
*QuitVerifyItemFore Wheat
*QuitVerifyItemBack Gray50
# begin items
*QuitVerifyLine          center
*QuitVerifyText          "Do you really want to exit FVWM?"
*QuitVerifyLine          expand
*QuitVerifyButton   quit      " Exit "
*QuitVerifyCommand  Quit
*QuitVerifyButton   quit      "Cancel"
*QuitVerifyCommand  Nop

## MyTalk & MyFvwmTalk from Dave Goldberg
## MyTalk Form - dissappears after use
#*MyTalkWarpPointer
#*MyTalkFont *helvetica*m*r*n*14*
#*MyTalkButtonFont *helvetica*m*o*n*14*
#*MyTalkInputFont *cour*m*r*n*14*
#*MyTalkFore Red
#*MyTalkBack Gray
#*MyTalkItemFore Blue
#*MyTalkItemBack Gray
#*MyTalkLine center
#*MyTalkText "Fvwm Function"
#*MyTalkInput Func 40 ""
#*MyTalkLine expand
#*MyTalkButton quit "Run" ^M
#*MyTalkCommand $(Func)
#*MyTalkButton restart "Clear" ^R
#*MyTalkButton quit "Cancel" ^C
#*MyTalkCommand Nop
## MyFvwmTalk Form - sticks around
#*MyFvwmTalkWarpPointer
#*MyFvwmTalkFont *helvetica*m*r*n*14*
#*MyFvwmTalkButtonFont *helvetica*m*o*n*14*
#*MyFvwmTalkInputFont *cour*m*r*n*14*
#*MyFvwmTalkFore Red
#*MyFvwmTalkBack Gray
#*MyFvwmTalkItemFore Blue
#*MyFvwmTalkItemBack Gray
#*MyFvwmTalkLine center
#*MyFvwmTalkText "Fvwm Function"
#*MyFvwmTalkInput Func 40 ""
#*MyFvwmTalkLine expand
#*MyFvwmTalkButton restart "Run" ^M
#*MyFvwmTalkCommand $(Func)
#*MyFvwmTalkButton restart "Clear" ^R
#*MyFvwmTalkCommand Nop
#*MyFvwmTalkButton restart "Iconify" ^Z
#*MyFvwmTalkCommand Next [MyFvwmTalk] Iconify
#*MyFvwmTalkButton quit "Quit" ^C
#*MyFvwmTalkCommand Nop

# to change banner pixmap
#*FvwmBannerPixmap fvwm3.xpm
#*FvwmBannerTimeout 2

