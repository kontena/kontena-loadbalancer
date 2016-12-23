#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-a || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-c || true
}


@test "supports ssl with invalid cert ignored" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /a/
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  sleep 1
  run curl -k -s https://localhost:8443/a/
  [ "${lines[0]}" = "service-a" ]
}
