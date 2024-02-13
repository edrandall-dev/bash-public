#!/bin/bash
if [ $UID != 0 ] ; then
  echo "Error: This script must be run as root."
  exit 1
fi

LOGFILE="/Users/edrandall/Desktop/dns-reset.log"
DATESTAMP=$(date +"at %T on %m-%d-%y")

echo "*** Script invoked $DATESTAMP ***" >> $LOGFILE

MODULE="$(sudo launchctl list | grep -i dnsfilter | awk {'print $NF'})"
if [ "$MODULE" == "com.dnsfilter.agent.macos.helper" ] ; then
  echo "DNSfilter module is loaded. Unloading $DATESTAMP." >> $LOGFILE
  launchctl unload -w /Library/LaunchDaemons/com.dnsfilter.agent.macos.helper.plist
fi

DIRECTORY="/Applications/DNSFilter Agent.app/"
if [ -d "$DIRECTORY" ] ; then
  echo "Directory exists. Removing $DATESTAMP." >> $LOGFILE
  rm -rf "$DIRECTORY"
fi

