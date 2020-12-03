#!/bin/bash

export VERSION=2.81
export NETWORK=dockerdnsmasq

CONF=./dnsmasq.conf

if [ ! -f "$CONF" ]; then
    echo "No $CONF, please copy dnsmasq_example.conf to dnsmasq.conf and modify it"
    exit 1
fi

docker-compose -f dockers/dnsmasq.yaml up -d
