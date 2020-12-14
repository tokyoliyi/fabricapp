#!/bin/bash

# import system wide env.sh

. ./env.sh

docker-compose -f dockers/ca.yaml down
docker-compose -f dockers/peer.yaml down

docker-compose -f dockers/ca.yaml up -d
docker-compose -f dockers/peer.yaml up -d
