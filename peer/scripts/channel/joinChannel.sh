#!/bin/bash

. ../env.sh

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
# check if cli host workding dir exists
HOST_PATH=../${CLI_HOST_WORKING_DIR}
if [ ! -d "${HOST_PATH}" ]; then
    echo "mkdir ${HOST_PATH}"
    mkdir -p ${HOST_PATH}
fi

cp $CHANNEL_BLOCK ${HOST_PATH}/${APP_CHANNEL_NAME}.block
cp $ANCHORS_TX ${HOST_PATH}/anchors.tx

docker cp ../env.sh ${CLI_CONTAINER_NAME}:/tmp/env.sh
docker cp ./processJoinChannel.sh ${CLI_CONTAINER_NAME}:${CLI_VM_WORKING_DIR}/processJoinChannel.sh
docker exec $CLI_CONTAINER_NAME sh -c "chown root:root ${CLI_VM_WORKING_DIR}/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "chmod +x  ${CLI_VM_WORKING_DIR}/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "${CLI_VM_WORKING_DIR}/processJoinChannel.sh"
