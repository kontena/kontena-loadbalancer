#!/bin/bash

if [ ! -z "$TRAVIS_TAG" ] && [ ! -z "$DOCKER_PASSWORD" ]; then
    docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
    TAG=${TRAVIS_TAG/v/}
    docker build -t kontena/lb:latest -t "kontena/lb:$TAG" .
    docker push "kontena/lb:$TAG"
    docker push kontena/lb:latest
fi