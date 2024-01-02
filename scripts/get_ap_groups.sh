#!/bin/bash

readonly TYPE="ap_groups"
readonly ENDPOINT="proxy/network/v2/api/site/default/apgroups"
readonly SORT_BY='sort_by(._id)'

source ./scripts/json_utils.sh
source ./scripts/log_utils.sh

log_console "Retrieving $TYPE..."

source ./scripts/get_token.sh "$@"

# Fetch the data
raw=$(fetch_raw_json "$UNIFI_IP" "$ENDPOINT" "$TYPE" "$TOKEN")

# Post-processing
alphabetize_raw_json "$raw" | jq "$SORT_BY" > json/$TYPE.json
log_debug "Sorted JSON saved to json/$TYPE.json"
