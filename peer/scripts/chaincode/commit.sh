#!/bin/bash

# this script run in cli container

if [ -z "$1" ]; then
    echo "No peer address"
    exit 1
fi

. ./chaincode.env

. ./last.env

PEER_LIST=" "
for arg in "$@"
do
    PEER_LIST="$PEER_LIST --peerAddresses $arg --tlsRootCertFiles $TLS_CA_FILE"
done
echo $PEER_LIST

peer lifecycle chaincode commit -o ${ORDERER_HOSTPORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --version ${CC_PKG_VER} --sequence ${CC_SEQUENCE} --tls true --cafile ${TLS_CA_FILE} $PEER_LIST

peer lifecycle chaincode querycommitted --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --tls true --cafile ${TLS_CA_FILE}
