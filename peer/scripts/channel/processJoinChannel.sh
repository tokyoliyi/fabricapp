#!/bin/bash

# this script executed in cli docker container

. /tmp/env.sh

# check init channel.tx file exist

INIT_CHANNEL_TX=${CLI_VM_WORKING_DIR}/${APP_CHANNEL_NAME}.block
ANCHORS_FILE=${CLI_VM_WORKING_DIR}/anchors.tx


if [ ! -f "$INIT_CHANNEL_TX" ]; then
    echo "No startup channel tx"
    exit 1
fi

if [ ! -f "$ANCHORS_FILE" ]; then
    echo "No anchors tx"
    exit 1
fi

export CORE_PEER_LOCALMSPID=$ORG_MSPID
export CORE_PEER_ADDRESS=${PEER_CONTAINER_NAME}:${PEER_PORT}
export CORE_PEER_MSPCONFIGPATH=${FABRIC_CA_CLIENT_HOME}/users/${ORG_ADMIN_USER_NAME}/msp
export TLS_CA_FILE=${FABRIC_CA_CLIENT_HOME}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem

peer channel join -b ${APP_CHANNEL_NAME}.block

sleep 3

# update anchor peer
peer channel update -o $ORDERER_HOSTPORT --ordererTLSHostnameOverride $ORDERER_HOST -c $APP_CHANNEL_NAME -f $ANCHORS_FILE --tls true --cafile $TLS_CA_FILE

sleep 6
peer channel list
peer channel getinfo -c $APP_CHANNEL_NAME
