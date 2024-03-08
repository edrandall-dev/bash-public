#!/bin/bash

#Set backup username
USER="username"

#Set host IP and MAC Addresses
HOST_IP="10.10.10.10"
HOST_MAC="XX:XX:XX:XX:XX:XX"

#Set source and target directories
TARGET="/target-dir"
SOURCE="/source-dir"

PING_TEST="fping -c1 -t500 $HOST_IP"
SSH_PORT_TEST="nc -z $HOST_IP 22"

#Set SSH Keyname
SSH_KEY=""


SSH_CONN_TEST="ssh -i $SSH_KEY -o strictHostKeyChecking=no $USER@$HOST_IP exit"
STAMP="date +%H:%M:%S"
WAIT="sleep 5"

echo "$($STAMP) Waking up the backup target."
wakeonlan $HOST_MAC >> /dev/null 2>&1

#function to perform the first rsync operation
do_backup() {
  echo "$($STAMP) OK: Starting rsync"
  rsync \
    -avz \
    --delete \
    -e "ssh -i ~/.ssh/$SSH_KEY" \
    --exclude 'exclude-dir-1/*' \
    --exclude 'exclude-dir-2/*' \
    $SOURCE $USER@$HOST_IP:$TARGET
}

#while loop(s) to ensure that backup target is awake and ready
while true ; do 
  if $PING_TEST >> /dev/null 2>&1; then
    echo "$($STAMP) OK: ping test"
    if $SSH_PORT_TEST ; then 
      echo "$($STAMP) OK: ssh port open"
      while true ;do 
        if $SSH_CONN_TEST >> /dev/null 2>&1 ; then
          echo "$($STAMP) OK: ssh connection working for non-root users, starting backup"
          do_backup
          echo "$($STAMP) OK: Backup Complete.  Powering off target."
          $WAIT
          ssh -i $SSH_KEY $USER@$HOST_IP "sudo poweroff"
          exit
        else 
          echo "$($STAMP) FAIL: ssh port listening but sshd not ready for non-root users"
          $WAIT
        fi
      done
        exit  
    else 
      echo "$($STAMP) FAIL: ssh port closed"
      $WAIT
    fi
  else
    echo "$($STAMP) FAIL: ping test"
    $WAIT
  fi 
done