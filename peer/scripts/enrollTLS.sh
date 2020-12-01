#!/bin/bash

# enroll tls, dump out tls-msp for current peer
# we need to connect tls ca server
# use the tls-ca-cert.pem ca file
# peer's tls folder structure

. ./env.sh

ORG_BASE=${PWD}/${HOST_VOLUME_CLIENT}
PEER_BASE=$ORG_BASE/peers

export FABRIC_CA_CLIENT_HOME=$PEER_BASE/$PEER_NAME
export FABRIC_CA_CLIENT_MSPDIR=$FABRIC_CA_CLIENT_HOME/tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/tls-ca-cert.pem

rm -rf $FABRIC_CA_CLIENT_MSPDIR

fabric-ca-client enroll -d -u https://$TLS_USER_ID:$TLS_USER_PASSWD@$TLS_CA_SERVER_HOST --enrollment.profile tls --csr.hosts $TLS_USER_ID

# rename keystore and tlscacerts's file
mv $FABRIC_CA_CLIENT_MSPDIR/keystore/*_sk $FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
mv $FABRIC_CA_CLIENT_MSPDIR/tlscacerts/*.pem $FABRIC_CA_CLIENT_MSPDIR/tlscacerts/tls-ca-cert.pem
