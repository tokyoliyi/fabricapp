#!/bin/bash

# initial environment values
# merge ../../shared/global.env and ./local.env and user.env to env.sh
# userenv.sh is used by user who need to modify glolbal or local env values
# we ignore userenv.sh and env.sh in .gitignore

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

cp /tmp/env.sh ./env.sh

echo "init env done."
