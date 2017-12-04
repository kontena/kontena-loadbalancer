#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-a || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-c || true
}

@test "returns custom error page" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com
  sleep 1
  run curl -s http://localhost:8180/invalid/
  [ $(expr "$output" : ".*Kontena Load Balancer.*") -ne 0 ]
}
