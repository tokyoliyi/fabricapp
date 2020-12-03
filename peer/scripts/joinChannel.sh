#!/bin/bash

# this script executed in cli docker container

. ./env.sh

# check channel.tx file exist

CHANNEL_BLOCK=$1

if [ ! -f "$CHANNEL_BLOCK" ]; then
    echo "No startup channel tx"
    exit 1
fi

PATH_BASE=${PWD}/${HOST_VOLUME_CLIENT}

export FABRIC_CFG_PATH=${FABRIC_CLIENT_BIN_PATH}/config
export CORE_PEER_LOCALMSPID=$ORG_MSPID
export CORE_PEER_ADDRESS=${PEER_CONTAINER_NAME}:${PEER_PORT}
export CORE_PEER_MSPCONFIGPATH=${PATH_BASE}/users/${ORG_ADMIN_USER_NAME}/msp
# tls 
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_CERT_FILE=${PATH_BASE}/peers/${PEER_NAME}/tls-msp/signcerts/cert.pem
export CORE_PEER_TLS_KEY_FILE=${PATH_BASE}/peers/${PEER_NAME}/tls-msp/keystore/key.pem
export CORE_PEER_TLS_ROOTCERT_FILE=${PATH_BASE}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem

peer channel join -b $CHANNEL_BLOCK

sleep 6
peer channel list
