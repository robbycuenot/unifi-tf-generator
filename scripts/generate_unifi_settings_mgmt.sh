#!/bin/bash

# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/settings.json"
readonly KEYS=(
  "_id"
  "advanced_feature_enabled"
  "auto_upgrade"
  "auto_upgrade_hour"
  "debug_tools_enabled"
  "direct_connect_enabled"
  "key"
  "site_id"
  "unifi_idp_enabled"
  "wifiman_enabled"
  "x_api_token"
  "x_mgmt_key"
  "x_ssh_auth_password_enabled"
  "x_ssh_bind_wildcard"
  "x_ssh_enabled"
  "x_ssh_keys"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_setting_mgmt\" \"${args[sanitized_id]}\" {"
        echo                   "  site         = local.${site_id_to_name[${args[site_id]}]}.name"
        c_echo "auto_upgrade"  "  auto_upgrade = %s"
        c_echo "x_ssh_enabled" "  ssh_enabled  = %s"
        c_echo_ssh_keys "${args[x_ssh_keys]}"
        echo "}"
        echo ""
    } >> unifi_settings_mgmt.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_setting_mgmt.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_settings_mgmt_import.tf
}

main() {
    load_site_mappings

    > unifi_settings_mgmt.tf
    > unifi_settings_mgmt_import.tf

    # Process each line from read_json
    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        # Only process entries where key is 'mgmt'
        if [ "${resource_args[key]}" = "mgmt" ]; then
            resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"

            log_console "Processing settings_mgmt:   1 object..."
            log_debug "  Writing object: type=settings_mgmt id=${resource_args[_id]}"

            write_resource resource_args
            write_import resource_args
        fi
    done < <(read_json "$json_file_name" KEYS)

}

# Execute the main function
main
