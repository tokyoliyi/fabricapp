#!/bin/bash

# import system wide env.sh

. ./env.sh

docker-compose -f ca.yaml down
docker-compose -f cli.yaml down
docker-compose -f orderer.yaml down

rm $CONFIGTX_FILE

sudo rm -rf $HOST_VOLUME_SERVER
sudo rm -rf $HOST_VOLUME_CLIENT
sudo rm -rf $CLI_HOST_VOLUME/cli

