#!/bin/bash

# import system wide env.sh

. ./env.sh

docker-compose -f ca.yaml down

sudo rm -rf ../volume/*