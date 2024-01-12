#!/bin/bash

# Source the utility script
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/firewall_groups.json"
readonly KEYS=(
  "_id"
  "group_members"
  "group_type"
  "name"
  "site_id"
)

write_resource() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "resource \"unifi_firewall_group\" \"${args[sanitized_id]}\" {"

        c_echo "name"       "  name    = \"%s\""
        echo                "  site    = local.unifi_site_Default.name"
        c_echo "group_type" "  type    = \"%s\""
        c_echo_firewall_group_members "${args[group_members]}"
        echo "}"
        echo ""
    } >> unifi_firewall_groups.tf
}

write_import() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "import {"
        echo "    to = unifi_firewall_group.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_firewall_groups_import.tf
}

write_local() {
    local -n args=$1  # Use a nameref to refer to the associative array

    echo "  unifi_firewall_group_${args[sanitized_name]} = unifi_firewall_group.${args[sanitized_id]}" >> unifi_firewall_groups_map.tf
}

main() {
    # Clear existing files or create them if they don't exist
    > unifi_firewall_groups.tf
    > unifi_firewall_groups_import.tf
    > unifi_firewall_groups_map.tf

    # Initialize unifi_firewall_groups_map.tf with the header
    echo "locals {" > unifi_firewall_groups_map.tf

    log_console_object_count "$json_file_name"

    # Process each line from read_json
    while IFS='◊' read -ra values; do

        # Create an associative array from the keys and values
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${values[index]}"
        done

        # Parse additional data
        resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[name]}")"

        log_debug "  Writing object: id=${resource_args[_id]} name=${resource_args[name]}"

        # Write the resource blocks
        write_resource resource_args

        # Write the import blocks
        write_import resource_args

        # Write the locals block
        write_local resource_args

    done < <(read_json "$json_file_name" KEYS)

    # Close the locals block
    echo "}" >> unifi_firewall_groups_map.tf
}

# Execute the main function
main
