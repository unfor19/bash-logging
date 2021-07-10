#!/bin/bash

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
  if [[ " ${array[*]} " =~ \ $string\ .* ]]; then
    echo "true"
  fi

  echo "false"
}


log_msg(){
  local msg="$1"
  local level="${2:-"INF"}"

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
