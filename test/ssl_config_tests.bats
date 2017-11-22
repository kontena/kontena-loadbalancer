#!/usr/bin/env bats

load "common"

@test "sets etcd certs/bundle to true when configured with SSL_CERTS" {
  run etcdctl get /kontena/haproxy/lb/certs/bundle

  [ "$status" -eq 0 ]
  [ "$output" = 'true' ]
}

@test "configures haproxy to load certs when configured with SSL_CERTS" {
  run config
  assert_output_contains "bind *:443 ssl crt /etc/haproxy/certs/" 1
}

@test "loads certs from both SSL_CERTS and SSL_CERT_*" {
  run docker exec kontenaloadbalancer_lb_1 ls /etc/haproxy/certs
  assert_output_contains "cert00_gen.pem" 1
  assert_output_contains "SSL_CERT_test1.pem" 1
}
