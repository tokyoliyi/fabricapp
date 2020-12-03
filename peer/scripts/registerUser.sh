#!/bin/bash

# host dir client/orgX
# container dir /etc/fabricapp/client
# host:container ->   client/orgX:/etc/fabricapp/client

# . /tmp/env.sh
. ./env.sh

CA_HOST=${CA_CSR_CN}:$FABRIC_CA_PORT

ORG_BASE=${PWD}/${HOST_VOLUME_CLIENT}
CA_BASE=$ORG_BASE/ca
PEER_BASE=$ORG_BASE/peers
USER_BASE=$ORG_BASE/users
CA_FILE=$CA_BASE/admin/msp/cacerts/ca-cert.pem

# msp dir structure
# cacerts/
# keystore/
# signcerts/
# tlscacerts/ (if need or use another tls-msp structure)
# users/

# 1. register users
# first we need to set admin's msp dir as current working dir
# though client/admin/msp/tlscacerts/tls-ca-cert.pem is totally equal server/ca-cert.pem
# but in order to be more clearly, we use admin's tls-ca-cert.pem as certificate file
export FABRIC_CA_CLIENT_HOME=$CA_BASE/admin
export FABRIC_CA_CLIENT_MSPDIR=$FABRIC_CA_CLIENT_HOME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_FILE

peer_name=$PEER_NAME.$ORG_NAME.${TLD}

fabric-ca-client register -d --id.name $ORG_ADMIN_USER_NAME --id.secret $ORG_ADMIN_USER_PASSWD --id.type admin --id.attrs $ORG_ADMIN_USER_ATTRS -u https://$CA_HOST
fabric-ca-client register -d --id.name $peer_name --id.secret $PEER_PASSWD --id.type peer -u https://$CA_HOST

# 2. enroll org's admin (export)
export FABRIC_CA_CLIENT_HOME=$USER_BASE/$ORG_ADMIN_USER_NAME
export FABRIC_CA_CLIENT_MSPDIR=$FABRIC_CA_CLIENT_HOME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_FILE

fabric-ca-client enroll -d -u https://${ORG_ADMIN_USER_NAME}:${ORG_ADMIN_USER_PASSWD}@$CA_HOST
mv $FABRIC_CA_CLIENT_MSPDIR/cacerts/* $FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem
mv $FABRIC_CA_CLIENT_MSPDIR/keystore/*_sk $FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
cp ./config/mspconfig.yaml $FABRIC_CA_CLIENT_MSPDIR/config.yaml

# 3. enroll peer
export FABRIC_CA_CLIENT_HOME=$PEER_BASE/$PEER_NAME
export FABRIC_CA_CLIENT_MSPDIR=$FABRIC_CA_CLIENT_HOME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_FILE

fabric-ca-client enroll -d -u https://${peer_name}:$PEER_PASSWD@$CA_HOST
mv $FABRIC_CA_CLIENT_MSPDIR/cacerts/* $FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem
mv $FABRIC_CA_CLIENT_MSPDIR/keystore/*_sk $FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
cp ./config/mspconfig.yaml $FABRIC_CA_CLIENT_MSPDIR/config.yaml

# print user list
export FABRIC_CA_CLIENT_HOME=$USER_BASE/$ORG_ADMIN_USER_NAME
export FABRIC_CA_CLIENT_MSPDIR=$FABRIC_CA_CLIENT_HOME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_FILE
fabric-ca-client identity list
