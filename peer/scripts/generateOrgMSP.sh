#!/bin/bash

. /tmp/env.sh

MSPDIR=$FABRIC_CA_CLIENT_HOME/msp

mkdir -p $MSPDIR/{admincerts,cacerts,tlscacerts,users}

# admidcerts/ file come from admin's signcerts/cert.pem
cp $FABRIC_CA_CLIENT_HOME/$ORG_ADMIN_USER_NAME/msp/signcerts/cert.pem $MSPDIR/admincerts/cert.pem

# cacerts come from current org ca server 's ca-cert.pem
# but we use cadmin's cacerts/ca-cert.pem file, though they are equal
cp $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp/cacerts/ca-cert.pem $MSPDIR/cacerts/ca-cert.pem

# tlscacerts from peer's tls-msp
cp $FABRIC_CA_CLIENT_HOME/$PEER_NAME/tls-msp/tlscacerts/tls-ca-cert.pem $MSPDIR/tlscacerts/tls-ca-cert.pem