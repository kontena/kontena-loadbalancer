#!/usr/bin/env bats

load "common"

@test "does not configure haproxy to load certs when not configured with SSL_CERTS" {
  run docker exec kontenaloadbalancer_lb_no_health_1 cat /etc/haproxy/haproxy.cfg
  assert_output_contains "bind *:443 ssl crt /etc/haproxy/certs/" 0
}
