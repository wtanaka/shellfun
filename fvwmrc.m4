include(functions.m4)dnl
include(init.m4)dnl
include(shells.m4)dnl
changequote({{, }})dnl
define({{LOGIN}},
   ifelse(SYS_HOST, {{smonger}}, {{SSHXTERM($1,$2,$3,$4)}},
                                 {{XTERMSSH($1,$2,$3,$4)}}))dnl
define({{SSHXTERM}}, {{Exec "$1" exec ssh -f $2 xterm -ls -fg $3 -bg black -T wtanaka@$2\\ \\\($4\\\) -n $2}})dnl
define({{XTERMSSH}}, {{Exec "$1" exec xterm -fg $3 -bg black -T $2!wtanaka\ \($4\) -n $2 -e ssh $2}})dnl
# Unfortunately, order does matter in this file
# The correct order for inserting configurations is:
# 1. Colors
# 2. Assorted configuration paramters such as ClickToFocus, or MWMBorders
# 3. Path setup (ModulePath, PixmapPath, IconPath)
# 4. Style settings, including the default style Style "*" ...
# 5. InitFunction and ResetFunction definitions.
# 6. Other Functions. Functions cannot be forward referenced from
#	other functions, but they can be backward referenced.
# 7. Menus definitions. Same caveats about forward referencing
# 8. Key and Mouse Bindings.
# 9. Module options.

# The order of steps 5, 6, and 7 is not critical, as long as there are
# no forward references to functions or menus.

# If you get it wrong, the most common problem is that color or font settings
# are ignored
###########################################################################
# This sample is set up to try to conserve memory. A few techniques are
# used:
# 1. Only "fixed" font is used.
# 2. The internal pager is used instead of the module.
# 3. The FvwmWinList is used instead of the internal one.
# 4. rxvt is used instead of xterm.
# 5. Color icons are avoided.
###########################################################################
# set up the colors

# this is used for the selected window
StdForeColor		lightSteelBlue
StdBackColor		#002244

HiForeColor 		Black
HiBackColor 		lightSteelBlue

PagerBackColor		#908090
PagerForeColor		#484048

StickyForeColor		Black
StickyBackColor		SteelBlue

# Menu colors
MenuForeColor           Black
MenuBackColor           grey60
MenuStippleColor        grey40

###########################################################################
# Set up the major operating modes
#
########################      FOCUS STUFF     ##############################
# Set windows to auto-raise after 750 milliseconds if you like it.
# Autoraise can sometimes obscure pop-up windows. Performance is now
# similar to olvwm's auto-raise feature.
#AutoRaise 750

# Normally, we'll be in focus-follows mouse mode, but uncomment this 
# for mwm-style click-to-focus
#ClickToFocus

SloppyFocus

########################      ICON STUFF     ##############################
# Auto Place Icons is a nice feature....
# This creates two icon boxes, one on the left side, then one on the
# bottom. Leaves room in the upper left for my clock and xbiff,
# room on the bottom for the Pager.
#IconBox -150 90 -5 -140
#IconBox 5 -140 -140 -5
#IconBox -70 1 -1 -140
IconBox 1 1 -1 -1

# If you uncomment this, and make sure that the WindowList is bound to
# something, it works pretty much like an icon manager.
#SuppressIcons

# StubbornIcons makes icons de-iconify into their original position on the
# desktop, instead of on the current page.
#StubbornIcons

# With AutoPlacement, icons will normally place themselves underneath active
# windows. This option changes that.
StubbornIconPlacement

# If you want ALL you icons to follow you around the desktop (Sticky), try
# this
#StickyIcons

CirculateSkipIcons

########################      MWM EMULATION     #######################
#
# My feeling is that everyone should use MWMDecorHints and MWMFunctionHints,
# since some applications depend on having the window manager respect them

# MWMFunction hints parses the function information in the MOTIF_WM_HINTS
# property, and prohibits use of these functions on the window. Appropriate
# portions of the window decorations are removed.
MWMFunctionHints

# MWMDecor hints parses the decoration information in the MOTIF_WM_HINTS
# property, and removes these decoratons from the window. This does not affect
# the functions that can be performed via the menus.
MWMDecorHints

# These are affect minor aspects for the look-and-feel.
# Sub-menus placement mwm-style?
# MWMMenus
# mwm-style border reliefs (less deep than default fvwm) ?
# MWMBorders
# Maximize button does mwm-inversion thingy
# MWMButtons
########################      MISCELLANEOUS STUFF     #######################
# If you don't like the default 150 msec click delay for the complex functions
# change this and uncomment it.
ClickTime 70

