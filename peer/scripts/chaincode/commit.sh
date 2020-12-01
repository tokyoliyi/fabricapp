#!/bin/bash

# this script run in cli container

if [ -z "$1" ]; then
    echo "No peer address"
    exit 1
fi

. ../env.sh
PATH_BASE=${PWD}/../${HOST_VOLUME_CLIENT}
export FABRIC_CFG_PATH=${FABRIC_CLIENT_BIN_PATH}/config

. ./last.env

export TLS_CA_FILE=${PATH_BASE}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=$ORG_MSPID
export CORE_PEER_TLS_ROOTCERT_FILE=${PATH_BASE}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem
export CORE_PEER_MSPCONFIGPATH=${PATH_BASE}/users/${ORG_ADMIN_USER_NAME}/msp
export CORE_PEER_ADDRESS=${PEER_CONTAINER_NAME}:${PEER_PORT}

PEER_LIST=" "
for arg in "$@"
do
    PEER_LIST="$PEER_LIST --peerAddresses $arg --tlsRootCertFiles $TLS_CA_FILE"
done
echo $PEER_LIST

peer lifecycle chaincode commit -o ${ORDERER_HOSTPORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --version ${CC_PKG_VER} --sequence ${CC_SEQUENCE} --tls true --cafile ${TLS_CA_FILE} $PEER_LIST

peer lifecycle chaincode querycommitted --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --tls true --cafile ${TLS_CA_FILE}
