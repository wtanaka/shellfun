addclasspath /usr/local/java/lib/classes.zip

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
if [ -d "$HOME"/infospheres/external/jars/ ]; then
   if [ -n "${HOME}"/infospheres/external/jars/*.jar ]; then
     addclasspath "$HOME"/infospheres/external/jars/*.jar 
   fi
   if [ -n "${HOME}"/infospheres/external/jars/*.zip ]; then
     addclasspath "$HOME"/infospheres/external/jars/*.zip 
   fi
fi
addclasspath "$HOME/beanos/src"
addclasspath /usr/local/JSDK2.0/lib/jsdk.jar
