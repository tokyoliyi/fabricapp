#!/bin/bash

# for simple purpose, we don't enable mutual TLS between client and orderer admin server

. ./env.sh

# check if configtx.yaml file exists
if [ ! -f "$CONFIGTX_FILE" ]; then
    echo "No $CONFIGTX_FILE"
    exit 1
fi

if [ ! -z "$1" ]; then
    PROFILE_CHANNEL_NAME=$1
fi

if [ ! -z "$2" ]; then
    APP_CHANNEL_NAME=$2
fi

ORG_BASE=${PWD}/${CLI_HOST_VOLUME}

cp $CONFIGTX_FILE $ORG_BASE/configtx.yaml

cd $ORG_BASE

export FABRIC_CFG_PATH=$PWD

echo "Profile Name: $PROFILE_CHANNEL_NAME"

# 1. generate app channel block
configtxgen -profile $PROFILE_CHANNEL_NAME -outputBlock ${APP_CHANNEL_NAME}.tx -channelID $APP_CHANNEL_NAME

# 2. join orderer into the channel
export ORDERER_ADMIN_HOSTPORT=${PEER_CONTAINER_NAME}:${ORDERER_ADMIN_PORT}
osnadmin channel join --channel-id $APP_CHANNEL_NAME --config-block ${APP_CHANNEL_NAME}.tx -o $ORDERER_ADMIN_HOSTPORT 
