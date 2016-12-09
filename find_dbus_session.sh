#!/bin/sh
# From https://ubuntuforums.org/showthread.php?t=1059023
# Remember to run this script using the command "source ./filename.sh"

# Search these processes for the session variable 
# (they are run as the current user and have the DBUS session variable set)
compatiblePrograms="nautilus kdeinit kded4 pulseaudio trackerd"

# Attempt to get a program pid
for index in $compatiblePrograms; do
   PID=`pidof nautilus`
   if [ -n "${PID}" ]; then
      break
   fi
done
if [ -z "${PID}" ]; then
   echo "Could not detect active login session"
   return 1
fi

QUERY_ENVIRON="`tr '\0' '\n' < /proc/11339/environ |
   grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2-`"
if [ -n "${QUERY_ENVIRON}" ]; then
   export DBUS_SESSION_BUS_ADDRESS="${QUERY_ENVIRON}"
   # echo "Connected to session:"
   # echo "DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS}"
else
   echo "Could not find dbus session ID in user environment."
   return 1
fi

return 0


