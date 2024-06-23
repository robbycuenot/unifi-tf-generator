#!/usr/bin/env bash
echo `which bash`
echo `bash --version`
source ./scripts/log_utils.sh

# Initialize variables
UNIFI_IP=""
UNIFI_USER=""
UNIFI_PASSWORD=""
UNIFI_TOKEN=""

# Function to show usage
usage() {
    log_console "Usage: $0 -i UNIFI_IP [-u UNIFI_USER -p UNIFI_PASSWORD] [-t UNIFI_TOKEN]"
    exit 1
}

# Parse command-line options
while getopts "i:u:p:t:v" opt; do
    case $opt in
        i) UNIFI_IP=$OPTARG ;;
        u) UNIFI_USER=$OPTARG ;;
        p) UNIFI_PASSWORD=$OPTARG ;;
        t) UNIFI_TOKEN=$OPTARG ;;
        *) usage ;;
    esac
done

# Fallback to environment variables if no arguments are provided
if [ -z "$UNIFI_IP" ]; then
    UNIFI_IP=$SECRET_UNIFI_IP
fi
if [ -z "$UNIFI_USER" ]; then
    UNIFI_USER=$SECRET_UNIFI_USER
fi
if [ -z "$UNIFI_PASSWORD" ]; then
    UNIFI_PASSWORD=$SECRET_UNIFI_PASSWORD
fi

# Check for required IP address
if [ -z "$UNIFI_IP" ]; then
    log_console "Error: UNIFI_IP is required."
    usage
fi

# Determine login method and get/set token
if [ -z "$UNIFI_TOKEN" ]; then
    # Login to get token
    log_console "Logging in..."
    log_debug "Attempting to get token with user credentials..."
    # Debug: Print the values being used (except password for security)
    log_debug "Using UNIFI_IP: $UNIFI_IP"
    log_debug "Using UNIFI_USER: $UNIFI_USER"
    response=$(curl -i -s -S "https://$UNIFI_IP/api/auth/login" \
        -H "authority: $UNIFI_IP" \
        -H 'accept: */*' \
        -H 'accept-language: en-US,en' \
        -H 'content-type: application/json' \
        -H "origin: $UNIFI_IP" \
        --data-raw "{\"username\":\"$UNIFI_USER\",\"password\":\"$UNIFI_PASSWORD\",\"token\":\"\",\"rememberMe\":false}" \
        --compressed \
        --insecure)

    # Separate headers and JSON body for logging
    headers=$(echo "$response" | sed -n '1,/^\r$/p')
    json_body=$(echo "$response" | sed -n '/^\r$/,$p' | sed '1d')

    log_debug "Auth Headers:"
    log_debug "$headers"
    log_debug "Auth JSON Body:"
    log_debug "$(echo "$json_body" | jq .)"

    TOKEN=$(echo "$response" | grep 'set-cookie:' | awk -F'TOKEN=' '{print $2}' | awk -F';' '{print $1}')
    log_debug "Obtained TOKEN: $TOKEN"
elif [ -n "$UNIFI_TOKEN" ]; then
    # Use provided token
    TOKEN=$UNIFI_TOKEN
    log_debug "Using provided TOKEN."
else
    log_console "Error: Either UNIFI_USER and UNIFI_PASSWORD or UNIFI_TOKEN is required."
    usage
fi

# Export TOKEN
export TOKEN
export UNIFI_IP

# Check if TOKEN is empty and exit if it is
if [ -z "$TOKEN" ]; then
    log_console "Error: Failed to obtain token."
    exit 1
fi
