#!/bin/bash

###########################################
#                                         #
# Remember to set the first two variables #
# properly before proceeding!             #
#                                         #
###########################################

SERVER_HNAME=test-vm
MAC_ADDRESS="1c:98:ec:11:00:20"

VIRT_INSTALL=/usr/bin/virt-install
PACKAGE_MIRROR="http://anorien.csc.warwick.ac.uk/CentOS/7/os/x86_64/"
KICKSTART_FILE_LOC="http://microserver.thelinuxnetwork.com/ks/plex-one-seven.ks"

BRIDGE=virbr0

###########################################

function list_hostnames {
  virsh list --all | awk {'print $2'} | grep -v Name
}

function check_hostname {
  hn_result=$(list_hostnames | grep $SERVER_HNAME)
  if [ ! -z "$hn_result" ] ; then
    echo "The specified hostname is already in use."
  OK=false
  fi
}

function list_macs {
  for i in $(virsh list --all --name); do
    echo -ne "$i\t"
    virsh domiflist $i | grep -o -E '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}'
  done
}

function check_mac {
  mac_result=$(list_macs | grep $MAC_ADDRESS)
  if [ ! -z "$mac_result" ] ; then
    echo "The specified MAC address is already in use."
  OK=false
  fi
}

check_mac
check_hostname

if [ "$OK" != "false" ]; then
  echo -e "Attempting to build $SERVER_HNAME\n"
  $VIRT_INSTALL --vcpus 1 \
                --ram=2048 \
                --nographics \
                --os-type=linux \
                --os-variant=rhel7 \
                --name=$SERVER_HNAME \
                --network bridge=$BRIDGE,mac=$MAC_ADDRESS \
                --disk path=/var/lib/libvirt/images/$SERVER_HNAME.1.img,size=16 \
                --location $PACKAGE_MIRROR \
                --extra-args="ks=$KICKSTART_FILE_LOC console=ttyS0"
fi
