#!/usr/bin/env bats

load "common"

@test "configures haproxy to load certs when configured with SSL_CERTS" {
  run config
  assert_output_contains "bind *:443 ssl crt /etc/haproxy/certs/" 1
}

@test "loads certs from both SSL_CERTS" {
  run docker exec kontenaloadbalancer_lb_1 ls /etc/haproxy/certs
  assert_output_contains "cert1_gen.pem" 1
  assert_output_contains "SSL_CERT_test1.pem" 1
}
