#!/bin/bash

etcdctl() {
	docker run --rm --net=host --entrypoint=/usr/bin/etcdctl kontena/etcd:2.2.1 "$@" &> /dev/null
}
curl() {
	docker run --rm --net=host --entrypoint=/usr/bin/curl tutum/curl:latest "$@"
}
