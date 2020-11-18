#!/bin/bash

export EXPLORER_VERSION=1.1.3
export HOST_ETC_HOSTS=/etc/hosts

docker-compose -f explorer.yaml down -v
