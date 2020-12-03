#!/bin/bash

# import system wide env.sh
./init.sh

. ./env.sh

# start ca docker
docker-compose -f ca.yaml up -d
echo "Fabric CA Server started..."
echo "sleep 3s"
sleep 3
sudo chown -R ${USER}:${GROUP} $HOST_VOLUME_BASE

# enroll ca admin
./enrollCaAdmin.sh

# register tls account for peer
./registerUser.sh

sudo chown -R ${USER}:${GROUP} $HOST_VOLUME_BASE

# copy admin's tls-ca-cert.pem to /tmp/
cp $HOST_VOLUME_CLIENT/ca/admin/msp/tlscacerts/tls-ca-cert.pem /tmp/

echo "Start done."
