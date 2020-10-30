#!/bin/bash

# second step, enroll admin and register use

# remove old files
docker exec $CA_CONTAINER_NAME sh -c "cd /tmp && rm -f *.sh"

docker cp ./env.sh $CA_CONTAINER_NAME:/tmp
docker cp ./enrollAdmin.sh $CA_CONTAINER_NAME:/tmp/enrollAdmin.sh
docker cp ./registerUser.sh $CA_CONTAINER_NAME:/tmp/registerUser.sh

docker exec $CA_CONTAINER_NAME sh -c "chown root:root /tmp/*.sh"
docker exec $CA_CONTAINER_NAME sh -c "chmod +x /tmp/*.sh"


docker exec $CA_CONTAINER_NAME sh -c "/tmp/enrollAdmin.sh"
docker exec $CA_CONTAINER_NAME sh -c "/tmp/registerUser.sh"
