#!/bin/bash

# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/radius_profiles.json"
readonly KEYS=(
  "_id"
  "attr_hidden_id"
  "auth_servers"
  "interim_update_interval"
  "name"
  "site_id"
  "use_usg_auth_server"
  "vlan_enabled"
  "vlan_wlan_mode"
)

write_data() {
    local -n args=$1

    {
        echo "data \"unifi_radius_profile\" \"${args[sanitized_id]}\" {"
        c_echo "name"                  "  name = \"%s\""
        echo "}"
        echo ""
    } >> unifi_radius_profiles.tf
}

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_radius_profile\" \"${args[sanitized_id]}\" {"
        c_echo "name"                    "  name = \"%s\""
        echo                             "  site = local.${args[site_resource_name]}.name"
        echo ""
        c_echo "use_usg_auth_server"     "  use_usg_auth_server     = %s"
        c_echo "vlan_enabled"            "  vlan_enabled            = %s"
        c_echo "vlan_wlan_mode"          "  vlan_wlan_mode          = \"%s\""
        c_echo "interim_update_interval" "  interim_update_interval = %s"
        c_echo_auth_servers "${args[auth_servers]}" "${args[sanitized_name]}"
        echo "}"
        echo ""
    } >> unifi_radius_profiles.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_radius_profile.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_radius_profiles_import.tf
}

write_local() {
    local -n args=$1

    local prefix=""
    if [ "${args[attr_hidden_id]}" = "Default" ]; then
        prefix="data."
    fi

    echo "  unifi_radius_profile_${args[sanitized_name]} = ${prefix}unifi_radius_profile.${args[sanitized_id]}" >> unifi_radius_profiles_map.tf
}

main() {
    load_site_mappings
    > unifi_radius_profiles.tf
    > unifi_radius_profiles_import.tf
    echo "locals {" > unifi_radius_profiles_map.tf

    log_console_object_count "$json_file_name"

    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[name]}")"
        resource_args[site_resource_name]="${site_id_to_name[${resource_args[site_id]}]}"

        log_debug "  Writing object: id=${resource_args[_id]} name=${resource_args[name]}"

        if [ "${resource_args[attr_hidden_id]}" = "Default" ]; then
            write_data resource_args
        else
            write_resource resource_args
            write_import resource_args
        fi
        write_local resource_args

    done < <(read_json "$json_file_name" KEYS)

    echo "}" >> unifi_radius_profiles_map.tf
}

# Execute the main function
main
