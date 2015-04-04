casehost()
{
  cat <<TEMPLATEQUOTE
    $1|${1}.*)
      HOST="$2"
      FG="$3"
      BG="$4"
      ;;
TEMPLATEQUOTE
}

cat <<\TEMPLATEQUOTE
#!/bin/sh
SERVER="HERE"
TERM="xterm"
HOST=""
FG="white"
BG="black"
COMPRESS="";

makewin()
{
  case $@ in
TEMPLATEQUOTE

casehost "cco" "cco.caltech.edu." "red2" "black"
casehost "morocco" "morocco.cco.caltech.edu." "red2" "black"
casehost "stucco" "stucco.cco.caltech.edu." "red2" "black"

casehost "lenin" "lenin.dabney.caltech.edu." "green2" "black"

casehost "to" "uglab.best.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "hp" "ughp.best.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "sgi" "ugsgi.best.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "intel" "ugintel.best.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "acro" "acro.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "agora" "agora.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "amatho" "amatho.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "arachno" "arachno.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "auto" "auto.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "baht" "baht.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "barf" "barf.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "beg" "beg.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "bolivar" "bolivar.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "chunder" "chunder.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "crush" "crush.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "cruzeiro" "cruzeiro.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "dinar" "dinar.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "drachma" "drachma.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "gluttony" "gluttony.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "groat" "groat.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "gurg" "gurg.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "hedono" "hedono.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "hork" "hork.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "hurl" "hurl.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "lek" "lek.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "lira" "lira.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "mono" "mono.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "myxo" "myxo.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "necro" "necro.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "pyro" "pyro.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "retch" "retch.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "riyal" "riyal.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "spew" "spew.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "taphe" "taphe.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "triskaideka" "triskaideka.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "upchuck" "upchuck.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "vomit" "vomit.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "xeno" "xeno.ugcs.caltech.edu." "SteelBlue1" "black"
casehost "yak" "yak.ugcs.caltech.edu." "SteelBlue1" "black"

casehost "lugh" "lugh.cacr.caltech.edu." "PapayaWhip" "black"
casehost "trex" "trex.cacr.caltech.edu." "PapayaWhip" "black"

casehost "jotunheim" "jotunheim.caltech.edu." "MediumSpringGreen" "black"
casehost "lard" "lard" "MediumSpringGreen" "black"
casehost "lolita" "lolita.dabney.caltech.edu." "MediumSpringGreen" "black"
casehost "fruity" "fruity.dabney.caltech.edu." "MediumSpringGreen" "black"
casehost "dewinter" "dewinter.dabney.caltech.edu." "MediumSpringGreen" "black"
casehost "yojackson" "yojackson.dabney.caltech.edu." "MediumSpringGreen" "black"

casehost "colostomy" "colostomy.bitfield.org." "MistyRose" "black"
casehost "darbly" "darbly.mit.edu" "MistyRose" "black"
casehost "girgle" "girgle.dabney.caltech.edu." "MistyRose" "black"
casehost "quantum" "quantum.caltech.edu." "MistyRose" "black"

casehost "icsi" "login.icsi.berkeley.edu." "LightSteelBlue" "black"
casehost "icsi2" "login2.icsi.berkeley.edu." "LightSteelBlue" "black"
casehost "crawdad" "crawdad.icsi.berkeley.edu." "LightSteelBlue" "black"
casehost "fondue" "fondue.icsi.berkeley.edu." "LightSteelBlue" "black"
casehost "sausage" "sausage.icsi.berkeley.edu." "LightSteelBlue" "black"

casehost "admiral" "admiral.i." "LightSteelBlue" "black"
casehost "agama" "agama.i." "LightSteelBlue" "black"
casehost "agni" "agni.i." "LightSteelBlue" "black"
casehost "alfalfa" "alfalfa.i." "LightSteelBlue" "black"
casehost "anglewing" "anglewing.i." "LightSteelBlue" "black"
casehost "anubis" "anubis.i." "LightSteelBlue" "black"
casehost "anuket" "anuket.i." "LightSteelBlue" "black"
casehost "aten" "aten.i." "LightSteelBlue" "black"
casehost "atman" "atman.i." "LightSteelBlue" "black"
casehost "atum" "atum.i." "LightSteelBlue" "black"
casehost "bast" "bast.i." "LightSteelBlue" "black"
casehost "bes" "bes.i." "LightSteelBlue" "black"
casehost "blue" "blue.i." "LightSteelBlue" "black"
casehost "buckeye" "buckeye.i." "LightSteelBlue" "black"
casehost "checkerspot" "checkerspot.i." "LightSteelBlue" "black"
casehost "copper" "copper.i." "LightSteelBlue" "black"
casehost "crescent" "crescent.i." "LightSteelBlue" "black"
casehost "cerius" "cerius.i." "LightSteelBlue" "black"
casehost "darkhorse" "darkhorse.ispheres.com." "LightSteelBlue" "black"
casehost "dazzler" "dazzler.i." "LightSteelBlue" "black"
casehost "dragontail" "dragontail.i." "LightSteelBlue" "black"
casehost "edjo" "edjo.i." "LightSteelBlue" "black"
casehost "fritillary" "fritillary.i." "LightSteelBlue" "black"
casehost "harvest" "harvest.i." "LightSteelBlue" "black"
casehost "isis" "isis.i." "LightSteelBlue" "black"
casehost "kali" "kali.i." "LightSteelBlue" "black"
casehost "krishna" "krishna.i." "LightSteelBlue" "black"
casehost "lady" "lady.i." "LightSteelBlue" "black"
casehost "monarch" "monarch.i." "LightSteelBlue" "black"
casehost "moth" "moth.i." "LightSteelBlue" "black"
casehost "nymph" "nymph.i." "LightSteelBlue" "black"
casehost "parnassian" "parnassian.i." "LightSteelBlue" "black"
casehost "queen" "queen.i." "LightSteelBlue" "black"
casehost "ra" "ra.i." "LightSteelBlue" "black"
casehost "satyr" "satyr.i." "LightSteelBlue" "black"
casehost "shiva" "shiva.i." "LightSteelBlue" "black"
casehost "skippers" "skippers.i." "LightSteelBlue" "black"
casehost "snout" "snout.i." "LightSteelBlue" "black"
casehost "sulphur" "sulphur.i." "LightSteelBlue" "black"
casehost "sura" "sura.i." "LightSteelBlue" "black"
casehost "swallowtail" "swallowtail.i." "LightSteelBlue" "black"
casehost "swati" "swati.i." "LightSteelBlue" "black"
casehost "varuna" "varuna.i." "LightSteelBlue" "black"
casehost "viceroy" "viceroy.i." "LightSteelBlue" "black"
casehost "white" "white.i." "LightSteelBlue" "black"
casehost "yama" "yama.i." "LightSteelBlue" "black"

casehost "spica" "spica.mili.eu.org." "thistle2" "black"
casehost "altair" "altair.mili.eu.org." "thistle2" "black"
casehost "smonger" "smonger.mili.eu.org." "thistle2" "black"
casehost "fmonger" "fmonger.mili.eu.org." "thistle2" "black"
casehost "castor" "castor.mili.eu.org." "thistle2" "black"

casehost "ofb" "ofb.net." "PaleGoldenrod" "black"

casehost "maestro" "maestro.cs.caltech.edu." "GoldenRod1" "black"
casehost "cezanne" "cezanne.cs.caltech.edu." "GoldenRod1" "black"
casehost "chagall" "chagall.cs.caltech.edu." "GoldenRod1" "black"
casehost "da-vinci" "da-vinci.cs.caltech.edu." "GoldenRod1" "black"
casehost "gainsborough" "gainsborough.cs.caltech.edu." "GoldenRod1" "black"
casehost "gaugain" "gaugain.cs.caltech.edu." "GoldenRod1" "black"
casehost "michelangelo" "michelangelo.cs.caltech.edu." "GoldenRod1" "black"
casehost "monet" "monet.cs.caltech.edu." "GoldenRod1" "black"
casehost "picasso" "picasso.cs.caltech.edu." "GoldenRod1" "black"
casehost "raphael" "raphael.cs.caltech.edu." "GoldenRod1" "black"
casehost "rembrandt" "rembrandt.cs.caltech.edu." "GoldenRod1" "black"
casehost "renoir" "renoir.cs.caltech.edu." "GoldenRod1" "black"
casehost "rubens" "rubens.cs.caltech.edu." "GoldenRod1" "black"
casehost "toulouse-lautrec" "toulouse-lautrec.cs.caltech.edu." "GoldenRod1" "black"
casehost "vangogh" "vangogh.cs.caltech.edu." "GoldenRod1" "black"
casehost "varese" "varese.cs.caltech.edu." "GoldenRod1" "black"
casehost "velasquez" "velasquez.cs.caltech.edu." "GoldenRod1" "black"

casehost "piano" "piano.cs.caltech.edu." "GoldenRod2" "black"
casehost "harp" "harp.cs.caltech.edu." "GoldenRod2" "black"

casehost "shell1" "shell1.sourceforge.net." "lavender" "black"
casehost "cf" "cf.sourceforge.net." "lavender" "black"

cat <<\TEMPLATEQUOTE
    *)
      return 1
      ;;
  esac
  return 0
}

