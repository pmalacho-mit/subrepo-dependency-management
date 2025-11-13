set -euo pipefail

SCRIPTS_TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HARNESS_DIR="$(cd "$SCRIPTS_UTILS_TESTS_DIR/../../../.tests/harness" && pwd)"

readonly EXTERNAL_SCRIPT_EXTRACT="https://raw.githubusercontent.com/pmalacho-mit/suede/refs/heads/main/scripts/extract-subrepo-config.sh"
readonly LOCAL_SCRIPT_EXTRACT="$SCRIPTS_TESTS_DIR/../extract-subrepo-config.sh"

readonly EXTERNAL_SCRIPT_DEGIT="https://raw.githubusercontent.com/pmalacho-mit/suede/refs/heads/main/scripts/utils/degit.sh"
readonly LOCAL_SCRIPT_DEGIT="$SCRIPTS_TESTS_DIR/utils/../degit.sh"

source "$TEST_HARNESS_DIR/mock-curl.sh"
source "$TEST_HARNESS_DIR/color-logging.sh"
source "$TEST_HARNESS_DIR/with-single-example-txt-file.sh"

TEST_DIR=""

setup_test_env() {
  TEST_DIR="$(mktemp -d)"
  log_info "Created test directory: $TEST_DIR"

  mock_curl_url "$EXTERNAL_SCRIPT_EXTRACT" "$LOCAL_SCRIPT_EXTRACT"
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

main() {
  trap cleanup_test_env EXIT
  setup_test_env

  exit $?
}

main "$@"