# OpaqueMove has a number (N) attached to it (default 5), if the window occupies
# less than N% of the screen, opaque move is used. 0 <= N <= 100
OpaqueMove 25

# percent of the screen to move when scrolling
EdgeScroll 10 10

# A modest delay before flipping pages seems to be nice...
# I thresh in a 50 pixel Move-resistance too, just so people
# can try it out.
EdgeResistance 1000 5

########################      WINDOW PLACEMENT     #######################
# RandomPlacement prevents user interaction while placing windows:
# RandomPlacement

# SmartPlacement makes new  windows pop-up in blank regions of screen if
# possible, otherwise falls back to random or interactive placement.
SmartPlacement

# With SmartPlacement, windows will normally place themselves over icons.
# Uncomment this to change that.
StubbornPlacement

# NoPPosition instructs fvwm to ignore the PPosition field in window
# geometry hints.  Emacs annoyingly sets PPosition to (0,0)!
NoPPosition

########################      DECORATIONS     #######################
# If you want decorated transient windows, uncomment this:
#DecorateTransients

##########################################################################
# Setup paths for icons and modules
#
# ModulePath is a colon-separated list, just like regular unix PATH
ModulePath /local/homes/dsp/nation/modules:/usr/lib/X11/fvwm

# Icon paths
PixmapPath  PIXMAPPATH
IconPath    ICONPATH

###########################################################################
# Set up the virtual desktop and pager

#set the desk top size in units of physical screen size
DeskTopSize 1x12

# and the reduction scale used for the panner/pager
DeskTopScale 48

# Use the Fvwm Pager
Pager -5 -5

#############################################################################
# Initialization Functions

Function "InitFunction"
#	Module "I"	FvwmBanner
EndFunction

############################################################################
# list the windows that don't want a title bar
Style "*" BorderWidth 0, HandleWidth 4, Color Black/#60a0c0,Icon Unknown.xpm
Style "*" CirculateHit
Style "zwgc" CirculateSkip,Sticky,BorderWidth 2,WindowListSkip
Style "xgsubrc" CirculateSkip,Sticky,BorderWidth 2,WindowListSkip,NoTitle
Style "xv" NoTitle,NoHandles,WindowListSkip,CirculateSkip
Style "Fvwm*" NoTitle, NoHandles,Sticky,StaysOnTop,WindowListSkip,CirculateSkip
Style "GoodStuff" NoTitle, NoHandles,Sticky,WindowListSkip
Style "*lock" NoTitle,NoHandles,Sticky,WindowListSkip,CirculateSkip,NoHandles
Style "*lock" StaysOnTop
Style "xmailbox" NoTitle,NoHandles,Sticky,WindowListSkip,CirculateSkip,NoHandles
Style "xmailbox" StaysOnTop
Style "xbiff" NoTitle,NoHandles,Sticky,WindowListSkip,CirculateSkip,NoHandles
Style "xbiff" StaysOnTop
Style "xload" NoTitle,NoHandles,Sticky,WindowListSkip,CirculateSkip,NoHandles
Style "xload" StaysOnTop
Style "4va*" NoTitle,NoHandles,Sticky,WindowListSkip,CirculateSkip,NoHandles
Style "GoodStuff" NoTitle
Style "?ppeed*" NoTitle
Style "pine" Icon mail_edit.xpm
Style "*saved*" Icon mailbox_full.xpm
Style "Applet Viewer*" Icon java-100.xpm
Style "ghost*" Icon ghostview.xpm
Style "xterm" Icon image-blank.xpm
Style "*HP-UX*" Icon HPMonitor.xpm
Style "*IRIX*" Icon SGI.xpm
Style "*SunOS*" Icon SunMicrosystemsMonitor.xpm
Style "*Linux*" Icon LinuxPenguin.xpm
Style "*BSD*" Icon Daemon.xpm
Style "Maple V Release *" Icon maple.xpm

############################################################################
# Now define some handy complex functions

# This one moves and then raises the window if you drag the mouse,
# only raises the window if you click,  or does a RaiseLower if you double 
# click
Function "Move-or-Raise"
	Move 		"Motion"
	Raise		"Motion"
	Raise		"Click"
	RaiseLower	"DoubleClick" 
