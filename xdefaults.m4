include(functions.m4)dnl
include(init.m4)dnl
include(shells.m4)dnl
changequote({{, }})dnl
rxvt.background: black
rxvt.foreground: white
rxvt.geometry: 80x25
rxvt.font: -*-fixed-medium-r-*-*-12-*-*-*-*-*-*-*
rxvt.scrollBar: False
rxvt.mapAlert: true

ifelse(SYS_HOST,{{castor.mongers.ml.org}},
{{!## NETSCAPE
Netscape*drawingArea.translations:      #replace        \
        <Btn1Down>:                     ArmLink()       \n\
        <Btn2Down>:                     ArmLink()       \n\
        ~Shift<Btn1Up>:                 ActivateLink()  \n\
        ~Shift<Btn2Up>:                 ActivateLink(new-window)  \
                                        DisarmLink()    \n\
        Shift<Btn1Up>:                  ActivateLink(save-only)  \
                                        DisarmLink()    \n\
        Shift<Btn2Up>:                  ActivateLink(save-only)  \
                                        DisarmLink()    \n\
        <Btn1Motion>:                   DisarmLinkIfMoved()  \n\
        <Btn2Motion>:                   DisarmLinkIfMoved()  \n\
        <Btn3Motion>:                   DisarmLinkIfMoved()  \n\
        <Motion>:                       DescribeLink()  \n\
        <Btn3Down>:                     xfeDoPopup()    \n\
        <Btn3Up>:                       ActivatePopup() \n\
        Ctrl<Btn4Down>: PageUp()\n\
        Ctrl<Btn5Down>: PageDown()\n\
        Shift<Btn4Down>: LineUp()\n\
        Shift<Btn5Down>: LineDown()\n\
         None<Btn4Down>: LineUp()LineUp()LineUp()LineUp()LineUp()LineUp()\n\
         None<Btn5Down>:
LineDown()LineDown()LineDown()LineDown()LineDown()LineDown()\n\
        Alt<Btn4Down>: xfeDoCommand(forward)\n\
        Alt<Btn5Down>: xfeDoCommand(back)\n

Netscape*globalNonTextTranslations: #override\n\
 Shift<Btn4Down>: LineUp()\n\
 Shift<Btn5Down>: LineDown()\n\
 None<Btn4Down>:LineUp()LineUp()LineUp()LineUp()LineUp()LineUp()\n\
 None<Btn5Down>:LineDown()LineDown()LineDown()LineDown()LineDown()LineDown()\n\
 Alt<Btn4Down>: xfeDoCommand(forward)\n\
 Alt<Btn5Down>: xfeDoCommand(back)\n
}})
