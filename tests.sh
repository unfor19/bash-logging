#!/bin/bash

error_msg(){
    local msg="$1"
    echo -e "[ERROR] $msg"
    exit 1
}


divider_msg(){
    echo "-------------------------------------------------------"
}


should(){
    local expected=$1
    local test_name=$2
    local expr=$3
    divider_msg
    echo "[LOG] $test_name - Should $expected"
    echo "[LOG] Executing: $expr"
    output_msg=$(trap '$expr' EXIT)
    eval "$expr" > /dev/null
    output_code=$?
    echo -e "[LOG] Output:\n\n$output_msg\n"

    _TESTS_TOTAL="$((_TESTS_TOTAL+1))"

    if [[ $expected == "pass" && $output_code -eq 0 ]]; then
        _TESTS_PASSED="$((_TESTS_PASSED+1))"
        echo "[LOG] Test passed as expected"
    elif [[ $expected == "fail" && $output_code -gt 1 ]]; then
        echo "[LOG] Test failed as expected"
    else
        _TESTS_FAILED="$((_TESTS_FAILED+1))"    
        echo -e "[ERROR] Test output is not expected\n${output_msg}"
    fi
}

_TESTS_TOTAL="0"
_TESTS_PASSED="0"
_TESTS_FAILED="0"

should pass "Default Values"                 "bash ./entrypoint.sh"
should pass "Single Argument"                "bash ./entrypoint.sh /"
should pass "Two Arguments"                  "bash ./entrypoint.sh / 80"
should pass "All Arguments"                  "bash ./entrypoint.sh / 75 92"
should pass "Empty Values"                   "bash entrypoint.sh "" "" """
export LOGGING_LEVEL=OFF
should pass "Logging level - OFF"            "bash entrypoint.sh"
export LOGGING_LEVEL=DBG
should pass "Logging level - Debugging"      "bash entrypoint.sh / 75 92"
export LOGGING_LEVEL=WRN
should pass "Logging level - Warning"        "bash entrypoint.sh / 75 92"
export LOGGING_LEVEL=WILLY
should fail "Logging level - Unknown"        "bash entrypoint.sh / 75 92"
unset LOGGING_LEVEL
export TEST_UNKNOWN_LEVEL=true
should fail "Unknown inline logging level"   "bash entrypoint.sh / 75 92"
divider_msg
echo -e "[SUMMARY] Total: ${_TESTS_PASSED}, Passed: ${_TESTS_PASSED}, Failed: ${_TESTS_FAILED}"