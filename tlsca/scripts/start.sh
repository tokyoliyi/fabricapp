#!/bin/bash

# import system wide env.sh
./init.sh

. ./env.sh

# start ca docker
./1step.sh

echo "sleep 3s"
sleep 3

# enroll admin and
# register user identity
./2step.sh

# copy admin's tls-ca-cert.pem to /tmp/
cp ../volume/client/admin/msp/tlscacerts/tls-ca-cert.pem /tmp/

echo "Start done."
