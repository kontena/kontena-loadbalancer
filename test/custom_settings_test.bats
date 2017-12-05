#!/usr/bin/env bats

load "common"

@test "supports custom common settings via env" {

  run config
  assert_output_contains "option dontlognull"

}
