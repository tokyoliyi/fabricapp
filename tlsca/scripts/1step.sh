#!/bin/bash

# start docker container for fabric ca server

# import system wide env.sh
./init.sh

. ./env.sh

# docker-compose -f ca.yaml up
docker-compose -f ca.yaml up -d
