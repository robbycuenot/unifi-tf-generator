#!/usr/bin/env bash
# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/settings.json"
readonly KEYS=(
  "_id"
  "accounting_enabled"
  "acct_port"
  "auth_port"
  "ca_certificate"
  "configure_whole_network"
  "dh_key"
  "enabled"
  "interim_update_interval"
  "key"
  "server_certificate"
  "server_certificate_key"
  "site_id"
  "tunneled_reply"
  "x_secret"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_setting_radius\" \"${args[sanitized_id]}\" {"
        echo                   "  site         = local.${site_id_to_name[${args[site_id]}]}.name"
        c_echo "enabled"       "  enabled      = %s"
        echo ""
        c_echo "accounting_enabled"      "  accounting_enabled      = %s"
        c_echo "acct_port"               "  accounting_port         = %s"
        c_echo "auth_port"               "  auth_port               = %s"
        c_echo "interim_update_interval" "  interim_update_interval = %s"
        echo                             "  secret                  = var.unifi_setting_radius_${args[sanitized_id]}_secret"
        c_echo "tunneled_reply"          "  tunneled_reply          = %s"
        echo "}"
        echo ""
    } >> unifi_settings_radius.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_setting_radius.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_settings_radius_import.tf
}

main() {
    load_site_mappings

    > unifi_settings_radius.tf
    > unifi_settings_radius_import.tf

    # Process each line from read_json
    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        # Only process entries where key is 'radius'
        if [ "${resource_args[key]}" = "radius" ]; then
            resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"

            log_console "Processing settings_radius: 1 object..."
            log_debug "  Writing object: type=settings_radius id=${resource_args[_id]}"

            write_resource resource_args
            write_import resource_args
        fi
    done < <(read_json "$json_file_name" KEYS)

}

# Execute the main function
main
