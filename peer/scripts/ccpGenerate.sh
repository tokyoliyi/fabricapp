#!/bin/bash

. ./env.sh


NETWORK_NAME=$DOCKER_NETWORK_NAME
ORG_NAME=$ORG_NAME
ORG_MSPID=$ORG_MSPID
PEER_NAME=$PEER_NAME
PEER_PORT=$PEER_PORT
CA_CSR_CN=$CA_CSR_CN
FABRIC_CA_PORT=$FABRIC_CA_PORT
PEER_CERT=${HOST_VOLUME_CLIENT}/peers/${PEER_NAME}/msp/signcerts/cert.pem
CA_CERT=${HOST_VOLUME_CLIENT}/peers/${PEER_NAME}/msp/cacerts/ca-cert.pem

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}


function yaml_ccp {
    local PP=$(one_line_pem $8)
    local CP=$(one_line_pem $9)
    sed -e "s/\${NETWORK_NAME}/$1/" \
        -e "s/\${ORG_NAME}/$2/" \
        -e "s/\${ORG_MSPID}/$3/" \
        -e "s/\${PEER_NAME}/$4/" \
        -e "s/\${PEER_PORT}/$5/" \
        -e "s/\${CA_CSR_CN}/$6/" \
        -e "s/\${FABRIC_CA_PORT}/$7/" \
        -e "s#\${PEER_CERT}#$PP#" \
        -e "s#\${CA_CERT}#$CP#" \
        ccpTemplate.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function json_ccp {
    local PP=$(one_line_pem $8)
    local CP=$(one_line_pem $9)
    sed -e "s/\${NETWORK_NAME}/$1/" \
        -e "s/\${ORG_NAME}/$2/" \
        -e "s/\${ORG_MSPID}/$3/" \
        -e "s/\${PEER_NAME}/$4/" \
        -e "s/\${PEER_PORT}/$5/" \
        -e "s/\${CA_CSR_CN}/$6/" \
        -e "s/\${FABRIC_CA_PORT}/$7/" \
        -e "s#\${PEER_CERT}#$PP#" \
        -e "s#\${CA_CERT}#$CP#" \
        ccpTemplate.json
}

echo "$(yaml_ccp $NETWORK_NAME $ORG_NAME $ORG_MSPID $PEER_NAME $PEER_PORT $CA_CSR_CN $FABRIC_CA_PORT $PEER_CERT $CA_CERT)" > ${HOST_VOLUME_CLIENT}/connection.yaml
echo "$(json_ccp $NETWORK_NAME $ORG_NAME $ORG_MSPID $PEER_NAME $PEER_PORT $CA_CSR_CN $FABRIC_CA_PORT $PEER_CERT $CA_CERT)" > ${HOST_VOLUME_CLIENT}/connection.json
