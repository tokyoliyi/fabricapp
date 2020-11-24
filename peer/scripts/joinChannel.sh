#!/bin/bash

. ./env.sh

# prepare appchannel.block and anchors.tx

CHANNEL_BLOCK=/tmp/${APP_CHANNEL_NAME}.block
ANCHORS_TX=/tmp/anchors.tx

if [ ! -f "$CHANNEL_BLOCK" ]; then
    echo "No $CHANNEL_BLOCK file"
    exit 1
fi

if [ ! -f "$ANCHORS_TX" ]; then
    echo "No $ANCHORS_TX file"
    exit 1
fi

# copy channel and anchors tx file to host volume
HOST_PATH=$HOST_VOLUME_CLIENT

cp $CHANNEL_BLOCK $HOST_PATH
cp $ANCHORS_TX $HOST_PATH

docker cp ./env.sh ${CLI_CONTAINER_NAME}:/tmp/env.sh
docker cp ./processJoinChannel.sh ${CLI_CONTAINER_NAME}:${FABRIC_CA_CLIENT_HOME}/processJoinChannel.sh
docker exec $CLI_CONTAINER_NAME sh -c "chown root:root ${FABRIC_CA_CLIENT_HOME}/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "chmod +x  ${FABRIC_CA_CLIENT_HOME}/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "${FABRIC_CA_CLIENT_HOME}/processJoinChannel.sh"