EndFunction

# This one maximizes vertically if you click (leaving room for the GoodStuff
# bar at the bottom, or does a full maximization if you double click, or a
# true full vertical maximization if you just hold the mouse button down.

Function "maximize_func"
	Maximize	"Motion" 0 100
	Maximize	"Click" 0 90
	Maximize	"DoubleClick" 100 100
EndFunction

# This one moves and then lowers the window if you drag the mouse,
# only lowers the window if you click,  or does a RaiseLower if you double 
# click
Function "Move-or-Lower"
	Move 		"Motion"
	Lower		"Motion"
	Lower		"Click"
	RaiseLower	"DoubleClick"
EndFunction

# This one moves or (de)iconifies:
Function "Move-or-Iconify"
	Move 		"Motion"
	Iconify		"DoubleClick"
EndFunction

# This one resizes and then raises the window if you drag the mouse,
# only raises the window if you click,  or does a RaiseLower if you double 
# click
Function "Resize-or-Raise"
	Resize 		"Motion"
	Raise		"Motion"
	Raise		"Click"
	RaiseLower	"DoubleClick"
EndFunction

# This is provided as a hint only.
# Move to a known page on the desktop, then start an application in a 
# known location. Could also switch to a known desktop, I guess
#Function "abs_coord"
#	GoToPage "Immediate"	1,1
#	Exec	"Immediate"	exec xcalc -geometry +100+100&
#EndFunction

##############################################################################
#now define the menus - defer bindings until later

# This menu is invoked as a sub-menu - it allows you to quit,
# restart, or switch to another WM.
Popup "Quit-Verify"
	Title	"Really Quit Fvwm?"
	Quit	"Yes, Really Quit"
	Restart "Restart Fvwm"	fvwm
	Restart "Start twm" 	twm
	Restart "Start tvtwm" 	tvtwm
	Restart "Start mwm" 	mwm
	Restart "Start olwm" 	/usr/openwin/bin/olwm
	Nop	""
	Nop	"No, Don't Quit"
EndPopup

# Provides a list of modules to fire off
Popup "Module-Popup"
	Title	"Modules"
	Module	"GoodStuff"	GoodStuff
	Module	"NoClutter"	FvwmClean
	Module	"Identify"	FvwmIdent
	Move	"Move"
	Module  "SaveDesktop"   FvwmSave
	Module	"Debug"		FvwmDebug
	Module  "Pager"		FvwmPager 0 2
	Module  "Pager"		FvwmPager 1 2
EndPopup

Popup "Xlock-Popup"
	Exec "random" exec nice xlock -usefirst -mode random -fg black -bg white &
	Exec "swarm" exec nice xlock -usefirst -batchcount 1000 -mode swarm -fg black -bg white &
	Exec "galaxy" exec nice xlock -usefirst -mode galaxy -fg black -bg white &
	Exec "triangle" exec nice xlock -usefirst -mode triangle -fg black -bg white &
EndPopup

# This menu will fire up some very common utilities
Popup "Utilities"
	Title 	"Utilities"
	Exec	"Netscape"	exec netscape &
	Exec  "Pine"      exec rxvt -T pine -n pine -e pine &
	Exec    "Top"		exec rxvt -T Top -n Top -e top &
	Exec	"xv"			exec xv &
	Exec	"gvim"			exec gvim &
	Exec	"Xman"		exec xman &
	Nop	""
	Popup "xlock" Xlock-Popup
EndPopup

# This defines the most common window operations
Popup "System Ops"
	Title		"System Ops"
	Function	"Move" 			Move-or-Raise
	Function 	"Resize" 		Resize-or-Raise
	Raise   	"Raise"
	Lower   	"Lower"
	Iconify 	"(De)Iconify" 
	Stick		"(Un)Stick"
	Maximize 	"(Un)Maximize"
	Maximize 	"(Un)Maximize Vertical"	0 100
	Nop     	""
	Close	"Close"
	Destroy 	"Destroy"
	Delete  	"Delete"
	Nop	""
	Refresh	"Refresh Screen"
	Nop 	""
	Desk	"Next Desk"	1 0
	Desk	"Previous Desk" -1 0
   Nop   ""
	Restart "Restart Fvwm"	fvwm
	Popup	"Modules"	Module-Popup
	Quit "Quit"
EndPopup

