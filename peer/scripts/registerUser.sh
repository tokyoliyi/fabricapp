#!/bin/bash

. /tmp/env.sh

RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

# register users

# first we need to set admin's msp dir as current working dir
# though client/admin/msp/tlscacerts/tls-ca-cert.pem is totally equal server/ca-cert.pem
# but in order to be more clearly, we use admin's tls-ca-cert.pem as certificate file
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem

peer_name=$PEER_NAME.$ORG_NAME.fabric.test

# fabric-ca-client register -d --id.name $ORG_ADMIN_USER_NAME --id.secret $ORG_ADMIN_USER_PASSWD --id.type admin --id.attrs $ORG_ADMIN_USER_ATTRS -u https://0.0.0.0:$FABRIC_CA_PORT
fabric-ca-client register -d --id.name $peer_name --id.secret $PEER_PASSWD --id.type peer -u https://0.0.0.0:$FABRIC_CA_PORT

# enroll peer
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/$PEER_NAME
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/$PEER_NAME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp/cacerts/ca-cert.pem

fabric-ca-client enroll -d -u https://${peer_name}:$PEER_PASSWD@0.0.0.0:$FABRIC_CA_PORT
mv $FABRIC_CA_CLIENT_MSPDIR/keystore/*_sk $FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
mv $FABRIC_CA_CLIENT_MSPDIR/cacerts/* $FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem

# copy admin's cert to peer's admincerts
mkdir -p $FABRIC_CA_CLIENT_MSPDIR/admincerts
cp $RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp/signcerts/cert.pem $FABRIC_CA_CLIENT_MSPDIR/admincerts/cert.pem

# print user list
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem
fabric-ca-client identity list
