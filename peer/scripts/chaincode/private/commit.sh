#!/bin/bash

if [ -z "$1" ]; then
    echo "No peer address"
    echo "e.g ./commit.sh peer0.org1.fabric.test:7051 peer0.org2.fabric.test:7051"
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

peer lifecycle chaincode commit -o ${ORDERER_HOSTPORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --version ${CC_PKG_VER} --sequence ${CC_SEQUENCE} --tls true --cafile ${TLS_CA_FILE} $PEER_LIST --signature-policy ${CC_END_POLICY} --collections-config ${CC_COLLECTION_FILE}

peer lifecycle chaincode querycommitted --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --tls true --cafile ${TLS_CA_FILE}
