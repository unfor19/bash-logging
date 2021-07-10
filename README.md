# bash-logging

[![Publish Latest](https://github.com/unfor19/bash-logging/actions/workflows/publish-latest.yml/badge.svg)](https://github.com/unfor19/bash-logging/actions/workflows/publish-latest.yml)

## Usage

1. Download the [logging.sh](https://github.com/unfor19/bash-logging/blob/master/logging.sh) script
    ```bash
    TARGET_URL="https://raw.githubusercontent.com/unfor19/bash-logging/master/logging.sh" && \
    wget -O logging.sh "$TARGET_URL" && \
    chmod +x ./logging.sh
    ```
1. Import the [logging.sh](https://github.com/unfor19/bash-logging/blob/master/logging.sh) file in your script
   ```bash
   source logging.sh
   ```

1. Set the `_LOGGING_LEVELS` according to your needs, currently there are four (4) levels, see [logging.sh](https://github.com/unfor19/bash-logging/blob/master/logging.sh#L5)
   1. `DBG=0` - Logs verbose usage messages, useful for debugging the script
   2. `INF=1` - Logs application messages
   3. `WRN=2` - Logs warning messages
   4. `OFF=3` - No logs at all

1. Use the functions `log_msg` and `err_msg` in your code, the [logging.sh](https://github.com/unfor19/bash-logging/blob/master/logging.sh) file contains a full example of an application that logs the current disk usage.
   - `log_msg $MSG $LOGGING_LEVEL=INF`
   - `err_msg $MSG $EXIT_CODE=1`


## Examples

I've create a sample application that makes it easier to understand the logging mechanism.

1. Download the [entrypoint.sh](https://github.com/unfor19/bash-logging/blob/master/entrypoint.sh) script
    ```bash
    LOGGING_URL="https://raw.githubusercontent.com/unfor19/bash-logging/master/logging.sh" && \
    ENTRYPOINT_URL="https://raw.githubusercontent.com/unfor19/bash-logging/master/entrypoint.sh" && \
    wget "$LOGGING_URL" "$ENTRYPOINT_URL" && \
    chmod +x ./entrypoint.sh ./logging.sh
    ```
2. Provide arguments or variables
    ```bash
    ./entrypoint.sh "$DISK_USAGE_PATH" "$WARNING_THRESHOLD" "$MOCKED_DISK_USAGE"
    ```

3. Using default values `DISK_USAGE_PATH="/"`, `WARNING_THRESHOLD=85`, `MOCKED_DISK_USAGE=""`
   ```bash
   ./entrypoint.sh
   ```

   ```bash
   # Output
   [INF] 1625928547 Sat Jul 10 17:49:07 IDT 2021 :: Getting disk usage ...
   [INF] 1625928547 Sat Jul 10 17:49:07 IDT 2021 :: Disk usage for the path "/" is 6%
   [INF] 1625928547 Sat Jul 10 17:49:07 IDT 2021 :: Disk usage is lower than the warning threshold of 85%
   ```

4. Mocking disk size to check warning message
   ```bash
   ./entrypoint.sh / 75 92
   ```

   ```bash
   # Output
   [INF] 1625928557 Sat Jul 10 17:49:17 IDT 2021 :: Getting disk usage ...
   [INF] 1625928557 Sat Jul 10 17:49:17 IDT 2021 :: Disk usage for the path "/" is 92%
   [WRN] 1625928557 Sat Jul 10 17:49:17 IDT 2021 :: Disk usage is higher than the warning threshold of 75%
   ```
5. Debugging
   ```bash
   LOGGING_LEVEL="DBG" ./entrypoint.sh / 75 92
   ```

   ```bash
   # Output
   [INF] 1625928568 Sat Jul 10 17:49:28 IDT 2021 :: Getting disk usage ...
   [DBG] 1625928568 Sat Jul 10 17:49:28 IDT 2021 :: Finished getting disk usage 92 with the given path /
   [DBG] 1625928568 Sat Jul 10 17:49:28 IDT 2021 :: Warning threshold is 75
   [INF] 1625928568 Sat Jul 10 17:49:28 IDT 2021 :: Disk usage for the path "/" is 92%
   [WRN] 1625928568 Sat Jul 10 17:49:28 IDT 2021 :: Disk usage is higher than the warning threshold of 75%
   [DBG] 1625928568 Sat Jul 10 17:49:28 IDT 2021 :: Successfully completed disk usage process
   ```
6. Check what happens when providing an unknown logging level as an environment variable
   ```bash
   LOGGING_LEVEL="WILLY" ./entrypoint.sh / 75 92
   ```

   ```bash
   # Output
   [ERR] 1625928579 Sat Jul 10 17:49:39 IDT 2021 :: [EXIT_CODE=3] The variable LOGGING_LEVEL "WILLY" does not exist in INF OFF WRN DBG
   ```
7. Check what happens when providing an unknown logging level as an argument in the script
   ```bash
   TEST_UNKNOWN_LEVEL="true" ./entrypoint.sh / 75 92
   ```

   ```bash
   # Output
   [INF] 1625928586 Sat Jul 10 17:49:46 IDT 2021 :: Getting disk usage ...
   [INF] 1625928586 Sat Jul 10 17:49:46 IDT 2021 :: Disk usage for the path "/" is 92%
   [WRN] 1625928586 Sat Jul 10 17:49:46 IDT 2021 :: Disk usage is higher than the warning threshold of 75%
   [ERR] 1625928586 Sat Jul 10 17:49:46 IDT 2021 :: [EXIT_CODE=2] The argument "WONKA" does not exist in INF OFF WRN DBG 
   ```

## Advanced Bash Expressions

### Piping the data

Using `|` to pipe the data and getting the fifth element of the final line (Milla Jovovich? Bruce Willis?)
```bash
get last line | squash spaces     | split string by " " and get the Fifth Element 
tail -1       | tr -s "[:space:]" | cut -d" " -f5
```

This expression is used in the code in

```bash
path="/" # pseudo code
usage_msg="$(df -h "$path")"
echo -e "$usage_msg" # print temporary variable, including line breaks `-e`
percentage_msg="$(echo "$usage_msg" | tail -1 | tr -s "[:space:]" | cut -d" " -f5)"
echo "$percentage_msg" # print results
```

### Associative Array Keys As Array

Keys array of a given associative array
```bash 
declare -A ASSOCIATIVE_ARRAY=([FIRST]=1 [SECOND]=2)
echo ${!ASSOCIATIVE_ARRAY[*]}
```

```bash
# Output
FIRST SECOND
```

This expression is used in the code in - `${!_LOGGING_LEVELS[*]}`


### Initializing Variables

1. Use the first argument `$1` as the default value; if empty, use the var `$DISK_USAGE_PATH`

   ```bash
   _DISK_USAGE_PATH="${1:-"$DISK_USAGE_PATH"}"
   ```

1. Check if default value is set, if not, set to `/`
   ```bash
   _DISK_USAGE_PATH="${_DISK_USAGE_PATH:-"/"}"
   ```

### Substring

Replace all `%` instances with `""` - The chars `//` after `MY_VAR` stands for "all instances"; when using a single `/` it removes the first instance only
```bash
${MY_VAR//replace_this/with_this} - 
```

This expression is used in the code in - 

```bash
percentage_msg="$(echo "$usage_msg" | tail -1 | tr -s "[:space:]" | cut -d" " -f5)" # pseudo code
percentage="${percentage_msg//%/}"
echo "$percentage"
```

```bash
# Output - varies per machine
6
```

### Datetime

```bash
$(date +%s) # DDD MMM DD HH:MM:SS TZ YYYY
$(date)     # 1234567890 unix timestamp
```

## References

1. [Simple logging levels in Bash](https://stackoverflow.com/a/48087251/5285732)
2. [Create timestamp variable in bash script](https://stackoverflow.com/questions/17066250/create-timestamp-variable-in-bash-script)

## Authors

Created and maintained by [Meir Gabay](https://github.com/unfor19)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/unfor19/bash-logging/blob/master/LICENSE) file for details
