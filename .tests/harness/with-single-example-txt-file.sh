TESTS_HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TESTS_HARNESS_DIR/normalize.sh"
source "$TESTS_HARNESS_DIR/color-logging.sh"

readonly OWNER="pmalacho-mit"
readonly REPO="suede-scripts-test-harness"
readonly FIRST_COMMIT="98f6ba04cccd6d2f555bb5c5d11860d8b770b570"
readonly SECOND_COMMIT="86176653f3c0b9263e92e9d8edafafefe98d5c99"
readonly FILE="example.txt"
readonly FILE_CONTENTS_FIRST=""
readonly FILE_CONTENTS_SECOND="second commit"

readonly FIRST_COMMIT_GITREPO_CONTENT="
[subrepo]
  remote = https://github.com/pmalacho-mit/suede-scripts-test-harness.git
  branch = main
  commit = $FIRST_COMMIT
  parent = 
  method = merge
"

assert_dir_has_expected_contents_for_commit() {
  local dir="$1"
  local commit="$2"
  local expected_contents="$3"
  
  local file_path="${dir}/${FILE}"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "Expected file '$file_path' does not exist."
    return 1
  fi
  
  local actual_contents="$(strip_cr "$( <"$file_path" )")"
  
  if [[ "$actual_contents" == "$expected_contents" ]]; then
    log_pass "Directory '$dir' has expected contents for commit '$commit'."
    return 0
  else
    log_failure "Directory '$dir' does not have expected contents for commit '$commit'."
    log_info "Expected contents: $expected_contents"
    log_info "Actual contents: $actual_contents"
    return 1
  fi
}