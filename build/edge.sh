#!/bin/bash

if [ ! -z "$DOCKER_USERNAME" ] && [ ! -z "$DOCKER_PASSWORD" ]; then
    docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
    docker build -t kontena/lb:edge .
    docker push kontena/lb:edge
fi