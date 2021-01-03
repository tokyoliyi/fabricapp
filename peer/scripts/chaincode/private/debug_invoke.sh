#!/bin/bash

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

peer chaincode invoke -o ${ORDERER_HOSTPORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --tls --cafile $TLS_CA_FILE -C ${APP_CHANNEL_NAME} -n ${CC_NAME} $PEER_LIST -c '{"function":"InitLedger","Args":[]}'

peer chaincode query -C ${APP_CHANNEL_NAME} -n ${CC_NAME} -c '{"Args":["GetAllAssets"]}'
