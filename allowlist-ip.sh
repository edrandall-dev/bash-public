#!/bin/bash


ALLOWLIST_FILE=allowlist.ips
[ -f $ALLOWLIST_FILE ] || { echo "Error: $ALLOWLIST_FILE is missing. Check."; exit 1; }

function usage()
{
  echo " --> Error: This script takes ONE argument: a VALID ip address."
  exit 1;
}

function valid_ip()
{
    local ip=$1
    local stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

[ $# = 1 ] || { usage; }

if valid_ip $1; then
  #would we like to allowlist the valid ip?
  echo -n " --> $1 is a valid IP address. Would you like to allowlist it? [ y/N ]: "
  read input;

  #is the valid ip already in the $ALLOWLIST File
  grep -q $1 $ALLOWLIST_FILE
  [ $? = 0 ] && { echo " --> That IP is already in $ALLOWLIST_FILE. Exiting. "; exit 1; }

  #add the ip to the $ALLOWLIST_FILE
  echo $1 >> $ALLOWLIST_FILE

  #remind to reload iptables
  echo " --> $1 has been added to $ALLOWLIST_FILE."
  echo " --> reload iptables script for it to take effect."

else
  usage;
fi
