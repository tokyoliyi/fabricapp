#!/bin/bash

# enroll ca server admin account
# host dir client/orgX
# container dir /etc/fabricapp/client
# host:container ->   client/orgX:/etc/fabricapp/client
# local msp dir should be client/orgX/ca/admin/msp
# so container ca home should be /etc/fabricapp/client/ca

. /tmp/env.sh

CA_HOST=localhost:$FABRIC_CA_PORT
RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

# set environment values for fabric-ca-client
# in order to be more clearly, we use absolute path
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/ca/admin
export FABRIC_CA_CLIENT_MSP=$FABRIC_CA_CLIENT_HOME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_SERVER_HOME/ca-cert.pem

# if exist admin's msp, delete it 
rm -rf $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll -d -u https://$FABRIC_CA_ADMIN:$FABRIC_CA_PASSWD@$CA_HOST

# rename keystore and cacerts's file
mv $FABRIC_CA_CLIENT_MSP/cacerts/* $FABRIC_CA_CLIENT_MSP/cacerts/ca-cert.pem
mv $FABRIC_CA_CLIENT_MSP/keystore/*_sk $FABRIC_CA_CLIENT_MSP/keystore/key.pem
cp /tmp/examplemspconfig.yaml $FABRIC_CA_CLIENT_MSP/config.yaml