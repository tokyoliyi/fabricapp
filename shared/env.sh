#!/bin/bash

# shared enviroment values for all scripts

# docker network name
# when we use docker compose file version >= 3.5, we don't need network name prefix
# export COMPOSE_PROJECT_NAME=leyle
export DOCKER_NETWORK_NAME=fabricapp

# fabric docker image version
export FABRIC_TOOLS_VERSION=2.2.1
export FABRIC_PEER_VERSION=2.2.1
export FABRIC_ORDERER_VERSION=2.2.1
export FABRIC_CA_VERSION=1.4.9

# fabric ca
export FABRIC_CA_SERVER_HOME=/etc/fabricapp/server
export FABRIC_CA_CLIENT_HOME=/etc/fabricapp/client
export FABRIC_CA_ADMIN=caadmin
export FABRIC_CA_PASSWD=capasswd
export FABRIC_CA_PORT=7054
