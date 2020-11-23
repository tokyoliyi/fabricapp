#!/bin/bash

# import system wide env.sh

. ./env.sh

docker-compose -f ca.yaml down
docker-compose -f peer.yaml down

rm -rf ../volume/*
