#!/bin/bash

error_msg(){
    local msg=$1
    echo -e "[ERROR] $msg"
    exit 1
}

should(){
    local expected=$1
    local test_name=$2
    local expr=$3
    echo "-------------------------------------------------------"
    echo "[LOG] $test_name - Should $expected"
    echo "[LOG] Executing: $expr"
    output_msg=$(trap '$expr' EXIT)
    eval "$expr" > /dev/null
    output_code=$?
    echo -e "[LOG] Output:\n\n$output_msg\n"

    if [[ $expected == "pass" && $output_code -eq 0 ]]; then
        echo "[LOG] Test passed as expected"
    elif [[ $expected == "fail" && $output_code -gt 1 ]]; then
        echo "[LOG] Test failed as expected"
    else
        error_msg "Test output is not expected, terminating"
    fi
}

# bargs_vars path - pass
should pass "Default Values" "bash ./entrypoint.sh"
should pass "Single Argument" "bash ./entrypoint.sh /"
should pass "Two Arguments" "bash ./entrypoint.sh / 80"
should pass "All Arguments" "bash ./entrypoint.sh / 75 92"
should pass "Empty Values" "bash entrypoint.sh "" "" """
export LOGGING_LEVEL=OFF
should pass "Logging level - OFF" "bash entrypoint.sh"
export LOGGING_LEVEL=DBG
should pass "Logging level - Debugging" "bash entrypoint.sh / 75 92"
export LOGGING_LEVEL=WRN
should pass "Logging level - Warning"   "bash entrypoint.sh / 75 92"
export LOGGING_LEVEL=WILLY
should fail "Logging level - Unknown"   "bash entrypoint.sh / 75 92"
