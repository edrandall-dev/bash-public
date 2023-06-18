#!/bin/bash

#
# Script: neo4j-docker.sh
# Purpose: install neo4j container image after some simple environmentment prep
# 

[ $? == 0 ] || { echo "ERROR: Check if docker is installed (and in your PATH)" ; exit 1; }

DATA_DIR="$HOME/docker/neo4j-volumes/data"
LOG_DIR="$HOME/docker/neo4j-volumes/logs"
IMPORT_DIR="$HOME/docker/neo4j-volumes/import"
PLUGINS_DIR="$HOME/docker/neo4j-volumes/plugins"

RUNNING_CONTAINER=$($DOCKER ps -a | grep "neo4j:latest" | awk {'print $1'})
[ -z "$RUNNING_CONTAINER" ] || docker rm -f $RUNNING_CONTAINER

[ -d $DATA_DIR ] && rm -rf $DATA_DIR/* || mkdir $DATA_DIR
[ -d $LOG_DIR ] && rm -rf $DATA_DIR/* || mkdir $LOG_DIR
[ -d $IMPORT_DIR ] && rm -rf $DATA_DIR/* || mkdir $IMPORT_DIR
[ -d $PLUGINS_DIR ] && rm -rf $DATA_DIR/* || mkdir $PLUGINS_DIR

docker run \
    --name testneo4j \
    -p7474:7474 -p7687:7687 \
    -d \
    -v $DATA_DIR:/data \
    -v $LOG_DIR:/logs \
    -v $IMPORT_DIR:/var/lib/neo4j/import \
    -v $PLUGINS_DIR:/plugins \
    --env NEO4J_AUTH=neo4j/test \
    neo4j:latest
