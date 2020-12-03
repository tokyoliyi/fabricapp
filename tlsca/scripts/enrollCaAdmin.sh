#!/bin/bash

# enroll ca server admin account, export msp to ../volume/admin

. ./env.sh

# set environment values for fabric-ca-client
# in order to be more clearly, we use absolute path
export FABRIC_CA_CLIENT_HOME=${PWD}/$HOST_VOLUME_CLIENT/ca/admin
export FABRIC_CA_CLIENT_MSP=$FABRIC_CA_CLIENT_HOME/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/$HOST_VOLUME_SERVER/ca-cert.pem

# if exist admin's msp, delete it 
rm -rf $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll -d -u https://$FABRIC_CA_ADMIN:$FABRIC_CA_PASSWD@$TLS_CA_SERVER_HOST --enrollment.profile tls --csr.hosts ${CA_CSR_CN}

# rename keystore and tlscacerts
mv $FABRIC_CA_CLIENT_MSP/keystore/*_sk $FABRIC_CA_CLIENT_MSP/keystore/key.pem
mv $FABRIC_CA_CLIENT_MSP/tlscacerts/*.pem $FABRIC_CA_CLIENT_MSP/tlscacerts/tls-ca-cert.pem

cp ./config/mspconfig.yaml $FABRIC_CA_CLIENT_MSP/config.yaml
