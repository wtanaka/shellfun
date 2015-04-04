cat <<\TEMPLATEQUOTE
XDvi.grey: true
XDvi.reverseVideo: true
XDvi.expert: true

XTerm*background: black
XTerm*foreground: white
XTerm.VT100.geometry: 80x25
XTerm.VT100.scrollBar: False
XTerm.VT100.font: -*-fixed-medium-r-*-*-12-*-*-*-*-*-*-*
XTerm.VT100.colorBDMode: false
XTerm*VT100*translations: #override \
        Shift           <Btn4Down>: scroll-back(1,line)         \n\
        Ctrl            <Btn4Down>: scroll-back(1,halfpage)     \n\
        Alt             <Btn4Down>: scroll-back(10,page)        \n\
                        <Btn4Down>: scroll-back(5,line)         \n\
        Shift           <Btn5Down>: scroll-forw(1,line)         \n\
        Ctrl            <Btn5Down>: scroll-forw(1,halfpage)     \n\
        Alt             <Btn5Down>: scroll-forw(10,page)        \n\
                        <Btn5Down>: scroll-forw(5,line)

!# In the scrollbar we map buttons 5 & 4 to 1 and 2 otherwise, core dump
!# This will move proportionnaly to cursor position but we dont know how to
!# program the same exact behavior as in the text widget.
XTerm.vt100.Scrollbar.translations: #override\n\
     <Btn5Down>: StartScroll(Forward)\n\
     <Btn4Down>: StartScroll(Backward)\n\

!Netscape*globalTranslations: #override \
!        Shift           <Btn4Down>: LineUp()                    \n\
!        Ctrl            <Btn4Down>: PageUp()                    \n\
!        Alt             <Btn4Down>: PageUp(3)                   \n\
!                        <Btn4Down>: LineUp(5)                   \n\
!        Shift           <Btn5Down>: LineDown()                  \n\
!        Ctrl            <Btn5Down>: PageDown()                  \n\
!        Alt             <Btn5Down>: PageDown(3)                 \n\
!                        <Btn5Down>: LineDown(5)

!## NETSCAPE
Netscape*drawingArea.translations:  #replace    \
        <Btn1Down>:           ArmLink()   \n\
        <Btn2Down>:           ArmLink()   \n\
        ~Shift<Btn1Up>:       ActivateLink()  \n\
        ~Shift<Btn2Up>:       ActivateLink(new-window)  \
                                        DisarmLink()    \n\
        Shift<Btn1Up>:        ActivateLink(save-only)  \
                                        DisarmLink()    \n\
        Shift<Btn2Up>:        ActivateLink(save-only)  \
                                        DisarmLink()    \n\
        <Btn1Motion>:             DisarmLinkIfMoved()  \n\
        <Btn2Motion>:             DisarmLinkIfMoved()  \n\
        <Btn3Motion>:             DisarmLinkIfMoved()  \n\
        <Motion>:             DescribeLink()  \n\
        <Btn3Down>:           xfeDoPopup()    \n\
        <Btn3Up>:             ActivatePopup() \n\
        Ctrl<Btn4Down>: PageUp()\n\
        Ctrl<Btn5Down>: PageDown()\n\
        Shift<Btn4Down>: LineUp()\n\
        Shift<Btn5Down>: LineDown()\n\
         None<Btn4Down>: LineUp()LineUp()LineUp()LineUp()LineUp()LineUp()\n\
         None<Btn5Down>: LineDown()LineDown()LineDown()LineDown()LineDown()LineDown()\n\
        Alt<Btn4Down>: xfeDoCommand(forward)\n\
        Alt<Btn5Down>: xfeDoCommand(back)\n

Netscape*globalNonTextTranslations: #override\n\
 Shift<Btn4Down>: LineUp()\n\
 Shift<Btn5Down>: LineDown()\n\
 None<Btn4Down>:LineUp()LineUp()LineUp()LineUp()LineUp()LineUp()\n\
 None<Btn5Down>:LineDown()LineDown()LineDown()LineDown()LineDown()LineDown()\n\
 Alt<Btn4Down>: xfeDoCommand(forward)\n\
 Alt<Btn5Down>: xfeDoCommand(back)\n

