#!/bin/bash

# first step is startup ca server

. ../../shared/env.sh
. ./env.sh

# default start on foreground
if [ -z $1 ]; then
    docker-compose -f ca.yaml up
else
    docker-compose -f ca.yaml up -d
fi
