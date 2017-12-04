#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-a || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-c || true
}


@test "returns health check page if configured in env" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_hosts www.foo.com
  sleep 1
  run curl -s http://localhost:8180/health
  [ $(expr "$output" : ".*Everything seems to be 200 - OK.*") -ne 0 ]
}

@test "returns error if health not configured in env" {
  etcdctl set /kontena/haproxy/lb_no_health/services/service-a/virtual_hosts www.foo.com
  sleep 1
  run curl -s http://localhost:8181/health/
  [ $(expr "$output" : ".*503 — Service Unavailable.*") -ne 0 ]
}

@test "supports health check uri setting for balanced service" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /a/
  etcdctl set /kontena/haproxy/lb/services/service-a/health_check_uri /health
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  sleep 1
  run curl -k -s https://localhost:8443/a/
  [ "${lines[0]}" = "service-a" ]

  run config || grep httpchk
  assert_output_contains "option httpchk GET /health"

}
