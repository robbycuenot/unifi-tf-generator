declare -A ap_group_id_to_name
declare -A device_id_to_name
declare -A firewall_group_id_to_name
declare -A network_id_to_name
declare -A port_forward_id_to_name
declare -A port_profile_id_to_name
declare -A radius_profile_id_to_name
declare -A site_id_to_name
declare -A user_id_to_name
declare -A user_group_id_to_name

load_ap_group_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_ap_group\.id_(.+) ]]; then
            local ap_group_id="${BASH_REMATCH[1]}"
            ap_group_id_to_name[$ap_group_id]=$key
        fi
    done < unifi_ap_groups_map.tf
}

load_device_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_device\.id_(.+) ]]; then
            local device_id="${BASH_REMATCH[1]}"
            device_id_to_name[$device_id]=$key
        fi
    done < unifi_devices_map.tf
}

load_firewall_group_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_firewall_group\.id_(.+) ]]; then
            local firewall_group_id="${BASH_REMATCH[1]}"
            firewall_group_id_to_name[$firewall_group_id]=$key
        fi
    done < unifi_firewall_groups_map.tf
}

load_network_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_network\.id_(.+) ]]; then
            local network_id="${BASH_REMATCH[1]}"
            network_id_to_name[$network_id]=$key
        fi
    done < unifi_networks_map.tf
}

load_port_forward_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_port_forward\.id_(.+) ]]; then
            local port_forward_id="${BASH_REMATCH[1]}"
            port_forward_id_to_name[$port_forward_id]=$key
        fi
    done < unifi_port_forwards_map.tf
}

load_port_profile_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_port_profile\.id_(.+) ]]; then
            local port_profile_id="${BASH_REMATCH[1]}"
            port_profile_id_to_name[$port_profile_id]=$key
        fi
    done < unifi_port_profiles_map.tf
}

load_radius_profile_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_radius_profile\.id_(.+) ]]; then
            local radius_profile_id="${BASH_REMATCH[1]}"
            radius_profile_id_to_name[$radius_profile_id]=$key
        fi
    done < unifi_radius_profiles_map.tf
}

load_site_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_site\.id_(.+) ]]; then
            local site_id="${BASH_REMATCH[1]}"
            site_id_to_name[$site_id]=$key
        fi
    done < unifi_sites_map.tf
}

load_user_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_user\.id_(.+) ]]; then
            local user_id="${BASH_REMATCH[1]}"
            user_id_to_name[$user_id]=$key
        fi
    done < unifi_users_map.tf
}

load_user_group_mappings() {
    while IFS=' =' read -r key value; do
        if [[ $value =~ unifi_user_group\.id_(.+) ]]; then
            local user_group_id="${BASH_REMATCH[1]}"
            user_group_id_to_name[$user_group_id]=$key
        fi
    done < unifi_user_groups_map.tf
}