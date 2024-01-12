#!/bin/bash

# Source the utility script
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/static_routes.json"
readonly KEYS=(
  "_id"
  "enabled"
  "gateway_device"
  "gateway_type"
  "name"
  "site_id"
  "static-route_distance"
  "static-route_interface"
  "static-route_network"
  "static-route_nexthop"
  "static-route_type"
  "type"
)

write_resource() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "resource \"unifi_static_route\" \"${args[sanitized_id]}\" {"

        c_echo "name"                                 "  name      = \"%s\""
        echo                                          "  site      = local.unifi_site_Default.name"
        c_echo "enabled"                              "  # enabled   = %s"
        echo ""
        c_echo "static-route_network"                 "  network   = \"%s\""
        c_echo "static-route_type"                    "  type      = \"%s\""
        c_echo "static-route_distance"                "  distance  = %s"
        c_echo "static_route_interface_resource_name" "  interface = %s"
        c_echo "static-route_nexthop"                 "  next_hop  = \"%s\""
        echo "}"
        echo ""
    } >> unifi_static_routes.tf
}

write_import() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "import {"
        echo "    to = unifi_static_route.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_static_routes_import.tf
}

write_local() {
    local -n args=$1  # Use a nameref to refer to the associative array

    echo "  unifi_static_route_${args[sanitized_name]} = unifi_static_route.${args[sanitized_id]}" >> unifi_static_routes_map.tf
}

main() {
    # Load the mappings
    load_device_mappings
    load_network_mappings
    load_site_mappings

    # Clear existing files or create them if they don't exist
    > unifi_static_routes.tf
    > unifi_static_routes_import.tf
    > unifi_static_routes_map.tf

    # Initialize unifi_static_routes_map.tf with the header
    echo "locals {" > unifi_static_routes_map.tf

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
        resource_args[site_resource_name]="${site_id_to_name[${resource_args[site_id]}]}"
        if [ -n "${resource_args[static-route_interface]}" ]; then
            if [ -n "${network_id_to_name[${resource_args[static-route_interface]}]}" ]; then
                resource_args[static_route_interface_resource_name]="local.${network_id_to_name[${resource_args[static-route_interface]}]}.id"
            else
                resource_args[static_route_interface_resource_name]="\"${resource_args[static-route_interface]}\""
            fi
        else
            resource_args[static_route_interface_resource_name]=""
        fi

        log_debug "  Writing object: id=${resource_args[_id]} name=${resource_args[name]}"

        # Write the resource blocks
        write_resource resource_args

        # Write the import blocks
        write_import resource_args

        # Write the locals block
        write_local resource_args

    done < <(read_json "$json_file_name" KEYS)

    # Close the locals block
    echo "}" >> unifi_static_routes_map.tf
}

# Execute the main function
main