Netscape*composeFolder.shadowThickness:                 1
Netscape*newComposeFolder*attachItemImage.highlightThickness:      1
Netscape*XmPushButton*shadowThickness: 1 
Netscape*XmPushButtonGadget*shadowThickness: 1 
Netscape*XmCascadeButton.shadowThickness: 1
Netscape*XmCascadeButtonGadget.shadowThickness: 1
Netscape*drawingArea*XmList.highlightThickness: 1
Netscape*alignmentRowColumn*XmToggleButtonGadget.shadowThickness: 1
Netscape*XmDialogShell*highlightThickness:      1
Netscape*toolBar*XmSeparator.shadowThickness:   0
Netscape*Composition*XmTextField.highlightThickness:    1
Netscape*Composition*XmText.highlightThickness:         1

rxvt.background: black
rxvt.foreground: white
rxvt.geometry: 80x25
rxvt.font: -*-fixed-medium-r-*-*-12-*-*-*-*-*-*-*
rxvt.scrollBar: False
rxvt.mapAlert: true

cxterm*VT100.Translations: #override \
          <KeyPress> F1:     set-HZ-parameter(input-conv=toggle) \n\
          <KeyPress> F2:     switch-HZ-mode(IC) \n\
          <KeyPress> F3:     popup-panel(config) \n\
   ~Shift <KeyPress> F4:     switch-HZ-mode(TONEPY) \n\
    Shift <KeyPress> F4:     switch-HZ-mode(PY) \n\
   ~Shift <KeyPress> F5:     switch-HZ-mode(WuBi) \n\
    Shift <KeyPress> F5:     switch-HZ-mode(CangJie) \n\
   ~Meta <KeyPress> Escape:     insert() set-HZ-parameter(input-conv=off)

XGsub*background:           lemonChiffon4
XGsub*header.background:    lemonChiffon2
XGsub*header.foreground:    black
XGsub*header.font:          6x13
XGsub*message.background:   white
XGsub*message.foreground:   black
XGsub*message.font:         6x13
XGsub*geometry:             +200+300
XGsub*message*vertDistance: 0
XGsub*puff*defaultDistance: 2

XFontSel*fieldBox*field2.menu*font: -misc-fixed-medium-r-normal--7-*-*-*-c-50-iso8859-1
XFontSel*fieldBox*field1.menu*font: -misc-fixed-medium-r-normal--7-*-*-*-c-50-iso8859-1
*fieldBox*field1.menu.Options.ShowUnselectable: False

Zwgc*reverseStack:              false
Zwgc*minTimeToLive:             1000
Zwgc*resetSaver:                off
!Zwgc*style.message.personal*geometry:   -0+0
!Zwgc*style.login*geometry:      +0+0
!Zwgc*style.mail*geometry:       -0-0
Zwgc*transient:                 true
zwgc*style*substyle.default.fontfamily: charter
Zwgc.foreground: SlateGray1
Zwgc.background: Black

XMailbox.geometry: +0+20
xmailbox*volume:   50
xmailbox*update:   1
xmailbox*onceOnly:		true
xmailbox*mailNumOfXpmFile:	1
xmailbox*mailAnimOnce:		true
xmailbox*mailSndFile:      /net/smonger/drop/audio/youvegotmail.au
xmailbox*mailSndComm:      /usr/local/bin/rplay %s
xmailbox*mailAnimUpdate:   1000
xmailbox*mailapp:          echo 'LINES=25; COLUMNS=80; export LINES; export COLUMNS; rxvt -n pine -e pine' | /bin/sh -s
!xmailbox*nomailXpmFile:    /net/smonger/drop/pixmaps/ToasterEmpty.xpm
!xmailbox*mailXpmFile:      /net/smonger/drop/pixmaps/ToasterFull.xpm
!xmailbox*nomailXpmFile:    /net/smonger/drop/pixmaps/DisketteBoxEmpty.xpm
!xmailbox*mailXpmFile:      /net/smonger/drop/pixmaps/DisketteBoxFull.xpm

