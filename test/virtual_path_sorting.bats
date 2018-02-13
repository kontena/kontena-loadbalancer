#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services || true
}

@test "routes overlapping virtual_paths correctly" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_path /test/foo
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_path /test/
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1

  run curl -s http://localhost:8180/path
  [ "${lines[0]}" = "service-a" ]
  run curl -s http://localhost:8180/test/foo
  [ "${lines[0]}" = "service-b" ]
  run curl -s http://localhost:8180/test/path
  [ "${lines[0]}" = "service-c" ]
}
