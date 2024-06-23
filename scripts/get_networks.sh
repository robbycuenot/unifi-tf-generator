#!/usr/bin/env bash
readonly TYPE="networks"
readonly ENDPOINT="proxy/network/v2/api/site/default/lan/enriched-configuration"
readonly SORT_BY='map(.configuration) | sort_by(.vlan)'

source ./scripts/json_utils.sh
source ./scripts/log_utils.sh

log_console "Retrieving $TYPE..."

source ./scripts/get_token.sh "$@"

# Fetch the data
raw=$(fetch_raw_json "$UNIFI_IP" "$ENDPOINT" "$TYPE" "$TOKEN")

# Post-processing
alphabetize_raw_json "$raw" | jq "$SORT_BY" > json/$TYPE.json
log_debug "Sorted JSON saved to json/$TYPE.json"
