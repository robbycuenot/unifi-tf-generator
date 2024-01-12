#!/bin/bash

# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/port_forward.json"
readonly KEYS=(
  "_id"
  "dst_port"
  "enabled"
  "fwd"
  "fwd_port"
  "log"
  "name"
  "pfwd_interface"
  "proto"
  "site_id"
  "src"
)

readonly USER_KEYS=(
  "_id"
  "blocked"
  "dev_id_override"
  "fingerprint_override"
  "fixed_ip"
  "hostname"
  "local_dns_record"
  "local_dns_record_enabled"
  "mac"
  "name"
  "network_id"
  "note"
  "noted"
  "use_fixedip"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_port_forward\" \"${args[sanitized_id]}\" {"
        c_echo "name"           "  name                   = \"%s\""
        echo                    "  site                   = local.${args[site_resource_name]}.name"
        echo ""
        c_echo "pfwd_interface" "  port_forward_interface = \"%s\""
        c_echo "proto"          "  protocol               = \"%s\""
        echo ""
        c_echo "src"            "  src_ip                 = \"%s\""
        c_echo "dst_port"       "  dst_port               = \"%s\""
        if [ -n "${args[user_resource_name]}" ]; then
            echo                "  fwd_ip                 = local.${args[user_resource_name]}.fixed_ip"
        else
            c_echo "fwd"        "  fwd_ip                 = \"%s\""
        fi
        c_echo "fwd_port"       "  fwd_port               = \"%s\""
        echo ""
        c_echo "log"            "  log                    = %s"
        echo ""
        echo                    "  # Deprecated: To disable, remove the resource block"
        c_echo "enabled"        "  # enabled                = %s"
        echo "}"
        echo ""
    } >> unifi_port_forward.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_port_forward.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_port_forward_import.tf
}

write_local() {
    local -n args=$1

    echo "  unifi_port_forward_${args[sanitized_name]} = unifi_port_forward.${args[sanitized_id]}" >> unifi_port_forward_map.tf
}

main() {
    # Load the mappings for retrieving names from IDs
    load_site_mappings
    load_user_mappings

    # Clear existing files or create them if they don't exist
    > unifi_port_forward.tf
    > unifi_port_forward_import.tf
    > unifi_port_forward_map.tf

    # Write the header for the locals block
    echo "locals {" > unifi_port_forward_map.tf

    log_console_object_count "$json_file_name"

    # Build an associative array of IPs and MAC addresses from users
    declare -A ip_mac_array
    while IFS='◊' read -ra line_data; do
        declare -A user_args

        for index in "${!USER_KEYS[@]}"; do
            user_args["${USER_KEYS[index]}"]="${line_data[index]}"
        done

        # If the use_fixedip flag is set to true, then add the IP and MAC to the array
        if [ "${user_args[use_fixedip]}" = "true" ]; then
            ip_mac_array["${user_args[fixed_ip]}"]="${user_args[mac]}"
        fi
    done < <(read_json "json/users.json" USER_KEYS)

    # Process each line from read_json
    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[name]}")"
        resource_args[site_resource_name]="${site_id_to_name[${resource_args[site_id]}]}"
        if [[ -n ${ip_mac_array[${resource_args[fwd]}]} ]]; then
            resource_args[sanitized_fwd_mac]="$(sanitize_for_terraform "${ip_mac_array[${resource_args[fwd]}]}")"
            resource_args[user_resource_name]="${user_id_to_name[${resource_args[sanitized_fwd_mac]}]}"
        fi
        log_debug "  Writing object: id=${resource_args[_id]} name=${resource_args[name]}"
        
        write_resource resource_args
        write_import resource_args
        write_local resource_args

    done < <(read_json "$json_file_name" KEYS)

    # Close the locals block
    echo "}" >> unifi_port_forward_map.tf
}

# Execute the main function
main
