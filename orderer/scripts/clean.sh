#!/bin/bash

# import system wide env.sh

. ./env.sh

docker-compose -f dockers/ca.yaml down
docker-compose -f dockers/orderer.yaml down

rm -rf $HOST_VOLUME_SERVER
rm -rf $HOST_VOLUME_CLIENT
