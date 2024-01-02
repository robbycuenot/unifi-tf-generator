#!/bin/bash

# Source the utility script
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/dynamic_dns.json"
readonly KEYS=(
  "_id"
  "host_name"
  "interface"
  "login"
  "server"
  "service"
  "site_id"
  "x_password"
)

write_resource() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "resource \"unifi_dynamic_dns\" \"${args[sanitized_id]}\" {"

        c_echo "host_name" "  host_name = \"%s\""
        c_echo "service"   "  service   = \"%s\""
        c_echo "interface" "  interface = \"%s\""
        # On default site, causes infinite create/destroy loop
        # echo               "  site      = local.unifi_site_Default.name"
        echo ""
        c_echo "server"    "  server    = \"%s\""  
        c_echo "login"     "  login     = \"%s\""
        echo               "  password  = var.unifi_dynamic_dns_${args[sanitized_name]}_password"
        echo ""
        echo "}"
        echo ""
    } >> unifi_dynamic_dns.tf
}

write_import() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "import {"
        echo "    to = unifi_dynamic_dns.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_dynamic_dns_import.tf
}

write_local() {
    local -n args=$1  # Use a nameref to refer to the associative array

    echo "  unifi_dynamic_dns_${args[sanitized_name]} = unifi_dynamic_dns.${args[sanitized_id]}" >> unifi_dynamic_dns_map.tf
}


main() {
    # Load the mappings for retrieving names from IDs
    load_site_mappings

    # Clear existing files or create them if they don't exist
    > unifi_dynamic_dns.tf
    > unifi_dynamic_dns_import.tf
    > unifi_dynamic_dns_map.tf

    # Initialize unifi_dynamic_dns_map.tf with the header
    echo "locals {" > unifi_dynamic_dns_map.tf

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
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[service]}_${resource_args[host_name]}")"

        log_debug "  Writing object: type=dynamic_dns id=${resource_args[_id]} service=${resource_args[service]} server=${resource_args[server]} host_name=${resource_args[host_name]}"

        # Write the resource blocks
        write_resource resource_args

        # Write the import blocks
        write_import resource_args

        # Write the locals block
        write_local resource_args

    done < <(read_json "$json_file_name")

    # Close the locals block
    echo "}" >> unifi_dynamic_dns_map.tf
}

# Execute the main function
main
