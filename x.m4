include(functions.m4)dnl
include(init.m4)dnl
changequote({{, }})dnl
define({{CASEHOST}}, {{$1|$1.*)
      HOST="$2"
      FG="$3"
      BG="$4"
      ;;}})dnl
#!/bin/sh
define({{LOCALTERM}}, ifelse(SYS_HOST, {{castor.mili.eu.org}}, {{rxvt}},
           {{xterm}}))dnl

SERVER="HERE"
TERM="LOCALTERM"
HOST=""
FG="white"
BG="black"
COMPRESS="";

makewin()
{
  case $@ in
    CASEHOST(cco, cco.caltech.edu., red2, black)
    CASEHOST(morocco, morocco.cco.caltech.edu., red2, black)
    CASEHOST(stucco, stucco.cco.caltech.edu., red2, black)

    CASEHOST(lenin, lenin.dabney.caltech.edu., green2, black)

    CASEHOST(to, uglab.best.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(hp, ughp.best.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(sgi, ugsgi.best.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(intel, ugintel.best.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(acro, acro.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(agora, agora.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(amatho, amatho.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(arachno, arachno.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(auto, auto.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(baht, baht.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(barf, barf.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(beg, beg.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(bolivar, bolivar.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(chunder, chunder.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(crush, crush.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(cruzeiro, cruzeiro.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(dinar, dinar.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(drachma, drachma.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(gluttony, gluttony.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(groat, groat.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(gurg, gurg.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(hedono, hedono.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(hork, hork.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(hurl, hurl.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(lek, lek.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(lira, lira.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(mono, mono.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(myxo, myxo.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(necro, necro.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(pyro, pyro.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(retch, retch.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(riyal, riyal.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(spew, spew.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(taphe, taphe.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(triskaideka, triskaideka.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(upchuck, upchuck.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(vomit, vomit.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(xeno, xeno.ugcs.caltech.edu., SteelBlue1, black)
    CASEHOST(yak, yak.ugcs.caltech.edu., SteelBlue1, black)

    CASEHOST(lugh, lugh.cacr.caltech.edu., PapayaWhip, black)
    CASEHOST(trex, trex.cacr.caltech.edu., PapayaWhip, black)

    CASEHOST(jotunheim, jotunheim.caltech.edu., MediumSpringGreen, black)
    CASEHOST(lard, lard, MediumSpringGreen, black)
    CASEHOST(lolita, lolita.dabney.caltech.edu., MediumSpringGreen, black)
    CASEHOST(fruity, fruity.dabney.caltech.edu., MediumSpringGreen, black)
    CASEHOST(dewinter, dewinter.dabney.caltech.edu., MediumSpringGreen, black)
    CASEHOST(yojackson, yojackson.dabney.caltech.edu., MediumSpringGreen, black)

    CASEHOST(colostomy, colostomy.bitfield.org., MistyRose, black)
    CASEHOST(darbly, darbly.mit.edu, MistyRose, black)
    CASEHOST(girgle, girgle.dabney.caltech.edu., MistyRose, black)
    CASEHOST(quantum, quantum.caltech.edu., MistyRose, black)

    CASEHOST(icsi, login.icsi.berkeley.edu., LightSteelBlue, black)
    CASEHOST(icsi2, login2.icsi.berkeley.edu., LightSteelBlue, black)
    CASEHOST(crawdad, crawdad.icsi.berkeley.edu., LightSteelBlue, black)
    CASEHOST(fondue, fondue.icsi.berkeley.edu., LightSteelBlue, black)
    CASEHOST(sausage, sausage.icsi.berkeley.edu., LightSteelBlue, black)

    CASEHOST(admiral, admiral.i., LightSteelBlue, black)
    CASEHOST(agama, agama.i., LightSteelBlue, black)
    CASEHOST(agni, agni.i., LightSteelBlue, black)
    CASEHOST(alfalfa, alfalfa.i., LightSteelBlue, black)
    CASEHOST(anglewing, anglewing.i., LightSteelBlue, black)
    CASEHOST(anubis, anubis.i., LightSteelBlue, black)
    CASEHOST(anuket, anuket.i., LightSteelBlue, black)
    CASEHOST(aten, aten.i., LightSteelBlue, black)
    CASEHOST(atman, atman.i., LightSteelBlue, black)
    CASEHOST(atum, atum.i., LightSteelBlue, black)
    CASEHOST(bast, bast.i., LightSteelBlue, black)
    CASEHOST(bes, bes.i., LightSteelBlue, black)
    CASEHOST(blue, blue.i., LightSteelBlue, black)
    CASEHOST(buckeye, buckeye.i., LightSteelBlue, black)
    CASEHOST(checkerspot, checkerspot.i., LightSteelBlue, black)
    CASEHOST(copper, copper.i., LightSteelBlue, black)
    CASEHOST(crescent, crescent.i., LightSteelBlue, black)
    CASEHOST(cerius, cerius.i., LightSteelBlue, black)
    CASEHOST(darkhorse, darkhorse.ispheres.com., LightSteelBlue, black)
    CASEHOST(dazzler, dazzler.i., LightSteelBlue, black)
    CASEHOST(dragontail, dragontail.i., LightSteelBlue, black)
    CASEHOST(edjo, edjo.i., LightSteelBlue, black)
    CASEHOST(fritillary, fritillary.i., LightSteelBlue, black)
    CASEHOST(harvest, harvest.i., LightSteelBlue, black)
    CASEHOST(isis, isis.i., LightSteelBlue, black)
    CASEHOST(kali, kali.i., LightSteelBlue, black)
    CASEHOST(krishna, krishna.i., LightSteelBlue, black)
    CASEHOST(lady, lady.i., LightSteelBlue, black)
    CASEHOST(monarch, monarch.i., LightSteelBlue, black)
    CASEHOST(moth, moth.i., LightSteelBlue, black)
    CASEHOST(nymph, nymph.i., LightSteelBlue, black)
    CASEHOST(parnassian, parnassian.i., LightSteelBlue, black)
    CASEHOST(queen, queen.i., LightSteelBlue, black)
    CASEHOST(ra, ra.i., LightSteelBlue, black)
    CASEHOST(satyr, satyr.i., LightSteelBlue, black)
    CASEHOST(shiva, shiva.i., LightSteelBlue, black)
    CASEHOST(skippers, skippers.i., LightSteelBlue, black)
    CASEHOST(snout, snout.i., LightSteelBlue, black)
    CASEHOST(sulphur, sulphur.i., LightSteelBlue, black)
    CASEHOST(sura, sura.i., LightSteelBlue, black)
    CASEHOST(swallowtail, swallowtail.i., LightSteelBlue, black)
    CASEHOST(swati, swati.i., LightSteelBlue, black)
    CASEHOST(varuna, varuna.i., LightSteelBlue, black)
    CASEHOST(viceroy, viceroy.i., LightSteelBlue, black)
    CASEHOST(white, white.i., LightSteelBlue, black)
    CASEHOST(yama, yama.i., LightSteelBlue, black)

    CASEHOST(spica, spica.mili.eu.org., thistle2, black)
    CASEHOST(altair, altair.mili.eu.org., thistle2, black)
    CASEHOST(smonger, smonger.mili.eu.org., thistle2, black)
    CASEHOST(fmonger, fmonger.mili.eu.org., thistle2, black)
    CASEHOST(castor, castor.mili.eu.org., thistle2, black)

    CASEHOST(ofb, ofb.net., PaleGoldenrod, black)

    CASEHOST(maestro, maestro.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(cezanne, cezanne.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(chagall, chagall.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(da-vinci, da-vinci.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(gainsborough, gainsborough.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(gaugain, gaugain.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(michelangelo, michelangelo.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(monet, monet.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(picasso, picasso.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(raphael, raphael.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(rembrandt, rembrandt.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(renoir, renoir.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(rubens, rubens.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(toulouse-lautrec, toulouse-lautrec.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(vangogh, vangogh.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(varese, varese.cs.caltech.edu., GoldenRod1, black)
    CASEHOST(velasquez, velasquez.cs.caltech.edu., GoldenRod1, black)

    CASEHOST(piano, piano.cs.caltech.edu., GoldenRod2, black)
    CASEHOST(harp, harp.cs.caltech.edu., GoldenRod2, black)

    CASEHOST(shell1, shell1.sourceforge.net., lavender, black)
    CASEHOST(cf, cf.sourceforge.net., lavender, black)

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
