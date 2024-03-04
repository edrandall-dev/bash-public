HOST_NAME=hostname
HOST_MAC=XX:XX:XX:XX:XX:XX
HOST_IP=10.10.10.10
USER=username
SSH_KEY="~/.ssh/keyname"
FPING=$(which fping) || { echo "fping is required and can't be found.  please verify"; exit 1; } ;

echo "START:\t\tSending WOL packet to $HOST_MAC to wake up $HOST_NAME"
wakeonlan $HOST_MAC -q
sleep 2

echo "WAIT:\t\tWaiting for $HOST_NAME to respond"
sleep 2
$FPING -c1 -t500 $HOST_IP >> /dev/null 2>&1

while [ $? != 0 ] ; do
  sleep 1
  $FPING -c1 -t500 $HOST_IP
done >> /dev/null 2>&1

echo "READY:\t\t$HOST_NAME is awake and responding to pings"
sleep 2
echo "CONNECT:\tStarting SSH session to $HOST_NAME at $HOST_IP as user $USER"
sleep 2
ssh -i $SSH_KEY $USER@$HOST_IP
