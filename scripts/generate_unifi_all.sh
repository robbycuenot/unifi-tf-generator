#!/usr/bin/env bash
# Source the utility scripts
source ./scripts/log_utils.sh

log_debug "Executing generate_unifi_all.sh..."

./scripts/generate_unifi_sites.sh
./scripts/generate_unifi_networks.sh
./scripts/generate_unifi_dynamic_dns.sh
./scripts/generate_unifi_user_groups.sh
./scripts/generate_unifi_users.sh
./scripts/generate_unifi_port_forward.sh

# Devices and port profiles are dependent on each other
# for mappings. Executing one of them redundantly will
# resolve the mapping issue.
if [ ! -f unifi_devices_map.tf ]; then
    log_console ""
    log_console "unifi_devices_map.tf not found. Port profiles"
    log_console "will be generated first, and will display a mapping error."
    log_console "This is expected, will be resolved when it executes again after"
    log_console "generating devices. Once the initial codebase has been generated,"
    log_console "the error will resolve and port profiles will only be executed once"
    log_console "per run."
    log_console ""
    ./scripts/generate_unifi_port_profiles.sh
    ./scripts/generate_unifi_devices.sh
    ./scripts/generate_unifi_port_profiles.sh
else
    ./scripts/generate_unifi_port_profiles.sh
    ./scripts/generate_unifi_devices.sh
fi

./scripts/generate_unifi_ap_groups.sh
./scripts/generate_unifi_radius_profiles.sh
./scripts/generate_unifi_accounts.sh
./scripts/generate_unifi_wlans.sh
./scripts/generate_unifi_settings.sh
./scripts/generate_unifi_firewall_groups.sh
./scripts/generate_unifi_firewall_rules.sh
./scripts/generate_unifi_static_routes.sh
./scripts/generate_variables.sh

log_debug "Finished executing generate_unifi_all.sh"
