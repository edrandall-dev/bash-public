#
# Script:  reboot-script.sh
# Purpose: This script will run when the system reboots (via root's crontab, @reboot) to restart dns and dhcp containters
# Author:  Ed Randall
# Date:    12 May 2021
#

#Which Docker
DOCKER=$(/usr/bin/which docker)
MAKE=$(/usr/bin/which make)

# Destroy existing/leftover containers which may still be running
BIND_CONTAINER_ID=$($DOCKER ps -a | grep tln-alpine-bind9 | awk '{print $1'})
DHCP_CONTAINER_ID=$($DOCKER ps -a | grep tln-alpine-dhcp | awk '{print $1'})

[ "$BIND_CONTAINER_ID" != "" ] && { $DOCKER rm -f $BIND_CONTAINER_ID ; } ;
[ "$DHCP_CONTAINER_ID" != "" ] && { $DOCKER rm -f $DHCP_CONTAINER_ID ; } ;

sleep 1

#Start the DHCP container
cd /home/edrandall/docker/tln-alpine-dhcpd
$MAKE run-bg-with-pool

sleep 1

#Start the bind container
cd /home/edrandall/docker/tln-alpine-bind9
./run.sh &
