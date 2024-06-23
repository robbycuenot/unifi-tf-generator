#!/usr/bin/env bash
source ./scripts/log_utils.sh
log_debug "Executing get_all.sh..."

# Source get_token.sh to set TOKEN and UNIFI_IP
source ./scripts/get_token.sh "$@"

./scripts/get_accounts.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_ap_groups.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_devices.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_dynamic_dns.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_firewall_groups.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_firewall_rules.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_networks.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_port_forward.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_port_profiles.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_radius_profiles.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_settings.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_sites.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_static_routes.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_user_groups.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_users.sh -i $UNIFI_IP -t $TOKEN
./scripts/get_wlans.sh -i $UNIFI_IP -t $TOKEN

log_debug "Finished executing get_all.sh"
