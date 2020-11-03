#!/bin/bash

./init.sh
. ./env.sh

docker-compose -f orderer.yaml up
