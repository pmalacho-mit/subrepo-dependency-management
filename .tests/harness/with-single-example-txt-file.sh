TESTS_HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TESTS_HARNESS_DIR/normalize.sh"
source "$TESTS_HARNESS_DIR/color-logging.sh"

readonly OWNER="pmalacho-mit"
readonly REPO="suede-scripts-test-harness"
readonly FILE="example.txt"

declare -a COMMITS=(
  "98f6ba04cccd6d2f555bb5c5d11860d8b770b570"
  "86176653f3c0b9263e92e9d8edafafefe98d5c99"
)

declare -a FILE_CONTENTS=(
  ""
  "second commit"
)

declare -a GITREPO_CONTENT=(
  "; DO NOT EDIT (unless you know what you are doing)
;

[subrepo]
  remote = https://github.com/${OWNER}/${REPO}.git
  branch = with-single-example-txt-file
  commit = ${COMMITS[0]}
  parent = 
  method = merge"
  "; DO NOT EDIT (unless you know what you are doing)
;[subrepo]
  remote = https://github.com/${OWNER}/${REPO}.git
  branch = with-single-example-txt-file
  commit = ${COMMITS[1]}
  parent = ${COMMITS[0]}
  method = merge"
)

assert_dir_has_expected_contents_for_commit() {
  local dir="$1"
  local index="$2"
  
  local commit="${COMMITS[$index]}"
  local expected_contents="${FILE_CONTENTS[$index]}"
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

assert_file_has_expected_gitrepo_contents_for_commit() {
  local file_path="$1"
  local index="$2"
  
  local commit="${COMMITS[$index]}"
  local expected_contents="${GITREPO_CONTENT[$index]}"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "Expected .gitrepo file '$file_path' does not exist."
    return 1
  fi
  
  local actual_contents="$(strip_cr "$( <"$file_path" )")"
  
  if [[ "$actual_contents" == "$expected_contents" ]]; then
    log_pass ".gitrepo file '$file_path' has expected contents for commit '$commit'."
    return 0
  else
    log_failure ".gitrepo file '$file_path' does not have expected contents for commit '$commit'."
    log_info "Expected contents: $expected_contents"
    log_info "Actual contents: $actual_contents"
    return 1
  fi
}