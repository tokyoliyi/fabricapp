#!/bin/bash

. ./env.sh

NETWORK_NAME=$DOCKER_NETWORK_NAME

ORG_NAME=$ORG_NAME
ORG_MSPID=$ORG_MSPID

PEER_HOSTPORT=${PEER_NAME}.${ORG_NAME}.${TLD}:${PEER_PORT}
PEER_TLS_CERT=${HOST_VOLUME_CLIENT}/peers/${PEER_NAME}/tls-msp/signcerts/cert.pem

RCA_HOSTPORT=$CA_CSR_CN:$FABRIC_CA_PORT
RCA_CERT=${HOST_VOLUME_CLIENT}/peers/${PEER_NAME}/msp/cacerts/ca-cert.pem

TLS_CA_HOSTPORT=$TLS_CA_SERVER_HOST
TLS_CA_CERT=${HOST_VOLUME_CLIENT}/peers/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem

python generateConnectionFile.py --project $NETWORK_NAME --orgname $ORG_NAME --mspid $ORG_MSPID --peer $PEER_HOSTPORT --peertlscert $PEER_TLS_CERT --rca $RCA_HOSTPORT --rcacert $RCA_CERT --tlsca $TLS_CA_HOSTPORT --tlscacert $TLS_CA_CERT
