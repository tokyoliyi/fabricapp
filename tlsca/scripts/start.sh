#!/bin/bash

# import system wide env.sh
./init.sh

. ./env.sh

# start ca docker
docker-compose -f ca.yaml up -d
echo "Fabric CA Server started..."
echo "sleep 3s"
sleep 3

# copy all needed scripts to /tmp/
# first remove old/remain files
docker exec $CA_CONTAINER_NAME sh -c "cd /tmp && rm -f *.sh"

docker cp ./env.sh $CA_CONTAINER_NAME:/tmp
docker cp ./enrollCaAdmin.sh $CA_CONTAINER_NAME:/tmp/enrollCaAdmin.sh
docker cp ./registerUser.sh $CA_CONTAINER_NAME:/tmp/registerUser.sh

docker exec $CA_CONTAINER_NAME sh -c "chown root:root /tmp/*.sh"
docker exec $CA_CONTAINER_NAME sh -c "chmod +x /tmp/*.sh"

# enroll ca admin
docker exec $CA_CONTAINER_NAME sh -c "/tmp/enrollCaAdmin.sh"

# register tls account for peer
docker exec $CA_CONTAINER_NAME sh -c "/tmp/registerUser.sh"

# copy admin's tls-ca-cert.pem to /tmp/
cp $HOST_VOLUME_CLIENT/$FABRIC_CA_ADMIN/msp/tlscacerts/tls-ca-cert.pem /tmp/

echo "Start done."
