#!/bin/bash

export EXPLORER_VERSION=1.1.3
export HOST_ETC_HOSTS=/etc/hosts
export TIMEZONE=Asia/Shanghai

docker-compose -f explorer.yaml down -v
