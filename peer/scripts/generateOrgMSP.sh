#!/bin/bash

. /tmp/env.sh

RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME
ORG_BASE=$FABRIC_CA_CLIENT_HOME
PEER_BASE=$ORG_BASE/peers
CA_BASE=$ORG_BASE/ca
CA_FILE=$CA_BASE/admin/msp/cacerts/ca-cert.pem
TLS_CA_FILE=$PEER_BASE/$PEER_NAME/tls-msp/tlscacerts/tls-ca-cert.pem

MSPDIR=$ORG_BASE/msp

mkdir -p $MSPDIR/{cacerts,tlscacerts,users}

# admidcerts/ file come from admin's signcerts/cert.pem
# cp $FABRIC_CA_CLIENT_HOME/$ORG_ADMIN_USER_NAME/msp/signcerts/cert.pem $MSPDIR/admincerts/admin-cert.pem

# cacerts come from current org ca server 's ca-cert.pem
# but we use cadmin's cacerts/ca-cert.pem file, though they are equal
cp $CA_FILE $MSPDIR/cacerts/ca-cert.pem

# tlscacerts from peer's tls-msp
cp $TLS_CA_FILE $MSPDIR/tlscacerts/tls-ca-cert.pem
cp /tmp/examplemspconfig.yaml $MSPDIR/config.yaml

# fix docker container error file/folder permissions
# default docker volume's user/group is root
# but the host's current user to need to modify this msp
# so we need to rewrite the `other group` permission