# A trimmed down version of "Window Ops", good for binding to decorations
Popup "Window Ops2"
	Function 	"Move" 			Move-or-Raise
	Function  	"Resize" 		Resize-or-Raise
	Raise   	"Raise"
	Lower   	"Lower"
	Iconify 	"Iconify"
	Stick		"(Un)Stick"
	Nop     	""
	Close    "Close"
	Destroy 	"Destroy"
	Delete  	"Delete"
	Nop		""
	Module		"ScrollBar" 	FvwmScroll
EndPopup

Popup "Main Ops"
	Title "Main Ops"
	Restart "Restart Fvwm"	fvwm
	Popup	"Modules"	Module-Popup
	Quit "Quit"
EndPopup

Popup "CCO"
   LOGIN(morocco, morocco.cco.caltech.edu., red2, SunOS)
   LOGIN(stucco, stucco.cco.caltech.edu., red2, SunOS)
   LOGIN(accord, accord.cco.caltech.edu., red2, SunOS)
   LOGIN(piccolo, piccolo.cco.caltech.edu., red2, SunOS)
   LOGIN(ccosol, ccosol.cco.caltech.edu., red2, SunOS)
   LOGIN(ccosun, ccosun.cco.caltech.edu., red2, SunOS)
EndPopup

Popup "INFO"
   LOGIN(sphere.cs, sphere.cs.caltech.edu., PaleGoldenrod, SunOS)
   LOGIN(info.cs, info.cs.caltech.edu., PaleGoldenrod, SunOS)
EndPopup

Popup "CSSLOWSLOW"
   LOGIN(stun4t, stun4t.cs.caltech.edu., goldenrod1, SunOS)
EndPopup

