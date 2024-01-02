#!/bin/bash

# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/wlans.json"
readonly KEYS=(
  "_id"
  "name"
  "security"
  "usergroup_id"
  "is_guest"
  "site_id"
  "networkconf_id"
  "ap_group_ids"
  "radiusprofile_id"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_wlan\" \"${args[sanitized_id]}\" {"
        echo "  name = \"${args[name]}\""

        if [ "${site_id_to_name[${args[site_id]}]}" = "unifi_site_Default" ]; then
            echo "  # site = local.${site_id_to_name[${args[site_id]}]}.name"
        else
            echo "  site = local.${site_id_to_name[${args[site_id]}]}.name"
        fi

        echo "  security = \"${args[security]}\""
        echo "  user_group_id = local.${user_group_id_to_name[${args[usergroup_id]}]}.id"
        echo "  is_guest = ${args[is_guest]}"
        echo "  network_id = local.${network_id_to_name[${args[networkconf_id]}]}.id"
        echo "  radius_profile_id = local.${radius_profile_id_to_name[${args[radiusprofile_id]}]}.id"
        echo "  passphrase = var.unifi_wlan_${args[sanitized_name]}_passphrase"
        c_echo_ap_groups "${args[ap_group_ids]}"
        echo "}"
        echo ""
    } >> unifi_wlans.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_wlan.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_wlans_import.tf
}

write_local() {
    local -n args=$1

    echo "  unifi_wlan_${args[sanitized_name]} = unifi_wlan.${args[sanitized_id]}" >> unifi_wlans_map.tf
}

main() {
    load_site_mappings
    load_user_group_mappings
    load_network_mappings
    load_ap_group_mappings
    load_radius_profile_mappings

    > unifi_wlans.tf
    > unifi_wlans_import.tf
    > unifi_wlans_map.tf

    echo "locals {" > unifi_wlans_map.tf

    log_console_object_count "$json_file_name"

    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[name]}")"

        log_debug "  Writing object: id=${resource_args[_id]} name=${resource_args[name]}"

        write_resource resource_args
        write_import resource_args
        write_local resource_args
    done < <(read_json "$json_file_name")

    echo "}" >> unifi_wlans_map.tf
}

# Execute the main function
main
