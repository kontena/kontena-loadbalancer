#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
}


@test "redirects *.foo.com -> foo.com" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts *.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-b/custom_settings "
    acl wildcard hdr_reg(host) ^\w*\.foo.com\w*
    redirect code 301 location foo.com%[capture.req.uri] if wildcard
  "
  sleep 1
  run curl -sL -w "%{http_code}" -H "Host: www.foo.com" http://localhost:8180/ -o /dev/null
  [ "${lines[0]}" = "301" ]

  run curl -sL -w "%{http_code}" -H "Host: bar.foo.com" http://localhost:8180/ -o /dev/null
  [ "${lines[0]}" = "301" ]


  run curl -ksL -w "%{http_code}" -H "Host: www.foo.com" https://localhost:8443/ -o /dev/null
  [ "${lines[0]}" = "301" ]
  
  run curl -sL -w "%{http_code}" -H "Host: foo.bar.foo.com" http://localhost:8180/
  [ "${lines[0]}" = "service-b200" ]
}
