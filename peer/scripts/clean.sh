#!/bin/bash

# import system wide env.sh

. ./env.sh

docker-compose -f dockers/ca.yaml down
docker-compose -f dockers/peer.yaml down

rm -rf ../volume/*
