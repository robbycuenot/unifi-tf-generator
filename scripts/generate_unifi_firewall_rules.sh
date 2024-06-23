#!/usr/bin/env bash
# Source the utility script
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/firewall_rules.json"
readonly KEYS=(
  "_id"
  "action"
  "dst_address"
  "dst_address_ipv6"
  "dst_firewallgroup_ids"
  "dst_networkconf_id"
  "dst_networkconf_type"
  "dst_port"
  "enabled"
  "icmp_typename"
  "icmp_v6_typename"
  "ipsec"
  "logging"
  "name"
  "protocol"
  "protocol_v6"
  "protocol_match_excepted"
  "rule_index"
  "ruleset"
  "setting_preference"
  "site_id"
  "src_address"
  "src_address_ipv6"
  "src_firewallgroup_ids"
  "src_mac_address"
  "src_networkconf_id"
  "src_networkconf_type"
  "src_port"
  "state_established"
  "state_invalid"
  "state_new"
  "state_related"
)

write_resource() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "resource \"unifi_firewall_rule\" \"${args[sanitized_id]}\" {"

        c_echo "name"       "  name    = \"%s\""
        echo                "  site    = local.unifi_site_Default.name"
        c_echo "enabled"    "  enabled = %s"
        echo ""
        c_echo "action"     "  action     = \"%s\""
        c_echo "rule_index" "  rule_index = %s"
        c_echo "ruleset"    "  ruleset    = \"%s\""
        echo ""
        c_echo "dst_address"          "  dst_address       = \"%s\""
        c_echo "dst_address_ipv6"     "  dst_address_ipv6  = \"%s\""
        c_echo_firewall_groups "${args[dst_firewallgroup_ids]}" "dst"
        c_echo "dst_network_resource" "  dst_network_id    = %s"
        c_echo "dst_networkconf_type" "  dst_network_type  = \"%s\""
        c_echo "dst_port"             "  dst_port          = \"%s\""
        c_echo "icmp_typename"        "  icmp_typename     = \"%s\""
        c_echo "icmp_v6_typename"     "  icmp_v6_typename  = \"%s\""
        c_echo "ipsec"                "  ip_sec            = \"%s\""
        c_echo "logging"              "  logging           = %s"
        c_echo "protocol"             "  protocol          = \"%s\""
        c_echo "protocol_v6"          "  protocol_v6       = \"%s\""
        c_echo "src_address"          "  src_address       = \"%s\""
        c_echo "src_address_ipv6"     "  src_address_ipv6  = \"%s\""
        c_echo_firewall_groups "${args[src_firewallgroup_ids]}" "src"
        c_echo_firewall_rule_src_mac_address "${args[src_mac_address]}"
        c_echo "src_network_resource" "  src_network_id    = %s"
        c_echo "src_networkconf_type" "  src_network_type  = \"%s\""
        c_echo "src_port"             "  src_port          = \"%s\""
        c_echo "state_established"    "  state_established = %s"
        c_echo "state_invalid"        "  state_invalid     = %s"
        c_echo "state_new"            "  state_new         = %s"
        c_echo "state_related"        "  state_related     = %s"
        echo "}"
        echo ""
    } >> unifi_firewall_rules.tf
}

write_import() {
    local -n args=$1  # Use a nameref to refer to the associative array

    {
        echo "import {"
        echo "    to = unifi_firewall_rule.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_firewall_rules_import.tf
}

write_local() {
    local -n args=$1  # Use a nameref to refer to the associative array

    echo "  unifi_firewall_rule_${args[sanitized_name]} = unifi_firewall_rule.${args[sanitized_id]}" >> unifi_firewall_rules_map.tf
}

main() {
    # Load the mappings
    load_device_mappings
    load_firewall_group_mappings
    load_network_mappings
    load_user_mappings

    # Clear existing files or create them if they don't exist
    > unifi_firewall_rules.tf
    > unifi_firewall_rules_import.tf
    > unifi_firewall_rules_map.tf

    # Initialize unifi_firewall_rules_map.tf with the header
    echo "locals {" > unifi_firewall_rules_map.tf

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
        if [ -n "${resource_args[dst_networkconf_id]}" ]; then
            resource_args[dst_network_resource]="local.${network_id_to_name[${resource_args[dst_networkconf_id]}]}.id"
        else
            resource_args[dst_network_resource]=""
        fi

        if [ -n "${resource_args[src_networkconf_id]}" ]; then
            resource_args[src_network_resource]="local.${network_id_to_name[${resource_args[src_networkconf_id]}]}.id"
        else
            resource_args[src_network_resource]=""
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
    echo "}" >> unifi_firewall_rules_map.tf
}

# Execute the main function
main
