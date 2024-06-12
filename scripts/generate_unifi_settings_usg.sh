# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/settings.json"
readonly KEYS=(
  "_id"
  "arp_cache_base_reachable"
  "arp_cache_timeout"
  "broadcast_ping"
  "dhcp_relay_server_1"
  "dhcp_relay_server_2"
  "dhcp_relay_server_3"
  "dhcp_relay_server_4"
  "dhcp_relay_server_5"
  "firewall_guest_default_log"
  "firewall_lan_default_log"
  "firewall_wan_default_log"
  "ftp_module"
  "geo_ip_filtering_block"
  "geo_ip_filtering_countries"
  "geo_ip_filtering_enabled"
  "geo_ip_filtering_traffic_direction"
  "gre_module"
  "h323_module"
  "icmp_timeout"
  "key"
  "mss_clamp"
  "offload_accounting"
  "offload_l2_blocking"
  "offload_sch"
  "other_timeout"
  "pptp_module"
  "receive_redirects"
  "send_redirects"
  "sip_module"
  "site_id"
  "syn_cookies"
  "tcp_close_timeout"
  "tcp_close_wait_timeout"
  "tcp_established_timeout"
  "tcp_fin_wait_timeout"
  "tcp_last_ack_timeout"
  "tcp_syn_recv_timeout"
  "tcp_syn_sent_timeout"
  "tcp_time_wait_timeout"
  "tftp_module"
  "timeout_setting_preference"
  "udp_other_timeout"
  "udp_stream_timeout"
  "upnp_enabled"
  "upnp_nat_pmp_enabled"
  "upnp_secure_mode"
  "upnp_wan_interface"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_setting_usg\" \"${args[sanitized_id]}\" {"
        echo                                "  site = local.${site_id_to_name[${args[site_id]}]}.name"
        echo ""
        c_echo_dhcp_relay_servers "${args[dhcp_relay_server_1]}" "${args[dhcp_relay_server_2]}" "${args[dhcp_relay_server_3]}" "${args[dhcp_relay_server_4]}" "${args[dhcp_relay_server_5]}"
        c_echo "firewall_guest_default_log" "  firewall_guest_default_log = %s"
        c_echo "firewall_lan_default_log"   "  firewall_lan_default_log   = %s"
        c_echo "firewall_wan_default_log"   "  firewall_wan_default_log   = %s"
        echo "}"
        echo ""
    } >> unifi_settings_usg.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_setting_usg.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_settings_usg_import.tf
}

main() {
    load_site_mappings

    > unifi_settings_usg.tf
    > unifi_settings_usg_import.tf

    # Process each line from read_json
    while IFS='◊' read -ra line_data; do
        declare -A resource_args

        for index in "${!KEYS[@]}"; do
            resource_args["${KEYS[index]}"]="${line_data[index]}"
        done

        # Only process entries where key is 'radius'
        if [ "${resource_args[key]}" = "usg" ]; then
            resource_args[sanitized_id]="id_$(sanitize_for_terraform "${resource_args[_id]}")"

            log_console "Processing settings_usg:    1 object..."
            log_debug "  Writing object: type=settings_usg id=${resource_args[_id]}"

            write_resource resource_args
            write_import resource_args
        fi
    done < <(read_json "$json_file_name" KEYS)

}

# Execute the main function
main
