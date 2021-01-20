#!/bin/bash

. ./env.sh

CHANNEL_NAME=$1
if [ -z "$CHANNEL_NAME" ]; then
    echo "No channel name"
    exit 1
fi

CHAINCODE=$2
if [ -z "$CHAINCODE" ]; then
    echo "No chaincode name"
    exit 1
fi

# first create conf.yaml file

PATH_BASE=${PWD}/${HOST_VOLUME_CLIENT}

LOCALMSPID=$ORG_MSPID
PEER_ADDRESS=${PEER_CONTAINER_NAME}:${PEER_PORT}

TLS_ROOTCERT_FILE=${PATH_BASE}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem

ADMIN_KEY=${PATH_BASE}/users/orgadmin/msp/keystore/key.pem
ADMIN_CERT=${PATH_BASE}/users/orgadmin/msp/signcerts/cert.pem

WORKDIR=/tmp/discover
mkdir -p $WORKDIR

CONFIG_FILE=$WORKDIR/discoverconf.yaml

discover --configFile $CONFIG_FILE --peerTLSCA $TLS_ROOTCERT_FILE --userKey $ADMIN_KEY --userCert $ADMIN_CERT --MSP $LOCALMSPID saveConfig

# query info
echo "Discover peers info..."
discover --configFile $CONFIG_FILE peers --channel $CHANNEL_NAME --server $PEER_ADDRESS > $WORKDIR/peer.json

echo "Discover config info..."
discover --configFile $CONFIG_FILE config --channel $CHANNEL_NAME --server $PEER_ADDRESS > $WORKDIR/config.json

echo "Discover endorsers info..."
discover --configFile $CONFIG_FILE endorsers --channel $CHANNEL_NAME --server $PEER_ADDRESS --chaincode $CHAINCODE > $WORKDIR/endorsers.json

echo "Discover done, results saved in $WORKDIR"
