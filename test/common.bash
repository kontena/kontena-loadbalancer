#!/bin/bash

etcdctl() {
	docker run --rm --net=host --entrypoint=/usr/bin/etcdctl lbtesthelper "$@" 
}
curl() {
	docker run --rm --net=host --entrypoint=/usr/bin/curl lbtesthelper "$@"
}
