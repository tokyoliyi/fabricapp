#!/bin/bash

# enroll ca server admin account, export msp to ../volume/admin

. /tmp/env.sh

CA_HOST=localhost:$FABRIC_CA_PORT
RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

# set environment values for fabric-ca-client
# in order to be more clearly, we use absolute path
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN
export FABRIC_CA_CLIENT_MSP=$RAW_FABRIC_CA_CLIENT_HOME/$FABRIC_CA_ADMIN/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_SERVER_HOME/ca-cert.pem

# if exist admin's msp, delete it 
rm -rf $FABRIC_CA_CLIENT_HOME

# fabric-ca-client enroll -d -u https://$FABRIC_CA_ADMIN:$FABRIC_CA_PASSWD@$CA_HOST --enrollment.profile tls --csr.hosts '*.fabric.test'
fabric-ca-client enroll -d -u https://$FABRIC_CA_ADMIN:$FABRIC_CA_PASSWD@$CA_HOST

# rename keystore and cacerts's file
mv $FABRIC_CA_CLIENT_MSP/keystore/*_sk $FABRIC_CA_CLIENT_MSP/keystore/key.pem
mv $FABRIC_CA_CLIENT_MSP/cacerts/* $FABRIC_CA_CLIENT_MSP/cacerts/ca-cert.pem

# copy signcerts as admincerts
cp -r $FABRIC_CA_CLIENT_MSP/signcerts $FABRIC_CA_CLIENT_MSP/admincerts

# copy tls ca's cert to admin's relative path
if [ ! -d $FABRIC_CA_CLIENT_MSP/tlscacerts ]; then
    mkdir $FABRIC_CA_CLIENT_MSP/tlscacerts
fi
cp /tmp/tls-ca-cert.pem $FABRIC_CA_CLIENT_MSP/tlscacerts/tls-ca-cert.pem

# fix docker container error file/folder permissions
# why 757 ? 
# default docker volume's user/group is root
# but the host's current user to need to modify this msp
# so we need to rewrite the `other group` permission
chmod 757 -R $FABRIC_CA_CLIENT_HOME
