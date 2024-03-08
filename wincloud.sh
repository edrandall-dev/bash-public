#!/bin/bash

function error {
  echo "Fatal Error: $1"
  exit 1
}

function usage {
  echo "Usage: wincloud [ create | destroy | status ]"
  exit 1
}

function loghead {
  echo "------------------------------------"
  echo
  echo -e "\033[4m$(/usr/bin/date)\033[0m"
  echo
}

OUTFILE="/var/log/terraform.log"
[ -f "$OUTFILE" ] || { error "Logfile doesn't exist. Please create and set correct ownership."; };
[ -O "$OUTFILE" ] || { error "Logfile is not owned by this user."; };

WRKDIR="/home/edrandall/terraform/code/sw-win-server/eu-west-2"
[ -d "$WRKDIR" ] && { cd $WRKDIR; } || { error "terraform directory doesn't exist. Please verify."; };

TERRAFORM="/usr/local/bin/terraform"
[ -f $TERRAFORM ] || { error "terraform command not found. Please verify"; };

AWS="/usr/bin/aws"
[ -f $AWS ] || { error "aws command not found."; };

[ $# -eq 1 ] || { usage; };

case "$1" in
  "create")
    loghead >> $OUTFILE 2>&1
    $TERRAFORM apply -auto-approve | tee -a $OUTFILE
    echo >> $OUTFILE
    ;;

  "destroy")
    loghead >> $OUTFILE 2>&1
    $TERRAFORM destroy -auto-approve | tee -a $OUTFILE
    echo >> $OUTFILE
    ;;

  "status")
    INSTANCE_NAME="edr-win-environment-server"
    PUBLIC_IP=$($AWS ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:Name,Values=edr-win-env-server --output table | grep PublicIp | awk '{print $4}' | sort -u)

    if [ -z "$PUBLIC_IP" ] ; then
      echo -e "No ec2 instance named \e[1m$INSTANCE_NAME\e[0m is running."
    else
      echo -e "An ec2 instance named \e[1m$INSTANCE_NAME\e[0m is running with public ip: \e[1m$PUBLIC_IP\e[0m"
    fi

    ;;

  *)
    usage;
    ;;
esac
