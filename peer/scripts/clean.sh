#!/bin/bash

# import system wide env.sh

. ./env.sh

docker-compose -f ca.yaml down
docker-compose -f peer.yaml down

docker rm -f logspout

rm -rf ../volume/*
