#!/bin/bash

# second step, connect to tls ca server, get tls-msp data

. ./env.sh

# remove old files
# docker exec $CA_CONTAINER_NAME sh -c "cd /tmp && rm -f *"

# copy files to /tmp/
docker cp ../../shared/env.sh $CA_CONTAINER_NAME:/tmp/globalenv.sh
docker cp ./env.sh $CA_CONTAINER_NAME:/tmp/localenv.sh
docker cp ../../shared/tls-ca-cert.pem $CA_CONTAINER_NAME:/tmp
docker cp ./adminenrollandregister.sh $CA_CONTAINER_NAME:/tmp/adminenrollandregister.sh

docker exec $CA_CONTAINER_NAME sh -c "chown root:root /tmp/*.sh"
docker exec $CA_CONTAINER_NAME sh -c "chmod +x /tmp/*.sh"

docker exec $CA_CONTAINER_NAME sh -c "/tmp/adminenrollandregister.sh"
