#!/bin/bash

# import system wide env.sh
. ../../shared/env.sh 
. ./env.sh

docker-compose -f ca.yaml down
