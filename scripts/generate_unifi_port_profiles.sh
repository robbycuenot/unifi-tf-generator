#!/usr/bin/env bash
# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/port_profiles.json"
readonly KEYS=(
  "_id"
  "autoneg"
  "dot1x_ctrl"
  "dot1x_idle_timeout"
  "egress_rate_limit_kbps"
  "egress_rate_limit_kbps_enabled"
  "excluded_networkconf_ids"
  "forward"
  "full_duplex"
  "isolation"
  "lldpmed_enabled"
  "lldpmed_notify_enabled"
  "name"
  "native_networkconf_id"
  "op_mode"
  "poe_mode"
  "port_keepalive_enabled"
  "port_security_enabled"
  "port_security_mac_address"
  "setting_preference"
  "site_id"
  "speed"
  "stormctrl_bcast_enabled"
  "stormctrl_bcast_level"
  "stormctrl_bcast_rate"
  "stormctrl_mcast_enabled"
  "stormctrl_mcast_level"
  "stormctrl_mcast_rate"
  "stormctrl_ucast_enabled"
  "stormctrl_ucast_level"
  "stormctrl_ucast_rate"
  "stp_port_mode"
  "tagged_vlan_mgmt"
  "voice_networkconf_id"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_port_profile\" \"${args[sanitized_id]}\" {"
        c_echo "name"                           "  name                  = \"%s\""
        echo                                    "  site                  = local.${args[site_resource_name]}.name"
        c_echo "native_networkconf_id"          "  native_networkconf_id = local.${args[network_resource_name]}.id"
        echo ""         
        c_echo "autoneg"                        "  autoneg                        = %s"
        c_echo "dot1x_ctrl"                     "  dot1x_ctrl                     = \"%s\""
        c_echo "dot1x_idle_timeout"             "  dot1x_idle_timeout             = %s"
        c_echo "egress_rate_limit_kbps"         "  egress_rate_limit_kbps         = %s"
        c_echo "egress_rate_limit_kbps_enabled" "  egress_rate_limit_kbps_enabled = %s"
        c_echo "forward"                        "  forward                        = \"%s\""
        c_echo "full_duplex"                    "  full_duplex                    = %s"
        c_echo "isolation"                      "  isolation                      = %s"
        c_echo "lldpmed_enabled"                "  lldpmed_enabled                = %s"
        c_echo "lldpmed_notify_enabled"         "  lldpmed_notify_enabled         = %s"
        c_echo "op_mode"                        "  op_mode                        = \"%s\""
        c_echo "poe_mode"                       "  poe_mode                       = \"%s\""
        c_echo "port_security_enabled"          "  port_security_enabled          = %s"
        c_echo_port_security_mac_address "${args[port_security_mac_address]}"
        c_echo "priority_queue1_level"          "  priority_queue1_level          = %s"
        c_echo "priority_queue2_level"          "  priority_queue2_level          = %s"
        c_echo "priority_queue3_level"          "  priority_queue3_level          = %s"
        c_echo "priority_queue4_level"          "  priority_queue4_level          = %s"
        c_echo "speed"                          "  speed                          = %s"
        c_echo "stormctrl_bcast_enabled"        "  stormctrl_bcast_enabled        = %s"
        c_echo "stormctrl_bcast_level"          "  stormctrl_bcast_level          = %s"
        c_echo "stormctrl_bcast_rate"           "  stormctrl_bcast_rate           = %s"
        c_echo "stormctrl_mcast_enabled"        "  stormctrl_mcast_enabled        = %s"
        c_echo "stormctrl_mcast_level"          "  stormctrl_mcast_level          = %s"
        c_echo "stormctrl_mcast_rate"           "  stormctrl_mcast_rate           = %s"
        c_echo "stormctrl_type"                 "  stormctrl_type                 = \"%s\""
        c_echo "stormctrl_ucast_enabled"        "  stormctrl_ucast_enabled        = %s"
        c_echo "stormctrl_ucast_level"          "  stormctrl_ucast_level          = %s"
        c_echo "stormctrl_ucast_rate"           "  stormctrl_ucast_rate           = %s"
        c_echo "stp_port_mode"                  "  stp_port_mode                  = %s"
        # This appears to be deprecated, in favor of excluded_networkconf_ids
        # c_echo "tagged_networkconf_ids"         "  tagged_networkconf_ids         = %s"
        c_echo "voice_networkconf_id"           "  voice_networkconf_id           = \"%s\""
        echo "}"
        echo ""
    } >> unifi_port_profiles.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_port_profile.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_port_profiles_import.tf
}

write_local() {
    local -n args=$1

    echo "  unifi_port_profile_${args[sanitized_name]} = unifi_port_profile.${args[sanitized_id]}" >> unifi_port_profiles_map.tf
}

main() {
    # Load the mappings for retrieving names from IDs
    load_device_mappings
    load_network_mappings
    load_site_mappings
    load_user_mappings

    # Clear existing files or create them if they don't exist
    > unifi_port_profiles.tf
    > unifi_port_profiles_import.tf
    > unifi_port_profiles_map.tf

    # Write the header for the locals block
    echo "locals {" > unifi_port_profiles_map.tf

    log_console_object_count "$json_file_name"

    # Process each line from read_json
    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[name]}")"
        resource_args[site_resource_name]="${site_id_to_name[${resource_args[site_id]}]}"
        resource_args[network_resource_name]="${network_id_to_name[${resource_args[native_networkconf_id]}]}"

        log_debug "  Writing object: id=${resource_args[_id]} name=${resource_args[name]}"
        
        write_resource resource_args
        write_import resource_args
        write_local resource_args

    done < <(read_json "$json_file_name" KEYS)

    # Close the locals block
    echo "}" >> unifi_port_profiles_map.tf
}

# Execute the main function
main
