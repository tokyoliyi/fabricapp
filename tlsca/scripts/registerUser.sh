#!/bin/bash

. /tmp/env.sh

RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

# register users

# first we need to set admin's msp dir as current working dir
# though client/admin/msp/tlscacerts/tls-ca-cert.pem is totally equal server/ca-cert.pem
# but in order to be more clearly, we use admin's tls-ca-cert.pem as certificate file
export FABRIC_CA_CLIENT_HOME=$RAW_FABRIC_CA_CLIENT_HOME/admin
export FABRIC_CA_CLIENT_MSPDIR=$RAW_FABRIC_CA_CLIENT_HOME/admin/msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$RAW_FABRIC_CA_CLIENT_HOME/admin/msp/tlscacerts/tls-ca-cert.pem

for idx in "${REG_PEERS[@]}"
do
    fabric-ca-client register -d --id.name $idx --id.secret passwd --id.type peer -u https://$TLS_CA_SERVER_HOST
done

for idx in "${REG_ORDERERS[@]}"
do
    fabric-ca-client register -d --id.name $idx --id.secret passwd --id.type orderer -u https://$TLS_CA_SERVER_HOST
done

fabric-ca-client identity list
