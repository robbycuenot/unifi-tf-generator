#!/usr/bin/env bash
# Source the utility script
source ./scripts/json_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/sites.json"
readonly KEYS=(
  "_id"
  "desc"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_site\" \"${args[sanitized_id]}\" {"
        echo "  description = \"${args[desc]}\""
        echo ""
        echo "  lifecycle {"
        echo "    prevent_destroy = true"
        echo "  }"
        echo "}"
        echo ""
    } >> unifi_sites.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_site.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_sites_import.tf
}

write_local() {
    local -n args=$1

    echo "  unifi_site_${args[sanitized_desc]} = unifi_site.${args[sanitized_id]}" >> unifi_sites_map.tf
}

main() {
    > unifi_sites.tf
    > unifi_sites_import.tf
    > unifi_sites_map.tf

    echo "locals {" > unifi_sites_map.tf

    log_console_object_count "$json_file_name"

    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"
        resource_args[sanitized_desc]="$(sanitize_for_terraform "${resource_args[desc]}")"

        log_debug "  Writing object: id=${resource_args[_id]} desc=${resource_args[desc]}"

        write_resource resource_args
        write_import resource_args
        write_local resource_args
    done < <(read_json "$json_file_name" KEYS)

    echo "}" >> unifi_sites_map.tf
}

# Execute the main function
main
