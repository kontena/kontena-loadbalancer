#!/usr/bin/env bats

load "common"

@test "ciphers are set" {
  run sslscan localhost:8443
  assert_output_contains "ECDHE-RSA-AES128-GCM-SHA256" 1
  assert_output_contains "ECDHE-ECDSA-AES128-GCM-SHA256" 0
}
