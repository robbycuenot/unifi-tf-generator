#!/usr/bin/env bash
# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/wlans.json"
readonly KEYS=(
  "_id"
  "ap_group_ids"
  "bss_transition"
  "fast_roaming_enabled"
  "hide_ssid"
  "is_guest"
  "l2_isolation"
  "mac_filter_enabled"
  "mac_filter_list"
  "mac_filter_policy"
  "mcastenhance_enabled"
  "minrate_na_data_rate_kbps"
  "minrate_ng_data_rate_kbps"
  "name"
  "networkconf_id"
  "no2ghz_oui"
  "pmf_mode"
  "proxy_arp"
  "radiusprofile_id"
  "schedule_with_duration"
  "security"
  "site_id"
  "uapsd_enabled"
  "usergroup_id"
  "wlan_band"
  "wpa3_support"
  "wpa3_transition"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_wlan\" \"${args[sanitized_id]}\" {"
        echo "  name = \"${args[name]}\""

        if [ "${site_id_to_name[${args[site_id]}]}" = "unifi_site_Default" ]; then
            echo "  # site = local.${site_id_to_name[${args[site_id]}]}.name"
        else
            echo "  site = local.${site_id_to_name[${args[site_id]}]}.name"
        fi

        echo "  security = \"${args[security]}\""
        echo "  user_group_id = local.${user_group_id_to_name[${args[usergroup_id]}]}.id"
        c_echo "is_guest" "  is_guest = %s"
        echo "  network_id = local.${network_id_to_name[${args[networkconf_id]}]}.id"
        if [ -n "${args[radiusprofile_id]}" ]; then
            echo "  radius_profile_id = local.${radius_profile_id_to_name[${args[radiusprofile_id]}]}.id"
        fi
        echo "  passphrase = var.unifi_wlan_${args[sanitized_name]}_passphrase"
        c_echo_ap_groups "${args[ap_group_ids]}"
        echo ""
        c_echo "bss_transition"       "  bss_transition            = %s"
        c_echo "fast_roaming_enabled" "  fast_roaming_enabled      = %s"
        c_echo "hide_ssid"            "  hide_ssid                 = %s"
        c_echo "l2_isolation"         "  l2_isolation              = %s"
        c_echo "mac_filter_enabled"   "  mac_filter_enabled        = %s"
        c_echo_wlan_security_mac_address "${args[mac_filter_list]}"
        c_echo "mac_filter_policy"    "  mac_filter_policy         = \"%s\""
        c_echo "minrate_ng_data_rate" "  minimum_data_rate_2g_kbps = %s"
        c_echo "minrate_na_data_rate" "  minimum_data_rate_5g_kbps = %s"
        c_echo "mcastenhance_enabled" "  multicast_enhance         = %s"
        c_echo "no2ghz_oui"           "  no2ghz_oui                = %s"
        c_echo "pmf_mode"             "  pmf_mode                  = \"%s\""
        c_echo "proxy_arp"            "  proxy_arp                 = %s"
        c_echo "uapsd_enabled"        "  uapsd                     = %s"
        c_echo "wlan_band"            "  wlan_band                 = \"%s\""
        c_echo "wpa3_support"         "  wpa3_support              = %s"
        c_echo "wpa3_transition"      "  wpa3_transition           = %s"
        c_echo_wlan_schedules "${args[schedule_with_duration]}"
        echo "}"
        echo ""
    } >> unifi_wlans.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_wlan.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_wlans_import.tf
}

write_local() {
    local -n args=$1

    echo "  unifi_wlan_${args[sanitized_name]} = unifi_wlan.${args[sanitized_id]}" >> unifi_wlans_map.tf
}

main() {
    load_site_mappings
    load_user_group_mappings
    load_user_mappings
    load_device_mappings
    load_network_mappings
    load_ap_group_mappings
    load_radius_profile_mappings

    > unifi_wlans.tf
    > unifi_wlans_import.tf
    > unifi_wlans_map.tf

    echo "locals {" > unifi_wlans_map.tf

    log_console_object_count "$json_file_name"

    while IFS='◊' read -ra line_data; do
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
    done < <(read_json "$json_file_name" KEYS)

    echo "}" >> unifi_wlans_map.tf
}

# Execute the main function
main
