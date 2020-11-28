#!/bin/bash

# initial environment values
# merge ../../shared/global.env and ./local.env and user.env to env.sh
# userenv.sh is used by user who need to modify glolbal or local env values
# we ignore userenv.sh and env.sh in .gitignore

# 1. merge env values
GLOBAL_ENV=../../shared/global.env
LOCAL_ENV=./local.env
USER_ENV=./user.env

cp $GLOBAL_ENV /tmp/global.env
cp $LOCAL_ENV /tmp/local.env

if [ -f "/tmp/user.env" ]; then
    rm /tmp/user.env
fi

if [ -f "$USER_ENV" ]; then
    cp $USER_ENV /tmp/user.env
fi

/usr/bin/env python mergeEnv.py

. /tmp/env.sh

# 2. prepare fabric binary files
# check os type and download fabric client binary if needed
if [ ! -d "$FABRIC_CLIENT_BIN_PATH" ]; then
    mkdir -p ${FABRIC_CLIENT_BIN_PATH}
fi

BIN_PATH=$FABRIC_CLIENT_BIN_PATH/bin
OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
echo $OS_ARCH
if [ $OS_ARCH = "darwin-amd64" ]; then
    export FABRIC_CLIENT_BIN_OSARCH=$FABRIC_CLIENT_BIN_ARCH_OSX
else
    export FABRIC_CLIENT_BIN_OSARCH=$FABRIC_CLIENT_BIN_ARCH_LINUX
fi


if [ ! -d "$BIN_PATH" ]; then
    echo "Donwload fabric binary files from github..."
    DLURL=$FABRIC_CLIENT_BIN_URL
    DSTFILE=/tmp/fabricBin.${FABRIC_CLIENT_BIN_VERSION}.tar.gz
    wget -c $DLURL -O $DSTFILE
    tar zxvf $DSTFILE -C $FABRIC_CLIENT_BIN_PATH
fi

# check if fabric-ca-client exist
if [ ! -f "$BIN_PATH/fabric-ca-client" ]; then
    echo "Download fabric-ca binary files from github..."
    DLURL=$FABRIC_CA_CLIENT_BIN_URL
    DSTFILE=/tmp/fabricCaBin.${FABRIC_CA_VERSION}.tar.gz
    wget -c $DLURL -O $DSTFILE
    TMP=/tmp/fcabinpath
    mkdir -p $TMP
    tar zxvf $DSTFILE -C $TMP
    cp $TMP/bin/fabric-ca-client $BIN_PATH
fi

echo "export PATH=${BIN_PATH}:\$PATH" >> /tmp/env.sh

cp /tmp/env.sh ./env.sh

echo "init env done."
