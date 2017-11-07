#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services || true
}

@test "if no upstreams, service frontend retained in config" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292

  sleep 1
  run curl -sL -w "%{http_code}" -H "Host: www.foo.com" http://localhost:8180/ -o /dev/null
  [ "${lines[0]}" = "503" ]

  run config
  assert_output_contains "use_backend service-b" 1
}
