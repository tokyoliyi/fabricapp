#!/bin/bash

# this script run in cli container

. /tmp/envcc.sh

# export go path
export PATH=/usr/local/go/bin:$PATH

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=$ORG_MSPID
export CORE_PEER_TLS_ROOTCERT_FILE=${FABRIC_CA_CLIENT_HOME}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem
export CORE_PEER_MSPCONFIGPATH=${FABRIC_CA_CLIENT_HOME}/users/${ORG_ADMIN_USER_NAME}/msp
export CORE_PEER_ADDRESS=${PEER_CONTAINER_NAME}:${PEER_PORT}

export TLS_CA_FILE=${FABRIC_CA_CLIENT_HOME}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem
export ORDERER_HOST=orderer0.org0.fabric.test
export ORDERER_HOSTPORT=orderer0.org0.fabric.test:7050

peer lifecycle chaincode commit -o ${ORDERER_HOSTPORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --version ${CC_PKG_VER} --sequence ${CC_SEQUENCE} --tls true --cafile ${TLS_CA_FILE} --peerAddresses peer0.org1.fabric.test:7051 --tlsRootCertFiles ${TLS_CA_FILE} --peerAddresses peer0.org2.fabric.test:7051 --tlsRootCertFiles ${TLS_CA_FILE}

peer lifecycle chaincode querycommitted --channelID $APP_CHANNEL_NAME --name $CC_NAME --tls true --cafile $TLS_CA_FILE
