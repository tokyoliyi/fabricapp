#!/bin/bash

# import system wide env.sh

. ./env.sh

docker-compose -f ca.yaml down
docker-compose -f cli.yaml down
docker-compose -f orderer.yaml down

docker rm -f logspout

rm $CONFIGTX_FILE

rm -rf $HOST_VOLUME_SERVER
rm -rf $HOST_VOLUME_CLIENT
rm -rf $CLI_HOST_VOLUME/cli

