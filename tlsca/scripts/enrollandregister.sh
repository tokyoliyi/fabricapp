#!/bin/bash

# enroll ca server admin account, export msp to ../volume/admin

. /tmp/env.sh

HOST=0.0.0.0:$FABRIC_CA_PORT
RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

REG_ORDERERS=("orderer0.org0.fabric.test")
REG_PEERS=("peer0.org1.fabric.test" "peer0.org2.fabric.test" "peer0.org3.fabric.test")

# set environment values for fabric-ca-client
# in order to be more clearly, we use absolute path
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/admin
export FABRIC_CA_CLIENT_MSP=$RAW_FABRIC_CA_CLIENT_HOME/admin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_SERVER_HOME/ca-cert.pem

# if exist admin's msp, delete it 
rm -rf $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll -d -u https://$FABRIC_CA_ADMIN:$FABRIC_CA_PASSWD@$HOST --enrollment.profile tls --csr.hosts '*.fabric.test'

# rename keystore and tlscacerts
mv $FABRIC_CA_CLIENT_HOME/msp/keystore/*_sk $FABRIC_CA_CLIENT_HOME/msp/keystore/key.pem
mv $FABRIC_CA_CLIENT_HOME/msp/tlscacerts/*.pem $FABRIC_CA_CLIENT_HOME/msp/tlscacerts/tls-ca-cert.pem

# fix docker container error file/folder permissions
# why 757 ? 
# default docker volume's user/group is root
# but the host's current user to need to modify this msp
# so we need to rewrite the `other group` permission
chmod 757 -R $FABRIC_CA_CLIENT_HOME

# register other users

# first we need to set admin's msp dir as current working dir
# though client/admin/msp/tlscacerts/tls-ca-cert.pem is totally equal server/ca-cert.pem
# but in order to be more clearly, we use admin's tls-ca-cert.pem as certificate file
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/admin
export FABRIC_CA_CLIENT_MSP=$RAW_FABRIC_CA_CLIENT_HOME/admin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$RAW_FABRIC_CA_CLIENT_HOME/admin/msp/tlscacerts/tls-ca-cert.pem

for idx in "${REG_PEERS[@]}"
do
    fabric-ca-client register -d --id.name $idx --id.secret passwd --id.type peer -u https://$HOST
done

for idx in "${REG_ORDERERS[@]}"
do
    fabric-ca-client register -d --id.name $idx --id.secret passwd --id.type orderer -u https://$HOST
done

fabric-ca-client identity list
