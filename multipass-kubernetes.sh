#!/bin/bash

###########

CTRL_PLANE_QTY=1
WORKER_QTY=3

VM_PREFIX=k8s

CTRL_PLANE_HN_PREFIX=$VM_PREFIX-ctrl-plane
WORKER_HN_PREFIX=$VM_PREFIX-worker
RANCHER_HN=$VM_PREFIX-rancher

###########

MULTIPASS=$(which multipass) || { echo "Error: multipass not found, please verify" ; exit 1; } ;

function usage {
  echo "Usage: {$0 list | create | destroy | purge}"
  exit 1
}

[ "$#" > 1 ] || usage
[ "$#" == 0 ] && $MULTIPASS list && exit 0 

case $1 in
     create)

       echo -e "1 - Creating $WORKER_QTY k8s Worker Node(s):"
       for host in $(seq 1 $WORKER_QTY)
       do
         $MULTIPASS launch --name $WORKER_HN_PREFIX-$host --network eno1
       done

       echo -e "\n2 - Creating $CTRL_PLANE_QTY k8s Control Plane Node(s):"
       for host in $(seq 1 $CTRL_PLANE_QTY)
       do
         $MULTIPASS launch --name $CTRL_PLANE_HN_PREFIX-$host --network eno1
       done

       echo -e "\n3 - Creating k8s Rancher Node:"
       $MULTIPASS launch --name $RANCHER_HN --network eno1
     ;;

     list)
       $MULTIPASS list
     ;;

     destroy)
       multipass list | grep k8s | awk '{print $1}' | xargs multipass delete
       multipass list
     ;;

     purge)
     multipass purge	
     ;; 

     *)
     usage
     ;;
esac
