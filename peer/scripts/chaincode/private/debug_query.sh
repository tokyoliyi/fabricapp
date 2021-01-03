#!/bin/bash

. ./chaincode.env

. ./last.env

peer chaincode query -C ${APP_CHANNEL_NAME} -n ${CC_NAME} -c '{"Args":["GetAllAssets"]}'
