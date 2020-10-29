#!/bin/bash

# second step, connect to tls ca server, get tls-msp data

. ./env.sh

# remove old files
docker exec $CONTAINER_NAME sh -c "cd /tmp && rm -f *"

# copy files to /tmp/
docker cp ../../shared/env.sh $CONTAINER_NAME:/tmp
docker cp ../../shared/tls-ca-cert.pem $CONTAINER_NAME:/tmp
docker cp ./enrolltls.sh $CONTAINER_NAME:/tmp/enrolltls.sh

docker exec $CONTAINER_NAME sh -c "chown root:root /tmp/*.sh"
docker exec $CONTAINER_NAME sh -c "chmod +x /tmp/*.sh"

docker exec $CONTAINER_NAME sh -c "/tmp/enrolltls.sh"
