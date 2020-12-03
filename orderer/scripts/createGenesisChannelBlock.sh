#!/bin/bash

# for simple purpose, we don't enable mutual TLS between client and orderer admin server

. ./env.sh

# check if configtx.yaml file exists
CONFIGTX_FILE=./orgmsps/configtx.yaml
if [ ! -f "$CONFIGTX_FILE" ]; then
    echo "No $CONFIGTX_FILE, please copy from ./config/txconfig.yaml, then modify it"
    exit 1
fi

PROFILE_CHANNEL_NAME=$1
if [ -z "$PROFILE_CHANNEL_NAME" ]; then
    echo "No profile channel name"
    exit 1
fi

APP_CHANNEL_NAME=$2
if [ -z "$APP_CHANNEL_NAME" ]; then
    echo "No channel name"
    exit 1
fi

WORKDIR=./orgmsps

cd $WORKDIR

export FABRIC_CFG_PATH=$PWD

echo "Profile Name: $PROFILE_CHANNEL_NAME"

# 1. generate app channel block
configtxgen -profile $PROFILE_CHANNEL_NAME -outputBlock ${APP_CHANNEL_NAME}.tx -channelID $APP_CHANNEL_NAME

# 2. join orderer into the channel
export ORDERER_ADMIN_HOSTPORT=${PEER_CONTAINER_NAME}:${ORDERER_ADMIN_PORT}
osnadmin channel join --channel-id $APP_CHANNEL_NAME --config-block ${APP_CHANNEL_NAME}.tx -o $ORDERER_ADMIN_HOSTPORT 
