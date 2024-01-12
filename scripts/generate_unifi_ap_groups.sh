#!/bin/bash

# Source the utility script
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/ap_groups.json"
readonly KEYS=(
  "_id"
  "attr_hidden_id"
  "attr_no_delete"
  "device_macs"
  "for_wlanconf"
  "name"
)

write_data() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "data \"unifi_ap_group\" \"${args[sanitized_id]}\" {"
        if [ "${args[attr_hidden_id]}" = "default" ]; then
            echo                "  # Commenting out name, as this is the default group"
            c_echo "name"       "  # name                   = \"%s\""
        else
            c_echo "name"       "  name                   = \"%s\""
        fi
        c_echo "attr_hidden_id" "  # attr_hidden_id         = \"%s\""
        c_echo "attr_no_delete" "  # attr_no_delete         = %s"
        c_echo "for_wlanconf"   "  # for_wlanconf           = %s"

        # Conditionally write the device_macs
        c_echo_macs "${args[device_macs]}"

        echo "}"
        echo ""
    } >> unifi_ap_groups.tf
}

write_local() {
    local -n args=$1  # Use a nameref to refer to the associative array

    echo "  unifi_ap_group_${args[sanitized_name]} = data.unifi_ap_group.${args[sanitized_id]}" >> unifi_ap_groups_map.tf
}

main() {
    # Load the mappings for retrieving names from IDs
    load_device_mappings

    # Clear existing files or create them if they don't exist
    > unifi_ap_groups.tf
    echo "locals {" > unifi_ap_groups_map.tf

    log_console_object_count "$json_file_name"

    # Process each line from read_json
    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        # Map read values to associative array using KEYS
        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        # Parse additional data for Terraform identifiers
        resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[name]}")"

        log_debug "  Writing object: type=ap_group id=${resource_args[_id]} name=${resource_args[name]}"

        # Write the data blocks by passing the associative array
        write_data resource_args

        # Write the locals block by passing the associative array
        write_local resource_args

    done < <(read_json "$json_file_name" KEYS)

    # Write the footer for the locals block
    echo "}" >> unifi_ap_groups_map.tf
}

# Execute the main function
main