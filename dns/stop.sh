#!/bin/bash

export VERSION=2.81
export NETWORK=dockerdnsmasq

docker-compose -f dockers/dnsmasq.yaml down
