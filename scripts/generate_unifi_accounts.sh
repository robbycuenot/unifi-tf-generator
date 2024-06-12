# Source the utility script
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/accounts.json"
readonly KEYS=(
  "_id"
  "name"
  "tunnel_medium_type"
  "tunnel_type"
)

write_resource() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "resource \"unifi_account\" \"${args[sanitized_id]}\" {"
        c_echo "name"               "  name                = \"%s\""
        echo                        "  password            = var.unifi_account_${args[name]}_password"
        echo ""
        c_echo "tunnel_medium_type" "  tunnel_medium_type  = %s"
        c_echo "tunnel_type"        "  tunnel_type         = %s"
        echo "}"
        echo ""
    } >> unifi_accounts.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_account.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_accounts_import.tf
}

write_local() {
    local -n args=$1

    echo "  unifi_account_${args[sanitized_name]} = unifi_account.${args[sanitized_id]}" >> unifi_accounts_map.tf
}

main() {
    # Clear existing files or create them if they don't exist
    > unifi_accounts.tf
    > unifi_accounts_import.tf
    > unifi_accounts_map.tf

    echo "locals {" > unifi_accounts_map.tf

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

        log_debug "  Writing object: type=account id=${resource_args[_id]} name=${resource_args[name]}"

        # Write the resource blocks
        write_resource resource_args

        # Write the import blocks
        write_import resource_args

        # Write the locals block
        write_local resource_args

    done < <(read_json "$json_file_name" KEYS)

    # Write the footer for the locals block
    echo "}" >> unifi_accounts_map.tf
}

# Execute the main function
main