Popup "CSSLOW"
   LOGIN(cello, cello.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(clarinet, clarinet.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(guitar, guitar.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(harpsichord, harpsichord.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(organ, organ.cs.caltech.edu., goldenrod1, BSD)
   Popup "Slower" CSSLOWSLOW
EndPopup

Popup "CS"
   LOGIN(cezanne, cezanne.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(chagall, chagall.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(da-vinci, da-vinci.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(gainsborough, gainsborough.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(gaugain, gaugain.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(michelangelo, michelangelo.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(monet, monet.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(picasso, picasso.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(raphael, raphael.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(rembrandt, rembrandt.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(renoir, renoir.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(rubens, rubens.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(toulouse-lautrec, toulouse-lautrec.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(vangogh, vangogh.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(varese, varese.cs.caltech.edu., goldenrod1, BSD)
   LOGIN(velasquez, velasquez.cs.caltech.edu., goldenrod1, BSD)
   Popup "Slower" CSSLOW
EndPopup

Popup "Other-Logins"
	Exec "naples" exec rxvt -ut -fg peachpuff -T "nfn02533@naples.net (BSD)" -n naples.net -e telnet -l nfn02533 naples.net &
	Exec "crack" exec rxvt -ut -fg peachpuff -T "wtanaka@crack (Linux)" -n crack -e telnet -l wtanaka crack &
	Exec "lard" exec ssh -f lard xterm -ls -fg peachpuff -bg black -T lard\\ \\\(Linux\\\) -n lard
	Exec "hotard" exec ssh -f hotard xterm -ls -fg peachpuff -bg black -T hotard\\ \\\(Linux\\\) -n hotard
	Exec "quad-brkt22" exec rxvt -ut -fg peachpuff -T "wtanaka@quad-brkt22 (Linux)" -n quad-brkt22 -e /usr/local/bin/ssh -l wtanaka quad-brkt22.colorado.edu. &
	Exec "uhics" exec rxvt -ut -fg peachpuff -T "wtanaka@uhics.ics.hawaii.edu (sol)" -n uhics.ics.hawaii.edu -e telnet -l wtanaka uhics.ics.hawaii.edu &
	Exec "grfn" exec rxvt -ut -fg peachpuff -T grfn -n grfn.org -e telnet -l wtanaka grfn.org &
	Exec "scn" exec rxvt -ut -fg peachpuff -T "scn (sol)" -n scn.org -e telnet -l be876 scn.org &
	Exec "jmrpoo" exec ssh -f jmrpoo /usr/X11R6/bin/xterm -ls -fg peachpuff -bg black -T jmrpoo\\ \\\(FreeBSD\\\) -n jmrpoo
EndPopup

Popup "UGSGISLOW"
   LOGIN(acro.ugcs, acro.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(agora.ugcs, agora.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(amatho.ugcs, amatho.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(arachno.ugcs, arachno.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(claustro.ugcs, claustro.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(mono.ugcs, mono.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(myxo.ugcs, myxo.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(necro.ugcs, necro.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(phobo.ugcs, phobo.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(photo.ugcs, photo.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(pyro.ugcs, pyro.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(xeno.ugcs, xeno.ugcs.caltech.edu., SteelBlue1, IRIX)
EndPopup

Popup "UGSGI"
	LOGIN(sgi.ugcs, sgi.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(auto.ugcs, auto.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(chaeto.ugcs, chaeto.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(hedono.ugcs, hedono.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(hydro.ugcs, hydro.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(hypno.ugcs, hypno.ugcs.caltech.edu., SteelBlue1, IRIX)
   LOGIN(taphe.ugcs, taphe.ugcs.caltech.edu., SteelBlue1, IRIX)
   Popup "Slower" UGSGISLOW
EndPopup

Popup "UGHPSLOW"
	LOGIN(beat, beat.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(chop, chop.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(whip, whip.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(crush, crush.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(liquefy, liquefy.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(pulp, pulp.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(puree, puree.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(shred, shred.ugcs.caltech.edu., SteelBlue1, HP-UX)
EndPopup

Popup "UGHP"
	LOGIN(hp.ugcs, hp.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(gluttony, gluttony.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(avarice, avarice.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(lust, lust.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(pride, pride.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(sloth, sloth.ugcs.caltech.edu., SteelBlue1, HP-UX)
	LOGIN(wrath, wrath.ugcs.caltech.edu., SteelBlue1, HP-UX)
	Popup "Slower" UGHPSLOW
EndPopup

Popup "UGCS"
   LOGIN(to.ugcs, to.ugcs.caltech.edu., SteelBlue1, \?)
   Popup "SGI" UGSGI
   Popup "HP" UGHP
EndPopup

Popup "Dabney"
   LOGIN(lenin, lenin.dabney.caltech.edu., green2, Linux)
EndPopup

Popup "Mongers"
   LOGIN(smonger, smonger.mongers.ml.org., MediumPurple2, Linux)
   LOGIN(fmonger, fmonger.mongers.ml.org., MediumPurple2, Linux)
   LOGIN(castor, castor.mongers.ml.org., MediumPurple2, Linux)
EndPopup

Popup "Logins"
	Exec "Random" exec RANDOM_SHELL &
   Popup "mongers" Mongers
	Popup "dabney" Dabney
	Popup "UGCS" UGCS
	Popup "CS" CS
   Popup "Infospheres" INFO
	Popup "CCO" CCO
EndPopup

#############################################################################
# One more complex function - couldn't be defined earlier because it used 
# pop-up menus
#
# This creates a motif-ish sticky menu for the title-bar window-ops
# pop-up
# Menu acts like normal twm menu if you just hold the button down,
# but if you click instead, the menu stays up, motif style
Function "window_ops_func"
	PopUp 	"Click"		Window Ops2
	PopUp	"Motion"	Window Ops2
# Motif would add
#       Delete  "DoubleClick"  
EndFunction


##############################################################################
# This defines the mouse bindings

# First, for the mouse in the root window
# Button 1 gives the Utilities menu
# Button 2 gives the Window Ops menu
# Button 3 gives the WindowList (like TwmWindows)
# I use the AnyModifier (A) option for the modifier field, so you can hold
# down
# any shift-control-whatever combination you want!
# Note the use of "Mouse 0" for AnyButton.

#Button     Context Modifi Function
Mouse 1     R       N      WindowList
Mouse 2     R       N      PopUp "System Ops"
Mouse 1     R       M      PopUp "System Ops"
Mouse 3     R       N      PopUp "Logins"
Mouse 1     R       C      PopUp "Logins"
Mouse 1		2    	  A      	Function "window_ops_func"
Mouse 1		4    	  A     	Function "maximize_func"
Mouse 1		6    	  A     	Iconify
Mouse 2     2       M        Move
Mouse 2     4       M        Move
Mouse 2     6       M        Move

Mouse 1  I  N  Iconify
Mouse 1 246ITWFS M Function "Move-or-Raise"
Mouse 1 T N Function "Move-or-Raise"
Mouse 1 FS N Resize

Mouse 2 246ITWFS M Function "Move-or-Lower"
Mouse 2 T N Function "Move-or-Lower"

Mouse 3 T N RaiseLower
Mouse 3 246FS N RaiseLower
Mouse 3 I246TWFS M RaiseLower

#Mouse 3         R	A	Module "t" FvwmWinList transient
############################################################################
# Now some keyboard shortcuts.

# Arrow Keys
# press arrow + control anywhere, and scroll by 1 page
Key Left	A	MC	Scroll -100 0
Key Right	A	MC	Scroll +100 +0
Key Up		A	MC	Scroll +0   -100
Key Down	A	MC	Scroll +0   +100

# press arrow + meta key, and scroll by 1/10 of a page
#Key Left	A	C	Scroll -10 +0
#Key Right	A	C	Scroll +10 +0
#Key Up		A	C	Scroll +0   -10
#Key Down	A	C	Scroll +0   +10

# press shift arrow + control anywhere, and move the pointer by 1% of a page
#Key Left	A	SC	CursorMove -1 0
#Key Right	A	SC	CursorMove +1 +0
#Key Up		A	SC	CursorMove +0   -1
#Key Down	A	SC	CursorMove +0   +1

# press shift arrow + meta key, and move the pointer by 1/10 of a page
#Key Left	A	SM	CursorMove -10 +0
#Key Right	A	SM	CursorMove +10 +0
#Key Up		A	SM	CursorMove +0   -10
#Key Down	A	SM	CursorMove +0   +10

#Circulate
Key Tab A M CirculateDown
Key Tab A MS CirculateUp

#No mouse keys
#Key n A CM Exec "random_rxvt" ~/bin/random_rxvt &
Key b A CM Exec "brown" exec rxvt -fg black -bg \#cccc99 -T wtanaka@smonger
Key c 124ITWFS CM Close
Key h A CM CursorMove -1 +0
Key i A CM Iconify
Key j A CM CursorMove +0 +1
Key k A CM CursorMove +0 -1
Key l A CM CursorMove +1 +0
Key m A CM Move
Key n A CM PopUp "Logins"
Key r A CM Resize
Key s A CM Stick
Key w A CM WindowList
Key z A CM Restart "Restart Fvwm"	fvwm

Key space 124ITWFS CM RaiseLower
Key Return 124ITWFS CM Focus

# Keyboard accelerators
Key F1		A	M	GoToPage 0,0
Key F2		A	M	GoToPage 0,1
Key F3		A	M	GoToPage 0,2
Key F4		A	M	GoToPage 0,3
Key F5		A	M	GoToPage 0,4
Key F6		A	M	GoToPage 0,5
Key F7		A	M	GoToPage 0,6
Key F8		A	M	GoToPage 0,7
Key F9		A	M	GoToPage 0,8
Key F10		A	M	GoToPage 0,9
Key F11		A	M	GoToPage 0,10
Key F12		A	M	GoToPage 0,11

#Page Up/Dapge Down keys are used to scroll by one desktop page
# in any context, press page up/down + control
# in root context, just pressing page up/down is OK
# 
# I prefer the non-wrapping scroll. These are for example purposes only
#Key Next	A       C       Scroll 100000 0
#Key Next	R       N       Scroll 100000 0  
#Key Prior	A       C       Scroll -100000 0
#Key Prior	R       N       Scroll -100000 0


############################################################################
############################################################################
#Definitions used by the modules

###################### GoodStuff button-bar ################################
# Colors

# Geometry - really likes to pick its own size, but giving a position is OK
*GoodStuffGeometry +0-1

# Layout: specify rows or columns, not both
# *GoodStuffColumns 1
*GoodStuffRows 1

# Define the buttons to use.....
*GoodStuff Raise   Up    Popup "Window Ops2"

*GoodStuff Paging  clamp.xpm   TogglePage

#Buttons for some other desktops.
*GoodStuff Desk-0  desk.xpm    Desk 0 0
*GoodStuff Desk-1  desk.xpm    Desk 0 1
*GoodStuff Desk-2  desk.xpm    Desk 0 2
*GoodStuff Desk-3  desk.xpm    Desk 0 3

######################### No Clutter ########################################
# I only wrote NoClutter as a simple test case, but maybe some big sites like
# universities really have usage problems (too many open windows)....
# Time delays are in seconds.
*FvwmNoClutter 3600 Iconify 1
*FvwmNoClutter 86400 Delete
*FvwmNoCLutter 172800 Destroy

*FvwmPagerGeometry -1-1
*FvwmPagerColumns 1

