#!/bin/bash

. /tmp/env.sh

CA_HOST=localhost:$FABRIC_CA_PORT
RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

# msp dir structure
# cacerts/
# keystore/
# signcerts/
# admincerts/ (if need admin permission)
# tlscacerts/ (if need or use another tls-msp structure)
# users/

# 1. register users

# first we need to set admin's msp dir as current working dir
# though client/admin/msp/tlscacerts/tls-ca-cert.pem is totally equal server/ca-cert.pem
# but in order to be more clearly, we use admin's tls-ca-cert.pem as certificate file
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem

peer_name=$PEER_NAME.$ORG_NAME.fabric.test

fabric-ca-client register -d --id.name $peer_name --id.secret $PEER_PASSWD --id.type peer -u https://$CA_HOST
fabric-ca-client register -d --id.name $ORG_ADMIN_USER_NAME --id.secret $ORG_ADMIN_USER_PASSWD --id.type admin -u https://$CA_HOST

# 2. enroll org's admin
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/$ORG_ADMIN_USER_NAME
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/$ORG_ADMIN_USER_NAME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp/cacerts/ca-cert.pem

fabric-ca-client enroll -d -u https://${ORG_ADMIN_USER_NAME}:${ORG_ADMIN_USER_PASSWD}@$CA_HOST
mv $FABRIC_CA_CLIENT_MSPDIR/keystore/*_sk $FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
mv $FABRIC_CA_CLIENT_MSPDIR/cacerts/* $FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem
cp -r $FABRIC_CA_CLIENT_MSPDIR/signcerts $FABRIC_CA_CLIENT_MSPDIR/admincerts

# 3. enroll peer
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/$PEER_NAME
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/$PEER_NAME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp/cacerts/ca-cert.pem

fabric-ca-client enroll -d -u https://${peer_name}:$PEER_PASSWD@$CA_HOST
mv $FABRIC_CA_CLIENT_MSPDIR/keystore/*_sk $FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
mv $FABRIC_CA_CLIENT_MSPDIR/cacerts/* $FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem

# copy admin's sign cert to peer's admincerts
mkdir -p $FABRIC_CA_CLIENT_MSPDIR/admincerts
cp $RAW_FABRIC_CA_CLIENT_HOME/$ORG_ADMIN_USER_NAME/msp/signcerts/cert.pem $FABRIC_CA_CLIENT_MSPDIR/admincerts/admin-cert.pem

# print user list
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_CLIENT_MSPDIR/cacerts/ca-cert.pem
fabric-ca-client identity list

# fix docker container error file/folder permissions
# why 757 ?
# default docker volume's user/group is root
# but the host's current user to need to modify this msp
# so we need to rewrite the `other group` permission
chmod 757 -R $RAW_FABRIC_CA_CLIENT_HOME