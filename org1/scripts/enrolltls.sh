#!/bin/bash

# enroll tls, dump out tls-msp for current peer
# we need to connect tls ca server
# use the tls-ca-cert.pem ca file
. /tmp/env.sh

$RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/tls
export FABRIC_CA_CLIENT_MSP=$RAW_FABRIC_CA_CLIENT_HOME/tls/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/tls-ca-cert.pem

rm -rf $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll -d -u https://$TLS_USER_ID:$TLS_USER_PASSWD@$TLS_CA_SERVER_HOST --enrollment.profile tls --csr.hosts '*.fabric.test'
