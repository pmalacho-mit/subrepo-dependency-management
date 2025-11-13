#!/usr/bin/env bash
#
# Test suite for degit.sh utility
# This script tests various scenarios including success cases,
# error handling, and edge cases.
#

set -euo pipefail

SCRIPTS_UTILS_TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HARNESS_DIR="$(cd "$SCRIPTS_UTILS_TESTS_DIR/../../../.tests/harness" && pwd)"

readonly EXTERNAL_SCRIPT_DEGIT="https://raw.githubusercontent.com/pmalacho-mit/suede/refs/heads/main/scripts/utils/degit.sh"
readonly LOCAL_SCRIPT_DEGIT="$SCRIPTS_UTILS_TESTS_DIR/../degit.sh"


source "$TEST_HARNESS_DIR/mock-curl.sh"
source "$TEST_HARNESS_DIR/color-logging.sh"
source "$TEST_HARNESS_DIR/with-single-example-txt-file.sh"

TEST_DIR=""

setup_test_env() {
  TEST_DIR="$(mktemp -d)"
  log_info "Created test directory: $TEST_DIR"
  
  mock_curl_url "$EXTERNAL_SCRIPT_DEGIT" "$LOCAL_SCRIPT_DEGIT"
  enable_url_mocking
  log_success "Test environment set up"
}

cleanup_test_env() {
  if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
    log_info "Cleaned up test directory"
  fi
  disable_url_mocking
}

basic_first_commit_test() {
  local destination="${TEST_DIR}/first-basic"
  mkdir -p "$destination"
  bash <(curl -fsSL $EXTERNAL_SCRIPT_DEGIT) --repo "${OWNER}/${REPO}" --commit "${FIRST_COMMIT}" --directory "$destination"
  assert_dir_has_expected_contents_for_commit "$destination" "$FIRST_COMMIT" "$FILE_CONTENTS_FIRST"
}

basic_second_commit_test() {
  local destination="${TEST_DIR}/second-basic"
  mkdir -p "$destination"
  bash <(curl -fsSL $EXTERNAL_SCRIPT_DEGIT) --repo "${OWNER}/${REPO}" --commit "${SECOND_COMMIT}" --directory "$destination"
  assert_dir_has_expected_contents_for_commit "$destination" "$SECOND_COMMIT" "$FILE_CONTENTS_SECOND"
}

force_test() {
  local destination="${TEST_DIR}/attempt-force"
  mkdir -p "$destination"
  touch "${destination}/extra-file.txt"
  
  $(bash <(curl -fsSL $EXTERNAL_SCRIPT_DEGIT) --repo "${OWNER}/${REPO}" --commit "${SECOND_COMMIT}" --directory "$destination") || {
    log_pass "Degit correctly failed when attempting to write to non-empty directory."
  }

  rm -f "${destination}/extra-file.txt"

  bash <(curl -fsSL $EXTERNAL_SCRIPT_DEGIT) --repo "${OWNER}/${REPO}" --commit "${SECOND_COMMIT}" --directory "$destination"
   
  assert_dir_has_expected_contents_for_commit "$destination" "$SECOND_COMMIT" "$FILE_CONTENTS_SECOND"
}

main() {
  trap cleanup_test_env EXIT
  setup_test_env
  basic_first_commit_test
  basic_second_commit_test
  force_test
  exit $?
}

main "$@"

