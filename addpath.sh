addpath $HOME/.rbenv/bin
addpath $HOME/.toast/bin
addpath $HOME/.gem/ruby/2.3.0/bin
addpath $HOME/.gem/ruby/2.0.0/bin
addpath $HOME/.gem/ruby/1.9.1/bin
addpath $HOME/dl/gocode/bin
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

## rust
addpath $HOME/.cargo/bin

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

# Mac OSX
addpath /opt/local/bin
addpath /opt/boxen/repo/bin
addpath $HOME/Library/Python/2.7/bin

addpath $HOME/bin
addpath $HOME/dl/android-sdk-linux/platform-tools
addpath $HOME/dl/android-sdk-linux/tools
addpath $HOME/dl/appengine-java-sdk/bin
addpath $HOME/.local/bin

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

preclasspath /usr/local/jdk117_v3/lib/classes.zip
addclasspath /etc/alternatives/java_sdk/jre/lib/rt.jar
addclasspath /usr/local/java/lib/classes.zip
addclasspath /usr/lib/j2sdk1.3/jre/lib/rt.jar
addclasspath /usr/lib/jvm/java-1.3.1-sun-1.3.1.08/jre/lib/rt.jar
addclasspath /usr/lib/jvm/java-1.4.2-sun-1.4.2.01/jre/lib/rt.jar

### try swing 1.1.1
addclasspath /opt/swing-1.1.1fcs/swing.jar

### try swing 1.1.1 beta2
addclasspath /usr/local/swing/swing-1.1.1beta2/swing.jar 
addclasspath /home/wtanaka/swing-1.1.1fcs/swing.jar
addclasspath /home/wtanaka/swing-1.1.1beta2/swing.jar
addclasspath /dei/share/arch/i386/swing/swing-1.1.1beta2/swing.jar

### try swing 1.1.1 beta1
addclasspath /usr/ug/share/swing-1.1.1-beta1/swing.jar

### try swing 1.1
addclasspath /usr/local/swing-1.1/swing.jar

### try swt
addclasspath /usr/lib/eclipse/plugins/org.eclipse.swt.gtk/ws/gtk/swt.jar
addclasspath /usr/lib/eclipse/plugins/org.eclipse.swt.gtk/ws/gtk/swt-pi.jar
addclasspath /usr/lib/eclipse/plugins/org.eclipse.ui.workbench/workbench.jar
addclasspath /usr/lib/eclipse/plugins/org.eclipse.core.boot/boot.jar
addclasspath /usr/lib/eclipse/plugins/org.eclipse.jface/jface.jar
addclasspath /usr/lib/eclipse/plugins/org.eclipse.core.runtime/runtime.jar

### try junit
addclasspath /usr/share/java/junit.jar

addclasspath "$HOME/gale.jar"
addclasspath "$HOME/wtanaka/gale.jar"

addclasspath "$HOME/infospheres/src"
if [ -r "$HOME"/infospheres/src/classpath ]; then
   addclasspath `sed -e 's/:/ /g' "$HOME"/infospheres/src/classpath`
else
   if [ -x "$HOME"/infospheres/src/scripts/make_classpath ]; then
      "$HOME"/infospheres/src/sciprts/make_classpath \
         > "$HOME"/infospheres/src/classpath
      addclasspath `sed -e 's/:/ /g' "$HOME"/infospheres/src/classpath`
   fi
fi

addclasspath "$HOME/wohenchan/src"
addclasspath "$HOME/herdme/src"
addclasspath "$HOME/cabal/src"
addclasspath "$HOME/praya"

addclasspath "$HOME/ecgs/source"
addclasspath "$HOME/ecgs/classes"

addclasspath "$HOME/beanos/src"
addclasspath /usr/local/JSDK2.0/lib/jsdk.jar
