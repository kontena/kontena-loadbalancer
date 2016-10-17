#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
}


@test "basic auth gives 401 without user and password" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  etcdctl set /kontena/haproxy/lb/services/service-b/basic_auth_secrets "user admin insecure-password passwd"
  sleep 1
  run curl -sL -w "%{http_code}" -H "Host: www.foo.com" http://localhost:8180/ -o /dev/null
  [ "${lines[0]}" = "401" ]

}


@test "basic auth gives 200 with valid user and password" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  etcdctl set /kontena/haproxy/lb/services/service-b/basic_auth_secrets "user admin insecure-password passwd"
  sleep 1
  run curl -s -H "Host: www.foo.com" http://admin:passwd@localhost:8180/
  [ "${lines[0]}" = "service-b" ]

}

@test "basic auth gives 200 with valid user and password, password encrypted" {
  # generated with: docker run -ti --rm alpine mkpasswd -m sha-512 passwd
  PASSWD='$6$n6KqSRo5Y.ifWXS/$H0y19JyooSMPYVqSTd2AEmLNo0PZnxTp5dx4W31vsWICZ3FYU5jMScJ64K8HgLXgFVyFYVq0EQ7XqgT5hCbg/1'
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  etcdctl set /kontena/haproxy/lb/services/service-b/basic_auth_secrets "user admin password $PASSWD"
  sleep 1

  run curl -s -H "Host: www.foo.com" http://admin:passwd@localhost:8180/
  [ "${lines[0]}" = "service-b" ]

}
