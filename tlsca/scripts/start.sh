#!/bin/bash

# import system wide env.sh
. ../../shared/env.sh 

export CONTAINER_NAME=tlsca
export CSR_CN=tlsca.fabric.test
export CSR_HOSTS=tlsca.fabric.test,0.0.0.0

# default start on foreground
if [ -z $1 ]; then
    docker-compose -f ca.yaml up
else
    docker-compose -f ca.yaml up -d
fi

./2step.sh
