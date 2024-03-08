###########################################
#                                         #
# Remember to set the first two variables #
# properly before proceeding!             #
#                                         #
###########################################

SERVER_HNAME=vm-hostname
MAC_ADDRESS="XX:XX:XX:XX:XX:XX"

###########################################

VIRT_INSTALL=/usr/sbin/virt-install
PACKAGE_MIRROR="http://anorien.csc.warwick.ac.uk/CentOS/7/os/x86_64/"
KICKSTART_FILE_LOC="http://example.com/ks/file.ks"


echo "This script was invoked as: $0"

if [ "$(/usr/bin/virsh list | grep $SERVER_HNAME | awk '{print $2}')" = "$SERVER_HNAME" ]
then
  echo "Machine already exists! Abandoning build." \
  echo
  /usr/bin/virsh list | grep -E "Id|----|$SERVER_HNAME"
  exit 1;
else
  echo -e "Attempting to build $SERVER_HNAME\n"
  $VIRT_INSTALL --vcpus 1 \
                --ram=2048 \
                --nographics \
                --os-type=linux \
                --os-variant=rhel7 \
                --name=$SERVER_HNAME \
                --network bridge=bridge0,mac=$MAC_ADDRESS \
                --disk path=/var/lib/libvirt/images/$SERVER_HNAME.1.img,size=16 \
                --location $PACKAGE_MIRROR \
                --extra-args="ks=$KICKSTART_FILE_LOC console=ttyS0"
fi
