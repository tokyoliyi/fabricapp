#!/bin/bash

# this script run in cli container

. ./chaincode.env

CC_SRC_PATH=$1
if [ ! -d "$CC_SRC_PATH" ]; then
    echo "No chaincode path" 
    exit 1
fi

CC_NAME=$2
if [ -z "$CC_NAME" ]; then
    echo "No chaincode name"
    exit 1
fi

CC_PKG_VER=$3
if [ -z "$CC_PKG_VER" ]; then
    echo "No package version"
    exit 1
fi

CC_SEQUENCE=$4
if [ -z "$CC_SEQUENCE" ]; then
    echo "No package sequence"
    exit 1
fi

APP_CHANNEL_NAME=$5
if [ -z "$APP_CHANNEL_NAME" ]; then
    echo "No channel name"
    exit 1
fi

CC_END_POLICY=$6
if [ -z "$CC_END_POLICY" ]; then
    echo "No private endorse policy"
    echo "e.g \"OR('org1MSP.member','org2MSP.member')\""
    exit 1
fi

CC_COLLECTION_FILE=$7
if [ -z "$CC_COLLECTION_FILE" ]; then
    echo "$No collection file"
    exit 1
fi

# current only support chaincode writes by golang


CC_PKG_NAME=${CC_NAME}_${CC_PKG_VER}.tar.gz
CC_LABEL=${CC_NAME}_${CC_PKG_VER}

# save args into last.env
# then used by commit.sh
echo "export CC_SRC_PATH=$CC_SRC_PATH" > last.env
echo "export CC_NAME=$CC_NAME" >> last.env 
echo "export CC_PKG_VER=$CC_PKG_VER" >> last.env
echo "export CC_SEQUENCE=$CC_SEQUENCE" >> last.env
echo "export APP_CHANNEL_NAME=$APP_CHANNEL_NAME" >> last.env
echo "export CC_END_POLICY=\"$CC_END_POLICY\"" >> last.env
echo "export CC_COLLECTION_FILE=$CC_COLLECTION_FILE" >> last.env

# 1. package
cd $CC_SRC_PATH
echo "go mode vendor..."
go mod vendor
cd ../

echo "package $CC_PKG_NAME"
peer lifecycle chaincode package ${CC_PKG_NAME} --path ${CC_SRC_PATH} --lang ${CC_SRC_LANG} --label ${CC_LABEL}

# 2. install on peer
echo "install chaincode ${CC_PKG_NAME}"
peer lifecycle chaincode install ${CC_PKG_NAME}

peer lifecycle chaincode queryinstalled

# 3. approve chaincode definition
# https://stedolan.github.io/jq/manual/
export CC_PKG_ID=$(peer lifecycle chaincode queryinstalled -O json | jq --arg LABEL $CC_LABEL -r '.installed_chaincodes[] | select(.label==$LABEL).package_id')
echo "package id is: $CC_PKG_ID"
if [ -z "$CC_PKG_ID" ]; then
    echo "Get package id failed"
    exit 1
fi

peer lifecycle chaincode approveformyorg -o ${ORDERER_HOSTPORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --version ${CC_PKG_VER} --package-id ${CC_PKG_ID} --sequence ${CC_SEQUENCE} --tls true --cafile ${TLS_CA_FILE} --signature-policy ${CC_END_POLICY} --collections-config ${CC_COLLECTION_FILE}

peer lifecycle chaincode checkcommitreadiness --channelID ${APP_CHANNEL_NAME} --name ${CC_NAME} --version ${CC_PKG_VER} --sequence ${CC_SEQUENCE} --tls true --cafile ${TLS_CA_FILE} --signature-policy ${CC_END_POLICY} -- collections-config ${CC_COLLECTION_FILE}
