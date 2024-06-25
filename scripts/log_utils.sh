#!/usr/bin/env bash
# Redirect stderr to both the console and log.txt, adding [ERROR] prefix
exec 2> >(while read line; do echo "[ERROR] $line"; done | tee -a log.txt)

# Function for logging
log_debug() {
    echo "[DEBUG] $1" >> log.txt
}

log_console() {
    echo "[CONSOLE] $1" >> log.txt
    echo "$1"
}

log_debug_object_count() {
    local file_name="$1"
    local type=$(echo "$file_name" | sed 's/json\///g' | sed 's/\.json//g')

    count=$(jq '. | length' "$file_name")

    if [ "$count" -eq 1 ]; then
        log_debug "Reading $type: $count object found..."
    else
        log_debug "Reading $type: $count objects found..."
    fi
}

log_console_object_count() {
    local file_name="$1"
    local type=$(echo "$file_name" | sed 's/json\///g' | sed 's/\.json//g')

    count=$(jq '. | length' "$file_name")

    # Calculate the number of spaces needed
    local max_length=15  # length of "radius_profiles"
    local type_length=${#type}
    local num_spaces=$((max_length - type_length + 1))  # +1 for the space after the colon
    local spaces=$(printf '%*s' "$num_spaces")

    if [ "$count" -eq 1 ]; then
        log_console "Processing $type:$spaces$count object..."
    else
        log_console "Processing $type:$spaces$count objects..."
    fi
}
