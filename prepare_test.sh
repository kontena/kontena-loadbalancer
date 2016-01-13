#!/bin/bash

docker-compose -f docker-compose.test.yml stop
docker-compose -f docker-compose.test.yml rm -f
docker-compose -f docker-compose.test.yml up -d etcd
sleep 3
docker-compose -f docker-compose.test.yml build
docker-compose -f docker-compose.test.yml up -d
