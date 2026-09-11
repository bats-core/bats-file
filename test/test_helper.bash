# Set variables for easily accessing sub-directories of `./fixtures'.
#
# Globals:
#   BATS_TEST_DIRNAME
#   TEST_FIXTURE_ROOT
# Arguments:
#   $1 - name of sub-directory
# Returns:
#   none
fixtures() {
  # shellcheck disable=SC2034  # Used by test files that load this helper.
  TEST_FIXTURE_ROOT="${BATS_TEST_DIRNAME}/fixtures/$1"
}

bats_sudo() {
  local sudo_path
  sudo_path=$(command -v sudo 2>/dev/null)
  if [[ "$(whoami)" != 'root' ]] && [ -x "$sudo_path" ]; then
    "$sudo_path" "$@"
  else
    "$@"
  fi
}

skip_on_msys() {
  if [[ ${OSTYPE-} == cygwin || ${OSTYPE-} == msys ]]; then
    skip "$1"
  fi
}

export TEST_MAIN_DIR="${BATS_TEST_DIRNAME}/.."
export TEST_DEPS_DIR="${TEST_DEPS_DIR-${TEST_MAIN_DIR}/..}"

# validate that bats-file is safe to use under -u
set -u

# Load dependencies.
bats_load_library 'bats-support'
# Load library.
load '../load'
