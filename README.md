# bash-logging


## Usage

1. Download the `entrypoint.sh` script
    ```bash
    TARGET_URL="https://raw.githubusercontent.com/unfor19/bash-logging/master/entrypoint.sh" && \
    wget -O entrypoint.sh "$TARGET_URL" && \
    chmod +x ./entrypoint.sh
    ```
1. Provide arguments or variablse
    ```bash
    ./entrypoint.sh "$DISK_USAGE_PATH" "$WARNING_THRESHOLD" "$MOCKED_DISK_USAGE"
    ```

## Examples

1. No arguments
   ```bash
   ./entrypoint.sh
   # Output
   [INF] 1625876204 Sat Jul 10 09:16:44 IDT 2021 :: Getting disk usage ...
   [INF] 1625876204 Sat Jul 10 09:16:44 IDT 2021 :: Disk usage for the path "/" is 6%
   [INF] 1625876204 Sat Jul 10 09:16:44 IDT 2021 :: Disk usage is lower than the warning threshold 85%
   ```

1. Mocking disk size to check warning message
   ```bash
   ./entrypoint.sh / 75 92
   # Output
   [INF] 1625876306 Sat Jul 10 09:18:26 IDT 2021 :: Getting disk usage ...
   [INF] 1625876306 Sat Jul 10 09:18:26 IDT 2021 :: Disk usage for the path "/" is 92%
   [WRN] 1625876306 Sat Jul 10 09:18:26 IDT 2021 :: Disk usage is higher than the warning threshold 75%   
   ```
1. Debugging
   ```bash
   LOGGING_LEVEL="DBG" ./entrypoint.sh / 75 92
   # Output
   [INF] 1625876349 Sat Jul 10 09:19:09 IDT 2021 :: Getting disk usage ...
   [DBG] 1625876349 Sat Jul 10 09:19:09 IDT 2021 :: Finished getting disk usage 92 with the given path /
   [DBG] 1625876350 Sat Jul 10 09:19:10 IDT 2021 :: Warning threshold is 75
   [INF] 1625876350 Sat Jul 10 09:19:10 IDT 2021 :: Disk usage for the path "/" is 92%
   [WRN] 1625876350 Sat Jul 10 09:19:10 IDT 2021 :: Disk usage is higher than the warning threshold 75%
   [DBG] 1625876350 Sat Jul 10 09:19:10 IDT 2021 :: Successfully completed disk usage process
   ```
1. Check what happens when providing an unknown logging level as an environment variable
   ```bash
   LOGGING_LEVEL="WILLY" ./entrypoint.sh / 75 92
   # Output
   [ERR] 1625876707 Sat Jul 10 09:25:07 IDT 2021 :: [EXIT_CODE=3] The variable LOGGING_LEVEL "WILLY" does not exist in INF OFF WRN DBG
   ```
1. Check what happens when providing an unknown logging level as an argument in the script
   ```bash
   TEST_UNKNOWN_LEVEL="true" ./entrypoint.sh / 75 92
   # Output
   [INF] 1625876424 Sat Jul 10 09:20:24 IDT 2021 :: Getting disk usage ...
   [INF] 1625876424 Sat Jul 10 09:20:24 IDT 2021 :: Disk usage for the path "/" is 92%
   [WRN] 1625876424 Sat Jul 10 09:20:24 IDT 2021 :: Disk usage is higher than the warning threshold 75%
   [ERR] 1625876424 Sat Jul 10 09:20:24 IDT 2021 :: [EXIT_CODE=2] The argument "WONKA" does not exist in INF OFF WRN DBG   
   ```

## Advanced Bash Expressions

### Associative Array Keys As Array

Keys array of a given associative array
```bash 
declare -A ASSOCIATIVE_ARRAY=([FIRST]=1 [SECOND]=2)
echo ${!ASSOCIATIVE_ARRAY[*]}
# Output
FIRST SECOND
```

This expression is used in the code in - `${!_LOGGING_LEVELS[*]}`

### Piping the data

```bash
get last line | squash spaces     | split string by " " and get the Fifth Element (Milla Jovovich? Bruce Willis?)
tail -1       | tr -s "[:space:]" | cut -d" " -f5
```

This expression is used in the code in

```bash
usage_msg="$(df -h "$path")"
percentage_msg="$(echo "$usage_msg" | tail -1 | tr -s "[:space:]" | cut -d" " -f5)"
```

### Initializing Variables

1. Use first argument $1 as the default value, if empty, use the var $DISK_USAGE_PATH

   ```bash
   _DISK_USAGE_PATH="${1:-"$DISK_USAGE_PATH"}"
   ```

1. Check if default value is set, if not, set to "/"
   ```bash
   _DISK_USAGE_PATH="${_DISK_USAGE_PATH:-"/"}"
   ```

### Substring

Replace all "%" instances with ""
```bash
${MY_VAR//replace_this/with_this} - "//" stands for "all instances", when using "/" it removes the first instance only
```

This expression is used in the code in - `"${percentage_msg//%/}"`

### Datetime

```bash
$(date +%s) - DDD MMM DD HH:MM:SS TZ YYYY
$(date)     - 1234567890 unix timestamp
```

## References

1. [Simple logging levels in Bash](https://stackoverflow.com/a/48087251/5285732)
2. [Create timestamp variable in bash script](https://stackoverflow.com/questions/17066250/create-timestamp-variable-in-bash-script)

## Authors

Created and maintained by [Meir Gabay](https://github.com/unfor19)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/unfor19/bash-logging/blob/master/LICENSE) file for details