# this is for the CS cluster
#export TEXINPUTS=.:/usr/local/teTeX/texmf/tex//:/usr/local/tex/lib/texmf/tex//:$HOME/tex//

#export PATH=""

addpath /usr/ug/bin
addpath /dei/share/bin

## java
addpath /usr/java/j2sdk1.4.2/bin
addpath /usr/java/jdk1.3.1/bin
addpath /usr/local/jdk117_v3/bin
addpath /usr/local/jdk1.1.7/bin
addpath /usr/local/jdk117/bin
addpath /usr/local/jdk1.1.5/bin
addpath /usr/local/java/jdk116_v5/bin
addpath /usr/local/jdk1.2/bin
addpath /usr/jdk1.2/bin
addpath /usr/local/java/bin

## generic
addpath /bin
addpath /usr/bin
addpath /usr/local/bin
addpath /etc
addpath /usr/etc
addpath /usr/contrib/bin
addpath /usr/sbin
addpath /usr/games

## X
addpath /usr/bin/X11
addpath /usr/X11/bin
addpath /usr/X11R6/bin
addpath /usr/local/X11/bin
addpath /usr/local/bin/X11

addpath $HOME/bin

addpath /usr/ucb
addpath /usr/local/cad/bin
addpath /usr/local/cosmos/bin
addpath /home/cs3/bin
addpath /home/wtanaka/cs2/bin
addpath /home/app/oracle/product/8.0.5/bin
addpath /home/oracle/bin
addpath /usr/rhs/bin
if [ -x /usr/local/bin/ccoarch ]; then
   addpath /ccovol/gnu/bin.`/usr/local/bin/ccoarch`
   addpath /ccovol/X11R5/bin.`/usr/local/bin/ccoarch`
fi
addpath "/ufs/info/bin/`uname -s``uname -r`/jdk1.1.3/bin"
addpath /ofb/bin
addpath /home/contrib/bin

addpath ~/infospheres/src/scripts

addpath "$FPATH"
