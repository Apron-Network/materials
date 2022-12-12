#!/bin/bash

set -x

if [[ ! -d alice ]] | [[ ! -d bob ]]; then
    echo "Put this script in parent directory of alice and bob, then retry."
    exit 1
fi

if [[ ! -f alice/docker-compose.yml ]] | [[ ! -f bob/docker-compose.yml ]]; then
    echo "Alice and bob directory should contain *docker-compose.yml* file."
    echo "Check document to get file content"
    exit 1
fi

docker network create --subnet=192.168.0.0/16 m1-testing

cd alice
docker-compose up -d
sleep 10
docker-compose logs apron-gateway-alice | grep 'Host ID:' | tail -1 | awk '{print "GATEWAY_BS_PEER_ID="$NF}' >../bob/env
cd ..

cd bob
docker-compose --env-file=env up -d
cd ..

cd alice
docker-compose logs -f
