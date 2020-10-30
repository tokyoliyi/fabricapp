#!/bin/bash

# enroll ca server admin account, export msp to ../volume/admin

. /tmp/env.sh

RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

# set environment values for fabric-ca-client
# in order to be more clearly, we use absolute path
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/admin
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/admin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_SERVER_HOME/ca-cert.pem

# if exist admin's msp, delete it 
rm -rf $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll -d -u https://$FABRIC_CA_ADMIN:$FABRIC_CA_PASSWD@$TLS_CA_SERVER_HOST --enrollment.profile tls --csr.hosts '*.fabric.test'

# rename keystore and tlscacerts
mv $FABRIC_CA_CLIENT_MSPDIR/keystore/*_sk $FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
mv $FABRIC_CA_CLIENT_MSPDIR/tlscacerts/*.pem $FABRIC_CA_CLIENT_MSPDIR/tlscacerts/tls-ca-cert.pem

# fix docker container error file/folder permissions
# why 757 ? 
# default docker volume's user/group is root
# but the host's current user to need to modify this msp
# so we need to rewrite the `other group` permission
chmod 757 -R $FABRIC_CA_CLIENT_HOME
