#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

@test 'assert_file_owner() <file>: supports GNU stat on macOS' {
  local OSTYPE=darwin
  local -r owner='fixture-owner'
  local -r file="${TEST_FIXTURE_ROOT}/dir/.gitignore"
  stat() {
    [[ "$1" == '-c' && "$2" == '%U' && "$3" == "$file" ]] || return 1
    printf 'fixture-owner\n'
  }
  run assert_file_owner "$owner" "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_file_owner() <file>: supports BSD stat on Linux' {
  local OSTYPE=linux-gnu
  local -r owner='fixture-owner'
  local -r file="${TEST_FIXTURE_ROOT}/dir/.gitignore"
  stat() {
    if [[ "$1" == '-c' && "$2" == '%U' && "$3" == "$file" ]]; then
      return 1
    fi
    [[ "$1" == '-f' && "$2" == '%Su' && "$3" == "$file" ]] || return 1
    printf 'fixture-owner\n'
  }
  run assert_file_owner "$owner" "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}
