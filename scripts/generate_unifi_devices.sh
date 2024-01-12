#!/bin/bash

# Source the utility script
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/devices.json"
readonly KEYS=(
  "_id"
  "disabled"
  "ip"
  "lan_ip"
  "mac"
  "model"
  "name"
  "port_table"
)

write_resource() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "resource \"unifi_device\" \"${args[sanitized_mac]}\" {"

        c_echo "name"  "  name                   = \"%s\""
        c_echo "mac"   "  mac                    = \"%s\""
        echo           "  site                   = local.unifi_site_Default.name"

        # Commented fields
        c_echo "model"      "  # model                  = \"%s\""
        # Handling the conditional presence of lan_ip or ip
        if [ -n "${args[lan_ip]}" ]; then
            c_echo "lan_ip" "  # lan_ip                 = \"%s\""
        else
            c_echo "ip"     "  # ip                     = \"%s\""
        fi
        c_echo "disabled"   "  # disabled               = %s"  # Assuming 'disabled' value is a boolean

        echo ""

        # Conditionally write the port overrides
        c_echo_port_overrides "${args[port_table]}"

        echo "  allow_adoption = false"
        echo "  forget_on_destroy = false"
        echo ""
        echo "  lifecycle {"
        echo "    prevent_destroy = true"
        echo "  }"
        echo "}"
        echo ""
    } >> unifi_devices.tf
}

write_import() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "import {"
        echo "    to = unifi_device.${args[sanitized_mac]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_devices_import.tf
}

write_local() {
    local -n args=$1  # Use a nameref to refer to the associative array

    echo "  unifi_device_${args[sanitized_name]} = unifi_device.${args[sanitized_mac]}" >> unifi_devices_map.tf
}


main() {
    # Load the mappings for retrieving names from IDs
    load_port_profile_mappings

    # Clear existing files or create them if they don't exist
    > unifi_devices.tf
    > unifi_devices_import.tf
    > unifi_devices_map.tf

    # Initialize unifi_devices_map.tf with the header
    echo "locals {" > unifi_devices_map.tf

    log_console_object_count "$json_file_name"

    # Process each line from read_json
    while IFS='◊' read -ra values; do

        # Create an associative array from the keys and values
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${values[index]}"
        done

        # Parse additional data
        resource_args[sanitized_mac]="id_$(sanitize_for_terraform "${resource_args[mac]}")"
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[name]}")"

        log_debug "  Writing object: type=device id=${resource_args[_id]} mac=${resource_args[mac]} name=${resource_args[name]}"

        # Write the resource blocks
        write_resource resource_args

        # Write the import blocks
        write_import resource_args

        # Write the locals block
        write_local resource_args

    done < <(read_json "$json_file_name" KEYS)

    # Close the locals block
    echo "}" >> unifi_devices_map.tf
}

# Execute the main function
main
