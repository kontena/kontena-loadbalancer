#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-a || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-c || true
}


@test "supports virtual_path" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /a/
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  sleep 1
  run curl -s http://localhost:8180/a/
  [ "${lines[0]}" = "service-a" ]
  run curl -s http://localhost:8180/a/virtual_path
  [ "${lines[0]}" = "service-a" ]
  [ "${lines[1]}" = "/virtual_path" ]
}

@test "supports virtual_path + keep_virtual_path" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /virtual_path
  etcdctl set /kontena/haproxy/lb/services/service-a/keep_virtual_path "true"
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_path /b/
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  sleep 1
  run curl -s http://localhost:8180/virtual_path
  [ "${lines[0]}" = "service-a" ]
  [ "${lines[1]}" = "/virtual_path" ]
  run curl -s http://localhost:8180/b/virtual_path
  [ "${lines[0]}" = "service-b" ]
  [ "${lines[1]}" = "/virtual_path" ]
}

@test "supports multiple virtual_paths" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path "/a/,/b/"
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  sleep 1
  run curl -s http://localhost:8180/a/
  [ "${lines[0]}" = "service-a" ]
  run curl -s http://localhost:8180/b/
  [ "${lines[0]}" = "service-a" ]
  run curl -s http://localhost:8180/a/virtual_path
  [ "${lines[0]}" = "service-a" ]
  [ "${lines[1]}" = "/virtual_path" ]
  run curl -s http://localhost:8180/b/virtual_path
  [ "${lines[0]}" = "service-a" ]
  [ "${lines[1]}" = "/virtual_path" ]
}
