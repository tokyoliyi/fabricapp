#!/bin/bash

# . /tmp/env.sh
. ./env.sh

ORG_BASE=${PWD}/${HOST_VOLUME_CLIENT}
PEER_BASE=${ORG_BASE}/peers
CA_BASE=${ORG_BASE}/ca
CA_FILE=${CA_BASE}/admin/msp/cacerts/ca-cert.pem
TLS_CA_FILE=${PEER_BASE}/${PEER_NAME}/tls-msp/tlscacerts/tls-ca-cert.pem

MSPDIR=${ORG_BASE}/msp

mkdir -p ${MSPDIR}/{cacerts,tlscacerts,users}

# cacerts come from current org ca server 's ca-cert.pem
# but we use cadmin's cacerts/ca-cert.pem file, though they are equal
cp $CA_FILE $MSPDIR/cacerts/ca-cert.pem

# tlscacerts from peer's tls-msp
cp $TLS_CA_FILE $MSPDIR/tlscacerts/tls-ca-cert.pem
cp ./config/mspconfig.yaml $MSPDIR/config.yaml
