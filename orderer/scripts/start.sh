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
docker cp ./generateOrgMSP.sh $CA_CONTAINER_NAME:/tmp

docker exec $CA_CONTAINER_NAME sh -c "chown root:root /tmp/*.sh"
docker exec $CA_CONTAINER_NAME sh -c "chmod +x /tmp/*.sh"

# enroll current org ca's admin
echo "enroll current org's ca admin"
sleep 2
docker exec $CA_CONTAINER_NAME sh -c "/tmp/enrollCaAdmin.sh"

# 2. register/enroll peer for current org
echo "register peer and admin user"
sleep 2
docker exec $CA_CONTAINER_NAME sh -c "/tmp/registerUser.sh"

# 3. enroll peer's tls msp
echo "enroll tls, get tls msp"
sleep 2
docker exec $CA_CONTAINER_NAME sh -c "/tmp/enrollTLS.sh"

# 4. generate org's msp structure
# org's msp contain all certificate files(public file)
echo "generate org's msp structure"
sleep 2
docker exec $CA_CONTAINER_NAME sh -c "/tmp/generateOrgMSP.sh"

# 5. start cli container
echo "start cli container..."
sleep 2
docker-compose -f cli.yaml up -d

docker cp ./env.sh $CLI_CONTAINER_NAME:/tmp
docker cp ./createGenesisBlock.sh $CLI_CONTAINER_NAME:$CLI_WORKING_DIR
docker cp $CONFIGTX_FILE $CLI_CONTAINER_NAME:$CLI_WORKING_DIR

docker exec $CLI_CONTAINER_NAME sh -c "chown root:root ${CLI_WORKING_DIR}/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "chmod +x ${CLI_WORKING_DIR}/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "${CLI_WORKING_DIR}/createGenesisBlock.sh"


# 6. generate orderer genesis block 

# 5. start peer docker container
echo "Start peer and couchdb..."
docker-compose -f orderer.yaml up

echo "Start done."
