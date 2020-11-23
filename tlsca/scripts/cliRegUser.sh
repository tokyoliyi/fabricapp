#!/bin/bash

# two input args
# $1 is username
# $2 is passwd
# $3 is reg type

if [ ! -f "./env.sh" ]; then
    ./init.sh
fi

if [ ! -f "./env.sh" ]; then
    echo "No env.sh file"
    exit 1
fi

. ./env.sh


USERNAME=$1
PASSWD=$2
TYPE=$3

if [ -z $USERNAME ]; then
    echo "No username"
    exit 1
fi

if [ -z $PASSWD ]; then
    echo "No passwd"
    exit 1
fi

if [ -z $TYPE ]; then
    TYPE=peer
fi

RAW_FABRIC_CA_CLIENT_HOME=$FABRIC_CA_CLIENT_HOME

CLIENT_HOME=${RAW_FABRIC_CA_CLIENT_HOME}/${FABRIC_CA_ADMIN}
MSPDIR=${RAW_FABRIC_CA_CLIENT_HOME}/${FABRIC_CA_ADMIN}/msp
TLS_CERT_FILE=${RAW_FABRIC_CA_CLIENT_HOME}/${FABRIC_CA_ADMIN}/msp/tlscacerts/tls-ca-cert.pem

docker exec \
    -e FABRIC_CA_CLIENT_HOME=$CLIENT_HOME \
    -e FABRIC_CA_CLIENT_MSPDIR=$MSPDIR \
    -e FABRIC_CA_CLIENT_TLS_CERTFILES=$TLS_CERT_FILE \
    $CA_CONTAINER_NAME fabric-ca-client register -d --id.name $USERNAME --id.secret $PASSWD --id.type $TYPE -u https://$TLS_CA_SERVER_HOST
