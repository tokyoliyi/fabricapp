#!/bin/bash

export EXPLORER_VERSION=1.1.3
export HOST_ETC_HOSTS=/etc/hosts

# check if crypto exist

TLS_CA_FILE=./crypto/tls/tls-ca-cert.pem
ADMIN_PUBLIC_KEY=./crypto/users/admin/signcerts/cert.pem
ADMIN_PRIVATE_KEY=./crypto/users/admin/keystore/key.pem

if [ ! -f "$TLS_CA_FILE" ]; then
    echo "No $TLS_CA_FILE"
    exit 1
fi

if [ ! -f "$ADMIN_PUBLIC_KEY" ]; then
    echo "No $ADMIN_PUBLIC_KEY"
    exit 1
fi

if [ ! -f "$ADMIN_PRIVATE_KEY" ]; then
    echo "No $ADMIN_PRIVATE_KEY"
    exit 1
fi

# docker-compose -f explorer.yaml up
docker-compose -f explorer.yaml up -d
