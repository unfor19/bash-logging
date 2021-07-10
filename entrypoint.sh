#!/bin/bash

# Fail on error
set -e
set -o pipefail


### Logging Helpers -----------------------------------------------------------------
## Enumerated log levels
declare -A _LOGGING_LEVELS=([DBG]=0 [INF]=1 [WRN]=2 [OFF]=3)
_LOGGING_LEVEL="${LOGGING_LEVEL:-"INF"}"


# Functions
err_msg(){
  local msg="$1"
  local exit_code="${2:-"1"}"
  echo -e "[ERR] $(date +%s) $(date) :: [EXIT_CODE=$exit_code] $msg"
  exit "$exit_code"
}


is_array_contains(){
    declare -a array=("$1")
    local string="$2"
    if [[ " ${array[*]} " =~ " $string " ]]; then
        echo "true"
    fi

    echo "false"
}


log_msg(){
  local msg="$1"
  local level="$2"

  # Validate logging levels
  if [[ "$(is_array_contains "${!_LOGGING_LEVELS[*]}" "$level")" = "false" ]]; then
    err_msg "The argument \"${level}\" does not exist in ${!_LOGGING_LEVELS[*]}" "2"
  fi

  if [[ "$(is_array_contains "${!_LOGGING_LEVELS[*]}" "$_LOGGING_LEVEL")" = "false" ]]; then
    err_msg "The variable LOGGING_LEVEL \"${_LOGGING_LEVEL}\" does not exist in ${!_LOGGING_LEVELS[*]}" "3"
  fi

  # Check whether to print log msg or not
  if [[ ${_LOGGING_LEVELS[$level]} -ge ${_LOGGING_LEVELS[$_LOGGING_LEVEL]} ]]; then
    echo -e "[${level}] $(date +%s) $(date) :: $msg"
  fi
}


### App -----------------------------------------------------------------------------
get_disk_usage(){
    local path="$1"
    local usage_msg=""
    local percentage_msg=""
    local percentage=""
    usage_msg="$(df -h "$path")"
    percentage_msg="$(echo "$usage_msg" | tail -1 | tr -s "[:space:]" | cut -d" " -f5)"
    percentage="${percentage_msg//%/}"
    echo "$percentage"
}


main(){
    local path="${1:-"/"}"
    local warning_threshold="${2:-"85"}"
    local disk_usage="${3:-""}"

    # Get disk usage
    log_msg "Getting disk usage ..." "INF"
    if [[ -z "$disk_usage" ]]; then
        disk_usage="$(get_disk_usage "$path")"
    fi
    log_msg "Finished getting disk usage $disk_usage with the given path $path" "DBG"
    log_msg "Warning threshold is $warning_threshold" "DBG"
    log_msg "Disk usage for the path \"${path}\" is ${disk_usage}%" "INF"

    # Check warning threshold
    if [[ "$disk_usage" -le "$warning_threshold" ]]; then
        log_msg "Disk usage is lower than the warning threshold ${warning_threshold}%" "INF"
    elif [[ "$disk_usage" -le 100 ]]; then
        log_msg "Disk usage is higher than the warning threshold ${warning_threshold}%" "WRN"
    else
        err_msg "Unknown this usage - ${disk_usage}" "4"
    fi

    log_msg "Successfully completed disk usage process" "DBG"

    # Tests
    _TEST_UNKNOWN_LEVEL="${TEST_UNKNOWN_LEVEL:-"false"}"
    if [[ "$_TEST_UNKNOWN_LEVEL" = "true" ]]; then
        log_msg "Missing level type" "WONKA"
    fi
}

# Initialize variables
_DISK_USAGE_PATH="${1:-"$DISK_USAGE_PATH"}"
_DISK_USAGE_PATH="${_DISK_USAGE_PATH:-"/"}"

_WARNING_THRESHOLD="${2:-"$WARNING_THRESHOLD"}"
_WARNING_THRESHOLD="${_WARNING_THRESHOLD:-"85"}"

_MOCKED_DISK_USAGE="${3:-"$MOCKED_DISK_USAGE"}"
_MOCKED_DISK_USAGE="${_MOCKED_DISK_USAGE:-""}"
### ---------------------------------------------------------------------------------


### Run Main ------------------------------------------------------------------------
main "$_DISK_USAGE_PATH" "$_WARNING_THRESHOLD" "$_MOCKED_DISK_USAGE"
