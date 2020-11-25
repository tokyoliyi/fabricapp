#!/bin/bash

# this script run in cli container

. /tmp/envcc.sh

# export go path
export PATH=/usr/local/go/bin:$PATH

# 1. package
cd $CC_SRC_PATH
go mod vendor
cd ../

peer lifecycle chaincode package ${CC_PKG_NAME} --path ${CC_SRC_PATH} --lang ${CC_SRC_LANG} --label ${CC_LABEL}

ls -l

# 2. install on peer
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=$ORG_MSPID
export CORE_PEER_TLS_ROOTCERT_FILE=${FABRIC_CA_CLIENT_HOME}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem
export CORE_PEER_MSPCONFIGPATH=${FABRIC_CA_CLIENT_HOME}/users/${ORG_ADMIN_USER_NAME}/msp
export CORE_PEER_ADDRESS=${PEER_CONTAINER_NAME}:${PEER_PORT}

peer lifecycle chaincode install ${CC_PKG_NAME}

peer lifecycle chaincode queryinstalled

# 3. approve chaincode definition
export CC_PKG_ID=`peer lifecycle chaincode queryinstalled -O json | jq -r '.installed_chaincodes[].package_id'`
export TLS_CA_FILE=${FABRIC_CA_CLIENT_HOME}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem
export ORDERER_HOST=orderer0.org0.fabric.test
export ORDERER_HOSTPORT=orderer0.org0.fabric.test:7050

peer lifecycle chaincode approveformyorg -o $ORDERER_HOSTPORT --ordererTLSHostnameOverride $ORDERER_HOST --channelID $APP_CHANNEL_NAME --name $CC_NAME --version $CC_PKG_VER --package-id $CC_PKG_ID --sequence $CC_SEQUENCE --tls true --cafile $TLS_CA_FILE

peer lifecycle chaincode checkcommitreadiness --channelID $APP_CHANNEL_NAME --name $CC_NAME --version $CC_PKG_VER --sequence $CC_SEQUENCE --tls true --cafile $TLS_CA_FILE
