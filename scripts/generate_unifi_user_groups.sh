#!/bin/bash

# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/user_groups.json"
readonly KEYS=(
  "_id"
  "name"
  "qos_rate_max_up"
  "qos_rate_max_down"
  "site_id"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_user_group\" \"${args[sanitized_id]}\" {"
        echo "  name = \"${args[name]}\""
        echo "  qos_rate_max_up = ${args[qos_rate_max_up]}"
        echo "  qos_rate_max_down = ${args[qos_rate_max_down]}"
        echo ""
        if [ "${site_id_to_name[${args[site_id]}]}" = "unifi_site_Default" ]; then
            echo "  # Commenting out the default site as the provider will attempt"
            echo "  # to destroy / create if it is included"
            echo ""
            echo "  # site = local.${site_id_to_name[${args[site_id]}]}"
        else
            echo "  site = local.${site_id_to_name[${args[site_id]}]}"
        fi
        echo "}"
        echo ""
    } >> unifi_user_groups.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_user_group.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_user_groups_import.tf
}

write_local() {
    local -n args=$1

    echo "  unifi_user_group_${args[sanitized_name]} = unifi_user_group.${args[sanitized_id]}" >> unifi_user_groups_map.tf
}

main() {
    load_site_mappings

    > unifi_user_groups.tf
    > unifi_user_groups_import.tf
    > unifi_user_groups_map.tf

    echo "locals {" > unifi_user_groups_map.tf

    log_console_object_count "$json_file_name"

    while IFS=$'◊' read -ra line_data; do
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

    echo "}" >> unifi_user_groups_map.tf
}

# Execute the main function
main