*fontfamily.charter.small.roman:          *-charter-medium-r-*-80-*-p-*
*fontfamily.charter.small.bold:           *-charter-bold-r-*-80-*-p-*
*fontfamily.charter.small.italic: *-charter-medium-i-*-80-*-p-*
*fontfamily.charter.small.bolditalic: *-charter-bold-i-*-80-*-p-*
*fontfamily.charter.medium.roman: *-charter-medium-r-*-120-*-p-*
*fontfamily.charter.medium.bold: *-charter-bold-r-*-120-*-p-*
*fontfamily.charter.medium.italic: *-charter-medium-i-*-120-*-p-*
*fontfamily.charter.medium.bolditalic: *-charter-bold-i-*-120-*-p-*
*fontfamily.charter.large.roman: *-charter-medium-r-*-240-*-p-*
*fontfamily.charter.large.bold: *-charter-bold-r-*-240-*-p-*
*fontfamily.charter.large.italic: *-charter-medium-i-*-240-*-p-*
*fontfamily.charter.large.bolditalic: *-charter-bold-i-*-240-*-p-*

*fontfamily.times.small.roman:          *adobe-times-medium-r-*-80-*-p-*
*fontfamily.times.small.bold:           *adobe-times-bold-r-*-80-*-p-*
*fontfamily.times.small.italic: *adobe-times-medium-i-*-80-*-p-*
*fontfamily.times.small.bolditalic: *adobe-times-bold-i-*-80-*-p-*
*fontfamily.times.medium.roman: *adobe-times-medium-r-*-120-*-p-*
*fontfamily.times.medium.bold: *adobe-times-bold-r-*-120-*-p-*
*fontfamily.times.medium.italic: *adobe-times-medium-i-*-120-*-p-*
*fontfamily.times.medium.bolditalic: *adobe-times-bold-i-*-120-*-p-*
*fontfamily.times.large.roman: *adobe-times-medium-r-*-240-*-p-*
*fontfamily.times.large.bold: *adobe-times-bold-r-*-240-*-p-*
*fontfamily.times.large.italic: *adobe-times-medium-i-*-240-*-p-*
*fontfamily.times.large.bolditalic: *adobe-times-bold-i-*-240-*-p-*

*ttyModes: intr ^C erase ^? susp ^Z kill ^U

*VT100.Translations:	#override <Key>Delete: string(0x1b) string("[3~")\n\
	<Key>Home: string(0x1b) string("[1~")\n\
	<Key>End: string(0x1b) string("[4~")\n\
	Ctrl<Key>Prior: string(0x1b) string("[40~")\n\
	Ctrl<Key>Next: string(0x1b) string("[41~")\n\
	<Key>KP_Decimal: string(0x1b) string("[3~")\n

XDaliClock.seconds: false
XDaliClock*cycle: true
XDaliClock.shape: true
XDaliClock*memory: low
XDaliClock*font: -*-lucida-*-r-*-*-*-190-*-*-*-*-*-*
XDaliClock*mode: 24
XDaliClock.geometry: 90x25-0+0

xscreensaver.timeout: 3
xscreensaver.lock: true
xscreensaver.lockTimeout: 2
xscreensaver.splash: false
xscreensaver.cycle: 10
xscreensaver.nice: 19
xscreensaver.fade: false
xscreensaver.unfade: false
xscreensaver.installColormap: false
!xscreensaver.visualID: PseudoColor

xearth.pos: fixed 34.08 -118.08
xearth.gamma: 1.47
xearth.label: true
xearth.labelpos: -0+0
xearth.night: 5
xearth.wait: 300
xearth.fork: true
xearth.nice: 19
xearth.ncolors: 16

