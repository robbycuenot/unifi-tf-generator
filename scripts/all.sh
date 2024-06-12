source ./scripts/log_utils.sh
log_debug "Executing all.sh..."

# Source get_token.sh to set TOKEN and UNIFI_IP
source ./scripts/get_token.sh "$@"

./scripts/get_all.sh -i $UNIFI_IP -t $TOKEN
./scripts/generate_unifi_all.sh

log_debug "Finished executing all.sh"