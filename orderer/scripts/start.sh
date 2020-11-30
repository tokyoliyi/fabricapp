#!/bin/bash

# import system wide env.sh
./init.sh

. ./env.sh

# check if tls-ca-cert.pem file exist
if [ ! -f "$TLS_CA_CERT_FILE" ]; then
    echo "$TLS_CA_CERT_FILE doesn't exist"
    exit -1
fi

# check configtx.yaml file and org's msp path exist
if [ ! -f "$CONFIGTX_FILE" ]; then
    echo "$CONFIGTX_FILE doesn't exist"
    exit -1
fi


# 1. start ca docker
docker-compose -f ./dockers/ca.yaml up -d

echo "sleep 3s"
sleep 3
sudo chown -R ${USER}:${GROUP} $HOST_VOLUME_BASE

# 2. enroll current org ca's admin
echo "enroll current org's ca admin"
./enrollCaAdmin.sh

# 3. register/enroll peer for current org
echo "register peer and admin user"
./registerUser.sh

# 4. enroll orderer node's tls msp
echo "enroll tls, get tls msp"
./enrollTLS.sh

# 5. generate org's msp structure
# org's msp contain all certificate files(public file)
echo "generate org's msp structure"
./generateOrgMSP.sh

# 6. start peer docker container
echo "Start orderer node..."
docker-compose -f ./dockers/orderer.yaml up -d

# 7. generate genesis channel block
./createGenesisChannelBlock.sh

# 8.
sudo chown -R ${USER}:${GROUP} $HOST_VOLUME_BASE

echo "Start done."
