#!/bin/bash

# enroll ca server admin account
# host dir client/orgX
# container dir /etc/fabricapp/client
# host:container ->   client/orgX:/etc/fabricapp/client
# local msp dir should be client/orgX/ca/admin/msp
# so container ca home should be /etc/fabricapp/client/ca

# . /tmp/env.sh

. ./env.sh


CA_HOST=${CA_CSR_CN}:$FABRIC_CA_PORT

# set environment values for fabric-ca-client
# in order to be more clearly, we use absolute path
# fabric ca client home must use absolute path
export FABRIC_CA_CLIENT_HOME=${PWD}/$HOST_VOLUME_CLIENT/ca/admin
export FABRIC_CA_CLIENT_MSP=$FABRIC_CA_CLIENT_HOME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/$HOST_VOLUME_SERVER/ca-cert.pem

# if exist admin's msp, delete it 
rm -rf $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll -d -u https://$FABRIC_CA_ADMIN:$FABRIC_CA_PASSWD@$CA_HOST

# rename keystore and cacerts's file
mv $FABRIC_CA_CLIENT_MSP/cacerts/* $FABRIC_CA_CLIENT_MSP/cacerts/ca-cert.pem
mv $FABRIC_CA_CLIENT_MSP/keystore/*_sk $FABRIC_CA_CLIENT_MSP/keystore/key.pem
cp ./config/mspconfig.yaml $FABRIC_CA_CLIENT_MSP/config.yaml
