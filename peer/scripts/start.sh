#!/bin/bash

# import system wide env.sh
./init.sh

. ./env.sh

# check if tls-ca-cert.pem file exist
if [ ! -f "$TLS_CA_CERT_FILE" ]; then
    echo "$TLS_CA_CERT_FILE doesn't exist"
    exit -1
fi

# 1. start ca docker
# change file/folder owner permission
docker-compose -f dockers/ca.yaml up -d
sudo chown -R ${USER}:${GROUP} $HOST_VOLUME_BASE

echo "sleep 3s"
sleep 3

# 2. enroll rca's admin user
echo "enroll current org's ca admin"
./enrollCaAdmin.sh

# 3. register/enroll peer for current org
echo "register peer and admin user"
./registerUser.sh

# 4. enroll peer's tls msp
echo "enroll tls, to get tls msp"
./enrollTLS.sh

# 5. generate org's msp structure
# org's msp contain all certificate files(public file)
echo "generate org's msp structure"
./generateOrgMSP.sh

# 6. generate connection profiles
./ccpGenerate.sh

# 7. start peer docker container
echo "Start peer and couchdb..."
docker-compose -f dockers/peer.yaml up -d

# 8. change file/foler owner permission
sudo chown -R ${USER}:${GROUP} $HOST_VOLUME_BASE

echo "Start done."
