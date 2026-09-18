#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
  touch ${TEST_FIXTURE_ROOT}/dir/permission
  chmod 777 ${TEST_FIXTURE_ROOT}/dir/permission
}
teardown () {
  rm -f ${TEST_FIXTURE_ROOT}/dir/permission
}

# Correctness
@test 'assert_file_permission() <file>: returns 0 if <file> file has 777' {
  local -r permission="777"
  local -r file="${TEST_FIXTURE_ROOT}/dir/permission"
  run assert_file_permission "$permission" "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_file_permission() <file>: supports GNU stat on macOS' {
  local OSTYPE=darwin
  local -r permission="777"
  local -r file="${TEST_FIXTURE_ROOT}/dir/permission"
  stat() {
    [[ "$1" == '-c' && "$2" == '%a' && "$3" == "$file" ]] || return 1
    printf '777\n'
  }
  run assert_file_permission "$permission" "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_file_permission() <file>: supports BSD stat on Linux' {
  local OSTYPE=linux-gnu
  local -r permission="777"
  local -r file="${TEST_FIXTURE_ROOT}/dir/permission"
  stat() {
    if [[ "$1" == '-c' && "$2" == '%a' && "$3" == "$file" ]]; then
      return 1
    fi
    [[ "$1" == '-f' && "$2" == '%A' && "$3" == "$file" ]] || return 1
    printf '777\n'
  }
  run assert_file_permission "$permission" "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_file_permission() <file>: returns 1 and displays path if <file> file does not have permissions 777' {
  local -r permission="644"
  local -r file="${TEST_FIXTURE_ROOT}/dir/permission"
  run assert_file_permission "$permission" "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file does not have permissions 644 --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

# Transforming path
@test 'assert_file_permission() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  local -r permission="644"
  local -r file="${TEST_FIXTURE_ROOT}/dir/permission"
  run assert_file_permission "$permission" "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file does not have permissions 644 --' ]
  [ "${lines[1]}" == "path : ../dir/permission" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_file_permission() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%dir/permission'
  local -r BATSLIB_FILE_PATH_ADD='..'
  local -r permission="644"
  local -r file="${TEST_FIXTURE_ROOT}/dir/permission"
  run assert_file_permission "$permission" "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file does not have permissions 644 --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/.." ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_file_permission() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir/permission'
  local -r BATSLIB_FILE_PATH_ADD='..'
  local -r permission="644"
  local -r file="${TEST_FIXTURE_ROOT}/dir/permission"
  run assert_file_permission "$permission" "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file does not have permissions 644 --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/.." ]
  [ "${lines[2]}" == '--' ]
}