debug()
{
   :
   #echo "$@"
}

for i in $@; do
   case $i in
      [Hh][Ee][Rr][Ee]) debug here; SERVER="HERE" ;;
      [Tt][Hh][Ee][Rr][Ee]) debug there; SERVER="THERE" ;;
      [Cc][Oo][Mm][Pp][Rr][Ee][Ss][Ss]) debug compress; COMPRESS="-C" ;;
      [Nn][Oo][Cc][Oo][Mm][Pp][Rr][Ee][Ss][Ss]) debug nocompress; COMPRESS="" ;;
      [Rr][Xx][Vv][Tt]) debug rxvt; TERM="rxvt" ;;
      [Xx][Tt][Ee][Rr][Mm]) debug xterm; TERM="xterm" ;;
      [Cc][Hh][Ii][Nn][Ee][Ss][Ee]) debug cxterm; TERM="cxterm" ;;
      *)
         debug makewin $i
         if makewin $i; then
            debug ok
         else
            debug not ok
            if makewin `nslookup $i | grep "^Name:" | awk '{print $2}'`; then
               debug ok after nslookup
            else
               echo Unknown Host $i
            fi
         fi

         if [ "$SERVER" = "HERE" ]; then
            CMD=""
            if [ -n "$HOST" ]; then
               CMD="$CMD -e ssh -X $COMPRESS -c blowfish $HOST"
               "$TERM" -fg "$FG" -bg "$BG" $CMD &
            fi
         else
            if [ -n "$HOST" ]; then
               ssh -X -f "$HOST" $COMPRESS -c blowfish "$TERM" -ls -fg $FG -bg $BG
            fi
         fi
         ;;
   esac
done
TEMPLATEQUOTE
