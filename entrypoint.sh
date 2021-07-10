#!/bin/bash

# Fail on error
set -e
set -o pipefail

# shellcheck disable=SC1091
# Disable shellcheck warning on file import
# Import Bash logging helpers
source logging.sh

### App -----------------------------------------------------------------------------
get_disk_usage(){
  local path="${1:-"/"}"
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
    log_msg "Disk usage is lower than the warning threshold of ${warning_threshold}%" "INF"
  elif [[ "$disk_usage" -le 100 ]]; then
    log_msg "Disk usage is higher than the warning threshold of ${warning_threshold}%" "WRN"
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
