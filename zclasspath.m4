addclasspath /usr/local/java/lib/classes.zip
addclasspath /usr/lib/j2sdk1.3/jre/lib/rt.jar

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

addclasspath $HOME

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

addclasspath "$HOME/beanos/src"
addclasspath /usr/local/JSDK2.0/lib/jsdk.jar
