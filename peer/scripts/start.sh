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
docker-compose -f ca.yaml up -d

echo "sleep 3s"
sleep 3

# copy all needed file to /tmp/
docker exec $CA_CONTAINER_NAME sh -c "cd /tmp && rm -f *.sh"
docker cp $TLS_CA_CERT_FILE $CA_CONTAINER_NAME:/tmp

docker cp ./env.sh $CA_CONTAINER_NAME:/tmp
docker cp ./enrollTLS.sh $CA_CONTAINER_NAME:/tmp
docker cp ./enrollCaAdmin.sh $CA_CONTAINER_NAME:/tmp
docker cp ./registerUser.sh $CA_CONTAINER_NAME:/tmp

docker exec $CA_CONTAINER_NAME sh -c "chown root:root /tmp/*.sh"
docker exec $CA_CONTAINER_NAME sh -c "chmod +x /tmp/*.sh"

# enroll current org ca's admin
echo "enroll current org's ca admin"
docker exec $CA_CONTAINER_NAME sh -c "/tmp/enrollCaAdmin.sh"

# 2. register/enroll peer for current org
echo "register peer and admin user"
sleep 2
docker exec $CA_CONTAINER_NAME sh -c "/tmp/registerUser.sh"

# 3. enroll peer's tls msp
echo "enroll tls, get tls msp"
docker exec $CA_CONTAINER_NAME sh -c "/tmp/enrollTLS.sh"
sleep 2

# 4. start peer docker container
echo "Start peer and couchdb..."
docker-compose -f peer.yaml up -d

echo "Start done."
