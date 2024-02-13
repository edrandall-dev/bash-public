#!/bin/bash
if [ $UID != 0 ] ; then
  echo "Error: This script must be run as root."
  exit 1
fi

LOGFILE="/Users/edrandall/Desktop/dns-reset.log"
DATESTAMP=$(date +"%T on %d-%m-%y")

#echo "*** Script invoked $DATESTAMP ***" >> $LOGFILE

MODULE="$(sudo launchctl list | grep -i dnsfilter | awk {'print $NF'})"
if [ "$MODULE" == "com.dnsfilter.agent.macos.helper" ] ; then
  echo "$DATESTAMP: DNSfilter module has been loaded. Unloading." >> $LOGFILE
  launchctl unload -w /Library/LaunchDaemons/com.dnsfilter.agent.macos.helper.plist
fi

DIRECTORY="/Applications/DNSFilter Agent.app/"
if [ -d "$DIRECTORY" ] ; then
  echo "$DATESTAMP: Directory "$DIRECTORY" exists. Removing." >> $LOGFILE
  rm -rf "$DIRECTORY"
fi
