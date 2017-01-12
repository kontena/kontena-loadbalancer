#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-a || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-c || true
}


@test "supports cookie stickyness" {
  etcdctl set /kontena/haproxy/lb/services/service-b/cookie ""
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  sleep 1
  run curl -c - -s -H "Host: www.foo.com" http://localhost:8180/

  [ "${lines[0]}" = "service-b# Netscape HTTP Cookie File" ]
  # cookie in format: www.foo.com FALSE / FALSE 0 KONTENA_SERVERID  server
  [ $(expr "${lines[3]}" : ".*KONTENA_SERVERID.*") -ne 0 ]
  [ $(expr "${lines[3]}" : ".*server.*") -ne 0 ]

}

@test "supports cookie stickyness with custom cookie config" {
  etcdctl set /kontena/haproxy/lb/services/service-b/cookie "cookie LB_COOKIE_TEST insert indirect nocache"
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  sleep 1
  run curl -c - -s -H "Host: www.foo.com" http://localhost:8180/
  [ "${lines[0]}" = "service-b# Netscape HTTP Cookie File" ]
  # cookie in format: www.foo.com FALSE / FALSE 0 KONTENA_SERVERID  server
  [ $(expr "${lines[3]}" : ".*LB_COOKIE_TEST.*") -ne 0 ]
  [ $(expr "${lines[3]}" : ".*server.*") -ne 0 ]

}

@test "supports cookie stickyness with custom cookie prefix" {
  etcdctl set /kontena/haproxy/lb/services/service-b/cookie "cookie JSESSIONID prefix nocache"
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server-1 service-b:9292
  sleep 1
  run curl -c - -s -H "Host: www.foo.com" http://localhost:8180/cookie
  [ "${lines[0]}" = "service-b" ]
  # cookie in format: www.foo.com FALSE / FALSE 0 KONTENA_SERVERID  server
  [ $(expr "${lines[4]}" : ".*JSESSIONID.*") -ne 0 ]
  [ $(expr "${lines[4]}" : ".*server-1~12345.*") -ne 0 ]

}
