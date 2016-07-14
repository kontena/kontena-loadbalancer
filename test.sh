#!/usr/bin/env bats

load "test/common"


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

@test "supports virtual_hosts" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com,api.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  sleep 1
  run curl -s -H "Host: www.foo.com" http://localhost:8180/
  [ "${lines[0]}" = "service-b" ]
  run curl -s -H "Host: api.foo.com" http://localhost:8180/
  [ "${lines[0]}" = "service-b" ]
}

@test "supports wildcard virtual_hosts" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts *.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292
  sleep 1
  run curl -s -H "Host: www.foo.com" http://localhost:8180/
  [ "${lines[0]}" = "service-b" ]
  run curl -s -H "Host: api.foo.com" http://localhost:8180/
  [ "${lines[0]}" = "service-b" ]
  run curl -s -H "Host: www.bar.com" http://localhost:8180/
  [ "${lines[0]}" = "service-c" ]
}

@test "supports virtual_hosts + virtual_path" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_path /b
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.bar.com,api.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_path /c
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s http://localhost:8180
  [ "$status" -eq 0 ]
  [ $(expr "$output" : ".*Service Unavailable.*") -ne 0 ]

  run curl -s http://localhost:8180/b
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]

  run curl -s -H "Host: www.bar.com" http://localhost:8180/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]

  run curl -s -H "Host: api.bar.com" http://localhost:8180/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]
}

@test "supports virtual_hosts + virtual_path + keep_virtual_path" {
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /virtual_path
  etcdctl set /kontena/haproxy/lb/services/service-a/keep_virtual_path "true"
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292

  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_path /b
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.bar.com,api.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_path /c
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s http://localhost:8180
  [ "$status" -eq 0 ]
  [ $(expr "$output" : ".*Service Unavailable.*") -ne 0 ]

  run curl -s -H "Host: www.foo.com" http://localhost:8180/virtual_path
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-a" ]
  [ "${lines[1]}" = "/virtual_path" ]

  run curl -s http://localhost:8180/b
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]
  [ "${lines[1]}" = "" ]

  run curl -s -H "Host: www.bar.com" http://localhost:8180/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]

  run curl -s -H "Host: api.bar.com" http://localhost:8180/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]
}

@test "handles empty upstreams" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.bar.com

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts api.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s -H "Host: www.bar.com" http://localhost:8180
  [ "$status" -eq 0 ]
  [ $(expr "$output" : ".*Service Unavailable.*") -ne 0 ]

  run curl -s -H "Host: api.bar.com" http://localhost:8180/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]
}

@test "on duplicate virtual_hosts first one in alphabets wins" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s http://localhost:8180
  [ "$status" -eq 0 ]
  [ $(expr "$output" : ".*Service Unavailable.*") -ne 0 ]

  run curl -s -H "Host: www.bar.com" http://localhost:8180/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]
}

@test "prioritizes first vhost+vpath, then vhost and finally vpath" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292

  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts api.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_path /c
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s http://localhost:8180
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-a" ]

  run curl -s -H "Host: www.bar.com" http://localhost:8180/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]

  run curl -s -H "Host: api.bar.com" http://localhost:8180/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]
}

@test "works with domain:port host header" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  sleep 1

  run curl -s -H "Host: www.bar.com" http://localhost:8180/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]

  run curl -s -H "Host: www.bar.com:80" http://localhost:8180/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]
}

@test "returns custom error page" {
  sleep 1
  run curl -s http://localhost:8180/invalid/
  [ $(expr "$output" : ".*Kontena Load Balancer.*") -ne 0 ]
}

@test "returns health check page if configured in env" {
  sleep 1
  run curl -s http://localhost:8180/health
  [ $(expr "$output" : ".*Everything seems to be 200 - OK.*") -ne 0 ]
}

@test "returns error if health not configured in env" {
  sleep 1
  run curl -s http://localhost:8181/health/
  [ $(expr "$output" : ".*503 — Service Unavailable.*") -ne 0 ]
}

@test "supports ssl with invalid cert ignored" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /a/
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  sleep 1
  run curl -k -s https://localhost:8443/a/
  [ "${lines[0]}" = "service-a" ]
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
