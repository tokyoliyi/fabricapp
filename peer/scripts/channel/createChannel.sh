#!/bin/bash

. ../env.sh

# prepare channel.tx and anchors.tx

CHANNEL_TX=/tmp/channel.tx
ANCHORS_TX=/tmp/anchors.tx

if [ ! -f "$CHANNEL_TX" ]; then
    echo "No $CHANNEL_TX file"
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

cp $CHANNEL_TX $HOST_PATH/channel.tx
cp $ANCHORS_TX $HOST_PATH/anchors.tx

# cp scripts into cli container
# why env.sh must be put in an absolute path? Because we will import it in another shell script, so we need to know where it is.
docker cp ../env.sh ${CLI_CONTAINER_NAME}:/tmp/env.sh
docker cp ./processCreateChannel.sh ${CLI_CONTAINER_NAME}:${CLI_VM_WORKING_DIR}/processCreateChannel.sh
docker exec $CLI_CONTAINER_NAME sh -c "chown root:root ${CLI_VM_WORKING_DIR}/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "chmod +x  ${CLI_VM_WORKING_DIR}/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "${CLI_VM_WORKING_DIR}/processCreateChannel.sh"
