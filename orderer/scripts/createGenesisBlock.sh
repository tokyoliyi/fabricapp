#!/bin/bash

. /tmp/env.sh

# create channel tx
export FABRIC_CFG_PATH=$CLI_WORKING_DIR
configtxgen -profile $PROFILE_ORDERER_GENESIS_NAME -outputBlock genesis.block -channelID $SYS_CHANNEL_NAME
configtxgen -profile $PROFILE_CHANNEL_NAME -outputCreateChannelTx channel.tx -channelID $APP_CHANNEL_NAME

# copy to orderer's home
cp genesis.block $FABRIC_CA_CLIENT_HOME/${ORG_NAME}/peers/${PEER_NAME}/genesis.block

# create peer's anchor tx
for idx in "${MSPID_LIST[@]}"
do
    configtxgen -profile $PROFILE_CHANNEL_NAME -outputAnchorPeersUpdate ${idx}anchors.tx -channelID $APP_CHANNEL_NAME -asOrg $idx
done