XLock.mode: blank
XLock.font: -b&h-lucida-medium-r-normal-sans-24-*-*-*-*-*-iso8859-1
XLock.background: White
XLock.foreground: Black
XLock.username: Name: 
XLock.password: Password: 
XLock.info: Enter password to unlock; select icon to lock.
XLock.validate: Validating login...
XLock.invalid: Invalid login.
XLock.geometry: 
XLock.nice: 10
XLock.timeout: 30
XLock.lockdelay: 0
XLock.mono: off
XLock.enablesaver: off
XLock.allowaccess: off
XLock.grabmouse: on
XLock.echokeys: off
XLock.usefirst: on
XLock.verbose: off
XLock.timeelapsed: off
XLock.install: on
XLock.use3d: off
XLock.delta3d: 1.5
XLock.right3d: rgb:ffff/0/0
XLock.left3d: rgb:0/ffff/0
XLock.program: fortune -s
XLock.messagesfile: 
XLock.messagefile: 
XLock.message: 
XLock.mfont: -*-times-*-*-*-*-18-*-*-*-*-*-*-*
XLock.ant.delay: 1000
XLock.ant.batchcount: 1
XLock.ant.cycles: 32767
XLock.ant.saturation: 1
XLock.bat.delay: 100000
XLock.bat.batchcount: 6
XLock.bat.cycles: 20
XLock.bat.saturation: 1
XLock.blot.delay: 100000
XLock.blot.batchcount: 6
XLock.blot.cycles: 30
XLock.blot.saturation: 0.4
XLock.bouboule.delay: 1000
XLock.bouboule.batchcount: 100
XLock.bouboule.cycles: 15
XLock.bouboule.saturation: 1
XLock.bounce.delay: 10000
XLock.bounce.batchcount: 10
XLock.bounce.cycles: 20
XLock.bounce.saturation: 1
XLock.braid.delay: 1000
XLock.braid.batchcount: 15
XLock.braid.cycles: 30
XLock.braid.saturation: 1
XLock.bug.delay: 75000
XLock.bug.batchcount: 10
XLock.bug.cycles: 32767
XLock.bug.saturation: 1
XLock.clock.delay: 100000
XLock.clock.batchcount: 30
XLock.clock.cycles: 200
XLock.clock.saturation: 1
XLock.demon.delay: 750000
XLock.demon.batchcount: 16
XLock.demon.cycles: 1000
XLock.demon.saturation: 1
XLock.flame.delay: 750000
XLock.flame.batchcount: 20
XLock.flame.cycles: 10000
XLock.flame.saturation: 1
XLock.forest.delay: 100000
XLock.forest.batchcount: 100
XLock.forest.cycles: 200
XLock.forest.saturation: 1
XLock.galaxy.delay: 100
XLock.galaxy.batchcount: 3
XLock.galaxy.cycles: 20
XLock.galaxy.saturation: 1
XLock.geometry.delay: 2000
XLock.geometry.batchcount: 8
XLock.geometry.cycles: 20
XLock.geometry.saturation: 1
XLock.grav.delay: 10000
XLock.grav.batchcount: 10
XLock.grav.cycles: 20
XLock.grav.saturation: 1
XLock.helix.delay: 10000
XLock.helix.batchcount: 1
XLock.helix.cycles: 100
XLock.helix.saturation: 1
XLock.hop.delay: 10000
XLock.hop.batchcount: 1000
XLock.hop.cycles: 2500
XLock.hop.saturation: 1
XLock.hyper.delay: 10000
XLock.hyper.batchcount: 1
XLock.hyper.cycles: 300
XLock.hyper.saturation: 1
XLock.image.delay: 2000000
XLock.image.batchcount: 1
XLock.image.cycles: 20
XLock.image.saturation: 1
XLock.kaleid.delay: 2000
XLock.kaleid.batchcount: 4
XLock.kaleid.cycles: 700
XLock.kaleid.saturation: 1
XLock.laser.delay: 5000
XLock.laser.batchcount: 10
XLock.laser.cycles: 200
XLock.laser.saturation: 1
XLock.life.delay: 750000
XLock.life.batchcount: 40
XLock.life.cycles: 140
XLock.life.saturation: 1
XLock.life1d.delay: 2500000
XLock.life1d.batchcount: 10
XLock.life1d.cycles: 10
XLock.life1d.saturation: 1
XLock.life3d.delay: 1000000
XLock.life3d.batchcount: 35
XLock.life3d.cycles: 85
XLock.life3d.saturation: 1
XLock.marquee.delay: 100000
XLock.marquee.batchcount: 10
XLock.marquee.cycles: 20
XLock.marquee.saturation: 1
XLock.maze.delay: 10000
XLock.maze.batchcount: 40
XLock.maze.cycles: 300
XLock.maze.saturation: 1
XLock.mountain.delay: 10000
XLock.mountain.batchcount: 30
XLock.mountain.cycles: 100
XLock.mountain.saturation: 1
XLock.nose.delay: 100000
XLock.nose.batchcount: 10
XLock.nose.cycles: 20
XLock.nose.saturation: 1
XLock.petal.delay: 10000
XLock.petal.batchcount: 500
XLock.petal.cycles: 100
XLock.petal.saturation: 1
XLock.pyro.delay: 15000
XLock.pyro.batchcount: 40
XLock.pyro.cycles: 20
XLock.pyro.saturation: 1
XLock.qix.delay: 30000
XLock.qix.batchcount: 100
XLock.qix.cycles: 64
XLock.qix.saturation: 1
XLock.rock.delay: 20000
XLock.rock.batchcount: 100
XLock.rock.cycles: 20
XLock.rock.saturation: 0.2
XLock.rotor.delay: 10000
XLock.rotor.batchcount: 4
XLock.rotor.cycles: 20
XLock.rotor.saturation: 0.4
XLock.shape.delay: 10000
XLock.shape.batchcount: 100
XLock.shape.cycles: 256
XLock.shape.saturation: 1
XLock.slip.delay: 50000
XLock.slip.batchcount: 35
XLock.slip.cycles: 50
XLock.slip.saturation: 1
XLock.sphere.delay: 10000
XLock.sphere.batchcount: 1
XLock.sphere.cycles: 20
XLock.sphere.saturation: 1
XLock.spiral.delay: 5000
XLock.spiral.batchcount: 6
XLock.spiral.cycles: 350
XLock.spiral.saturation: 1
XLock.spline.delay: 30000
XLock.spline.batchcount: 100
XLock.spline.cycles: 20
XLock.spline.saturation: 0.4
XLock.swarm.delay: 10000
XLock.swarm.batchcount: 100
XLock.swarm.cycles: 20
XLock.swarm.saturation: 1
XLock.swirl.delay: 5000
XLock.swirl.batchcount: 5
XLock.swirl.cycles: 20
XLock.swirl.saturation: 1
XLock.triangle.delay: 100000
XLock.triangle.batchcount: 100
XLock.triangle.cycles: 30
XLock.triangle.saturation: 1
XLock.wator.delay: 750000
XLock.wator.batchcount: 4
XLock.wator.cycles: 32767
XLock.wator.saturation: 1
XLock.world.delay: 100000
XLock.world.batchcount: 8
XLock.world.cycles: 20
XLock.world.saturation: 0.3
XLock.worm.delay: 10000
XLock.worm.batchcount: 20
XLock.worm.cycles: 20
XLock.worm.saturation: 1
XLock.blank.delay: 3000000
XLock.blank.batchcount: 1
XLock.blank.cycles: 20
XLock.blank.saturation: 1
XLock.random.delay: 1
XLock.random.batchcount: 0
XLock.random.cycles: 0
XLock.random.saturation: 0
TEMPLATEQUOTE
