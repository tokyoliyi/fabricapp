#!/bin/bash

. ../env.sh


MSPNAME=$1
if [ -z "$MSPNAME" ]; then
    echo "No organization name"
    exit 1
fi

cp newtxconfig.yaml tmp/configtx.yaml

cd tmp/


export FABRIC_CFG_PATH=$PWD
configtxgen -printOrg $MSPNAME > ${MSPNAME}.json

# add anchor config

PEER="peer0.org3.fabric.test"
PORT=7051

VALUES='.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "PEERHOST","port": PEERPORT}]},"version": "0"}}'
VALUES=${VALUES/PEERHOST/$PEER}
VALUES=${VALUES/PEERPORT/$PORT}

jq "$VALUES" ${MSPNAME}.json > ${MSPNAME}_full.json
