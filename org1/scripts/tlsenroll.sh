#!/bin/bash

# enroll tls, dump out tls-msp for current peer
# we need to connect tls ca server
# use the tls-ca-cert.pem ca file
. /tmp/globalenv.sh
. /tmp/localenv.sh

RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/peer0
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/peer0/tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/tls-ca-cert.pem

rm -rf $FABRIC_CA_CLIENT_MSPDIR

fabric-ca-client enroll -d -u https://$TLS_USER_ID:$TLS_USER_PASSWD@$TLS_CA_SERVER_HOST --enrollment.profile tls --csr.hosts '*.fabric.test'

# rename keystore and tlscacerts's file
mv $FABRIC_CA_CLIENT_MSPDIR/keystore/*_sk $FABRIC_CA_CLIENT_MSPDIR/keystore/key.pem
mv $FABRIC_CA_CLIENT_MSPDIR/tlscacerts/*.pem $FABRIC_CA_CLIENT_MSPDIR/tlscacerts/tls-ca-cert.pem

# fix docker container error file/folder permissions
# why 757 ?
# default docker volume's user/group is root
# but the host's current user to need to modify this msp
# so we need to rewrite the `other group` permission
chmod 757 -R $FABRIC_CA_CLIENT_HOME
