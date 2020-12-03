#!/bin/bash

. ../env.sh

export PATH_BASE=${PWD}/../${HOST_VOLUME_CLIENT}
export FABRIC_CFG_PATH=${FABRIC_CLIENT_BIN_PATH}/config

export TLS_CA_FILE=${PATH_BASE}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=$ORG_MSPID
export CORE_PEER_TLS_ROOTCERT_FILE=${PATH_BASE}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem
export CORE_PEER_MSPCONFIGPATH=${PATH_BASE}/users/${ORG_ADMIN_USER_NAME}/msp
export CORE_PEER_ADDRESS=${PEER_CONTAINER_NAME}:${PEER_PORT}

LAST_ENV=signdata/last.env

if [ ! -f "$LAST_ENV" ]; then
    echo "No $LAST_ENV file, please run add.sh first"
    exit 1
fi

. ./$LAST_ENV

UPDATE_PB=signdata/${NEW_MSPID}_update_in_envelope.pb
if [ ! -f "$UPDATE_PB" ]; then
    echo "No $UPDATE_PB file, please run add.sh first"
    exit 1
fi

peer channel update -f ${UPDATE_PB} -c $CHANNEL_NAME -o ${ORDERER_HOSTPORT} --tls --cafile $TLS_CA_FILE
