#!/usr/bin/env bash
# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/users.json"
readonly KEYS=(
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
  "virtual_network_override_enabled"
  "virtual_network_override_id"
)

write_resource() {
    local -n args=$1

    local network_resource_name=""
    if [ -n "${args[network_id]}" ]; then
        network_resource_name="${network_id_to_name[${args[network_id]}]}"
    fi

    if [ -n "${args[virtual_network_override_id]}" ] && [ "${args[virtual_network_override_enabled]}" = "true" ]; then
        network_override_name="${network_id_to_name[${args[virtual_network_override_id]}]}"
    fi

    {
        echo "resource \"unifi_user\" \"${args[sanitized_id]}\" {"
        echo "  mac  = \"${args[mac]}\""
        echo "  name = \"${args[escaped_name]}\""
        echo "  # hostname = \"${args[hostname]}\""
        # If blocked is "", then set to false
        [ -z "${args[blocked]}" ] && args[blocked]="false"
        echo "  blocked = ${args[blocked]}"
        [ "${args[noted]}" = "true" ] && [ -n "${args[note]}" ] && echo "  note = \"${args[note]}\""
        if [ "${args[use_fixedip]}" = "true" ]; then
            echo "  fixed_ip   = \"${args[fixed_ip]}\""
            [ -n "${args[network_id]}" ] && echo "  network_id = local.${network_resource_name}.id"
        fi
        [ "${args[local_dns_record_enabled]}" = "true" ] && [ -n "${args[local_dns_record]}" ] && echo "  local_dns_record = \"${args[local_dns_record]}\""
        [ "${args[fingerprint_override]}" = "true" ] && [ -n "${args[dev_id_override]}" ] && echo "  dev_id_override = ${args[dev_id_override]}"
        [ -n "${args[virtual_network_override_id]}" ] && [ "${args[virtual_network_override_enabled]}" = "true" ] && echo "  # virtual_network_override_id = local.${network_override_name}.id"
        echo "  skip_forget_on_destroy = true"
        echo "  allow_existing = true"
        echo "}"
        echo ""
    } >> unifi_users.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "  to = unifi_user.${args[sanitized_id]}"
        echo "  id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_users_import.tf
}

write_local() {
    local -n args=$1

    local user_name="${args[name]}"
    if [ -z "$user_name" ]; then
        user_name="${args[sanitized_id]}"
    else
        user_name="${args[sanitized_name]}"
    fi

    echo "  unifi_user_${user_name} = unifi_user.${args[sanitized_id]}" >> unifi_users_map.tf
}

main() {
    load_network_mappings

    > unifi_users.tf
    > unifi_users_import.tf
    > unifi_users_map.tf

    echo "locals {" > unifi_users_map.tf

    log_console_object_count "$json_file_name"

    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[mac]}")"
        resource_args[sanitized_name]="$(sanitize_for_terraform "${resource_args[name]}")"
        resource_args[escaped_name]="$(escape_quotes "${resource_args[name]}")"

        log_debug "  Writing object: id=${resource_args[_id]} mac=${resource_args[mac]} name=${resource_args[name]}"

        write_resource resource_args
        write_import resource_args
        write_local resource_args
    done < <(read_json "$json_file_name" KEYS)

    echo "}" >> unifi_users_map.tf
}

# Execute the main function
main
