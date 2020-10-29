#!/bin/bash

# second step, enroll admin and register use
if [ -z $CONTAINER_NAME ]; then
    export CONTAINER_NAME=tlsca
fi

# remove old files
docker exec $CONTAINER_NAME sh -c "cd /tmp && rm *"
docker cp ../../shared/env.sh $CONTAINER_NAME:/tmp
docker cp ./enrollandregister.sh $CONTAINER_NAME:/tmp/run.sh
docker exec $CONTAINER_NAME sh -c "chown root:root /tmp/*.sh"
docker exec $CONTAINER_NAME sh -c "chmod +x /tmp/*.sh"


docker exec $CONTAINER_NAME sh -c "/tmp/run.sh"
