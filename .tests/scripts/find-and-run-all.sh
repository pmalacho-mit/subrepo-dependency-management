#!/bin/bash

# Script to find and run test files in .tests directories
# Usage:
#   ./find-and-run.sh --all              # Run all test files
#   ./find-and-run.sh test1 test2 ...    # Run specific test files by name

set -e

TESTS_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$TESTS_SCRIPTS_DIR/../.."

source "$TESTS_SCRIPTS_DIR/../harness/color-logging.sh"

find_test_files() {
    find "$ROOT_DIR" -type f -path "*/.tests/*.sh" | \
    awk -F'/' '{
        # Check if .tests is the second-to-last directory component
        for(i=1; i<=NF; i++) {
            if($i == ".tests" && i == NF-1) {
                print $0
                break
            }
        }
    }'
}

execute_test() {
    local test_file="$1"
    local test_name
    test_name=$(basename "$test_file")
    
    log_info "Executing test: $test_name"
    
    if [[ ! -x "$test_file" ]]; then
        chmod +x "$test_file"
    fi
    
    if bash "$test_file"; then
        log_success "✓ $test_name passed"
        return 0
    else
        log_failure "✗ $test_name failed"
        return 1
    fi
}

# Main script logic
main() {
    local exit_code=0
    local failed_tests=()
    local passed_tests=()
    
    while IFS= read -r test_file; do
        if execute_test "$test_file"; then
            passed_tests+=("$test_file")
        else
            failed_tests+=("$test_file")
            exit_code=1
        fi
        echo ""
    done < <(find_test_files)
    
    # Print summary
    local total_tests=$((${#passed_tests[@]} + ${#failed_tests[@]}))
    
    printf "\n"
    printf "═══════════════════════════════════════════════════════════════\n"
    printf "                        TEST SUMMARY\n"
    printf "═══════════════════════════════════════════════════════════════\n"
    printf "  Total:  %d\n" "$total_tests"
    printf "  ${GREEN}Passed: %d${NO_COLOR}\n" "${#passed_tests[@]}"
    printf "  ${RED}Failed: %d${NO_COLOR}\n" "${#failed_tests[@]}"
    printf "═══════════════════════════════════════════════════════════════\n"
    
    if [[ ${#failed_tests[@]} -gt 0 ]]; then
        printf "\n${RED}Failed tests:${NO_COLOR}\n"
        for test in "${failed_tests[@]}"; do
            printf "  ${RED}✗${NO_COLOR} %s\n" "$(basename "$test")"
        done
        printf "\n"
    else
        printf "\n${GREEN}All tests passed! ✓${NO_COLOR}\n\n"
    fi
    
    exit $exit_code
}

main
