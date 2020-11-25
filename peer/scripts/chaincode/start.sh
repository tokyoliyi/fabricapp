#!/bin/bash

. ../env.sh

# check chaincode folder exist
CC_SRC_FOLDER=$CHAINCODE_HOST_PATH/$CC_NAME
if [ ! -d "$CC_SRC_FOLDER" ]; then
    echo "No $CC_SRC_FOLDER"
    exit 1
fi

# we use cli container to do rest work

docker cp ../env.sh $CLI_CONTAINER_NAME:/tmp/envcc.sh

docker cp ./deploy.sh $CLI_CONTAINER_NAME:/tmp/deploycc.sh
docker cp ./commit.sh $CLI_CONTAINER_NAME:/tmp/commitcc.sh

docker exec $CLI_CONTAINER_NAME sh -c "chown root:root /tmp/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "chmod +x  /tmp/*.sh"
docker exec $CLI_CONTAINER_NAME sh -c "/tmp/deploycc.sh"
