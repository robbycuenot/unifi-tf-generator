escape_quotes() {
    local string="$1"
    echo "${string//\"/\\\"}"
}

sanitize_for_terraform() {
    local original_name="$1"
    local sanitized_name=$(echo "$original_name" | sed 's/[^a-zA-Z0-9_-]/_/g')
    echo "$sanitized_name"
}

# Helper function to conditionally echo a line
c_echo() {
    local key="$1"
    local format="${2:-"%s"}"
    if [ -n "${args[$key]}" ]; then
        printf "$format\n" "${args[$key]}"
    fi
}

# Helper function to conditionally echo ap groups
c_echo_ap_groups() {
    local ap_group_ids="$1"

    echo "  ap_group_ids = ["

    IFS=',' read -ra AP_GROUP_IDS <<< "$ap_group_ids"
    for ap_group_id in "${AP_GROUP_IDS[@]}"; do
        echo "    local.${ap_group_id_to_name[$ap_group_id]}.id,"
    done

    echo "  ]"
}

# Helper function to conditionally echo auth servers
c_echo_auth_servers() {
    local auth_servers="$1"
    local sanitized_name="$2"

    IFS=',' read -ra SERVERS <<< "$auth_servers"
    for server in "${SERVERS[@]}"; do
        IFS=':' read -ra DETAILS <<< "$server"
        echo ""
        echo "  auth_server {"
        echo "    ip = \"${DETAILS[0]}\""
        echo "    port = ${DETAILS[1]}"
        echo "    xsecret = var.unifi_radius_profile_${sanitized_name}_x_secret"
        echo "  }"
    done
}

# Helper function to conditionally echo DHCP relay servers
c_echo_dhcp_relay_servers() {
    local dhcp_relay_server_1="$1"
    local dhcp_relay_server_2="$2"
    local dhcp_relay_server_3="$3"
    local dhcp_relay_server_4="$4"
    local dhcp_relay_server_5="$5"

    local servers=("$dhcp_relay_server_1" "$dhcp_relay_server_2" "$dhcp_relay_server_3" "$dhcp_relay_server_4" "$dhcp_relay_server_5")
    local output=""

    for server in "${servers[@]}"; do
        if [ -n "$server" ]; then
            output+="\n    \"$server\","
        fi
    done

    if [ -n "$output" ]; then
        echo -n "  dhcp_relay_servers = ["
        echo -e "$output"
        echo "  ]"
    fi
}

# Helper function to conditionally echo DNS values
c_echo_dns() {
    local dns_keys=("$1" "$2" "$3" "$4")
    local dns_values=()
    local dns_name=$5
    for key in "${dns_keys[@]}"; do
        [ -n "${args[$key]}" ] && dns_values+=("${args[$key]}")
    done

    if [ ${#dns_values[@]} -gt 0 ]; then
        echo "  $dns_name = ["
        for dns in "${dns_values[@]}"; do
            echo "    \"$dns\","
        done
        echo "  ]"
    fi
}

# Helper function to conditionally echo firewall group members
c_echo_firewall_group_members() {
    local members="$1"

    echo "  members = ["

    # Split the members and store them in an array
    IFS=',' read -ra MEMBERS <<< "$members"

    # Iterate over the sorted array and print each entry
    for member in "${MEMBERS[@]}"; do
        echo "    \"$member\","
    done

    echo "  ]"
}

# Helper function to conditionally echo firewall groups
c_echo_firewall_groups() {
    local firewall_group_ids="$1"
    local src_or_dst="$2"

    if [ -z "$firewall_group_ids" ]; then
        return
    fi

    echo "  ${src_or_dst}_firewall_group_ids = ["

    IFS=',' read -ra FIREWALL_GROUP_IDS <<< "$firewall_group_ids"
    for firewall_group_id in "${FIREWALL_GROUP_IDS[@]}"; do
        echo "    local.${firewall_group_id_to_name[$firewall_group_id]}.id,"
    done

    echo "  ]"
}

c_echo_firewall_rule_src_mac_address() {
    local mac_address="$1"

    if [ -z "$mac_address" ]; then
        return
    fi


    local resource_id="${mac_address//:/_}"
    # check to see if the resource_id is in the device_id_to_name array
    if [ -n "${device_id_to_name[$resource_id]}" ]; then
        resource_name=("local.${device_id_to_name[$resource_id]}.mac")
    elif [ -n "${user_id_to_name[$resource_id]}" ]; then
        resource_name=("local.${user_id_to_name[$resource_id]}.mac")
    else
        resource_name=("\"$mac_address\"")
    fi

    echo "  src_mac           = $resource_name"
}

c_echo_macs() {
    local device_macs="$1"

    echo "  # device_macs            = ["

    # Split the MAC addresses and store them in an array
    IFS=',' read -ra MACS <<< "$device_macs"

    # Create an array to hold the device resource names
    local device_resource_names=()

    # Populate the device_resource_names array
    for mac in "${MACS[@]}"; do
        local device_id="${mac//:/_}"
        device_resource_names+=("local.${device_id_to_name[$device_id]}.mac")
    done

    # Sort the array alphabetically and case-insensitively
    IFS=$'\n' sorted_device_resource_names=($(sort -f <<< "${device_resource_names[*]}"))
    unset IFS

    # Iterate over the sorted array and print each entry
    for device_resource_name in "${sorted_device_resource_names[@]}"; do
        echo "  #   $device_resource_name,"
    done

    echo "  # ]"
}

# Helper function to conditionally echo port override values
c_echo_port_overrides() {
    local port_table_json="$1"

    echo "$port_table_json" | jq -c '.[]' | while read -r port; do
        local op_mode=$(echo "$port" | jq -r '.op_mode // empty')
        local portconf_id=$(echo "$port" | jq -r '.portconf_id // empty')
        if [ -n "$op_mode" ] || [ -n "$portconf_id" ]; then
            local port_idx=$(echo "$port" | jq -r '.port_idx')
            local port_name=$(echo "$port" | jq -r '.name // empty')
            local aggregate_num_ports=$(echo "$port" | jq -r '.aggregate_num_ports // empty')

            echo "  port_override {"
            [ -n "$port_name" ] && echo "    name            = \"$port_name\""
            echo "    number          = $port_idx"
            [ -n "$portconf_id" ] && echo "    port_profile_id = local.${port_profile_id_to_name[$portconf_id]}.id"
            [ -n "$op_mode" ] && echo "    op_mode         = \"$op_mode\""
            [ -n "$aggregate_num_ports" ] && echo "    aggregate_num_ports = $aggregate_num_ports"
            echo "  }"
            echo ""
        fi
    done
}

c_echo_port_security_mac_address() {
    local mac_addresses="$1"

    if [ -z "$mac_addresses" ]; then
        return
    fi

    echo "  port_security_mac_address = ["

    # Split the MAC addresses and store them in an array
    IFS=',' read -ra MACS <<< "$mac_addresses"

    # Create an array to hold the resource names, or macs if no resource name is available
    local resource_names=()

    # Populate the resource_names array
    for mac in "${MACS[@]}"; do
        local resource_id="${mac//:/_}"
        # check to see if the resource_id is in the device_id_to_name array
        if [ -n "${device_id_to_name[$resource_id]}" ]; then
            resource_names+=("local.${device_id_to_name[$resource_id]}.mac")
        elif [ -n "${user_id_to_name[$resource_id]}" ]; then
            resource_names+=("local.${user_id_to_name[$resource_id]}.mac")
        else
            resource_names+=("\"$mac\"")
        fi
    done

    # Sort the array alphabetically and case-insensitively
    IFS=$'\n' sorted_resource_names=($(sort -f <<< "${resource_names[*]}"))
    unset IFS

    # Iterate over the sorted array and print each entry
    for resource_name in "${sorted_resource_names[@]}"; do
        echo "    $resource_name,"
    done

    echo "  ]"
}

c_echo_ssh_keys() {
    local ssh_keys_json="$1"

    # Get the length of the JSON array
    local length=$(echo "$ssh_keys_json" | jq '. | length')

    # Iterate over each object in the JSON array
    for ((i=0;i<$length;i++)); do
        local ssh_key=$(echo "$ssh_keys_json" | jq ".[$i]")

        echo ""
        echo "  ssh_key {"
        echo "    name    = \"$(echo "$ssh_key" | jq -r '.name')\""
        echo "    comment = \"$(echo "$ssh_key" | jq -r '.comment')\""
        echo "    type    = \"$(echo "$ssh_key" | jq -r '.type')\""
        echo "    key     = \"$(echo "$ssh_key" | jq -r '.key')\""
        echo "  }"
    done
}

c_echo_wlan_security_mac_address() {
    local mac_addresses="$1"

    if [ -z "$mac_addresses" ]; then
        return
    fi

    echo "  mac_filter_list = ["

    # Split the MAC addresses and store them in an array
    IFS=',' read -ra MACS <<< "$mac_addresses"

    # Create an array to hold the resource names, or macs if no resource name is available
    local resource_names=()

    # Populate the resource_names array
    for mac in "${MACS[@]}"; do
        local resource_id="${mac//:/_}"
        # check to see if the resource_id is in the device_id_to_name array
        if [ -n "${device_id_to_name[$resource_id]}" ]; then
            resource_names+=("local.${device_id_to_name[$resource_id]}.mac")
        elif [ -n "${user_id_to_name[$resource_id]}" ]; then
            resource_names+=("local.${user_id_to_name[$resource_id]}.mac")
        else
            resource_names+=("\"$mac\"")
        fi
    done

    # Sort the array alphabetically and case-insensitively
    IFS=$'\n' sorted_resource_names=($(sort -f <<< "${resource_names[*]}"))
    unset IFS

    # Iterate over the sorted array and print each entry
    for resource_name in "${sorted_resource_names[@]}"; do
        echo "    $resource_name,"
    done

    echo "  ]"
}

# Helper function to conditionally echo wlan schedules
c_echo_wlan_schedules() {
    local wlan_schedules_json="$1"

    echo "$wlan_schedules_json" | jq -c '.[]' | while read -r schedule; do
        local duration_minutes=$(echo "$schedule" | jq -r '.duration_minutes // empty')
        local name=$(echo "$schedule" | jq -r '.name // empty')
        local start_days_of_week=$(echo "$schedule" | jq -r '.start_days_of_week[] // empty')
        local start_hour=$(echo "$schedule" | jq -r '.start_hour // empty')
        local start_minute=$(echo "$schedule" | jq -r '.start_minute // empty')

        for day in $start_days_of_week; do
            if [ -n "$duration_minutes" ] || [ -n "$name" ] || [ -n "$day" ] || [ -n "$start_hour" ] || [ -n "$start_minute" ]; then
                echo ""
                echo "  schedule {"
                [ -n "$duration_minutes" ] && echo "    duration = $duration_minutes"
                [ -n "$name" ] && echo             "    name = \"$name\""
                [ -n "$day" ] && echo              "    day_of_week = \"$day\""
                [ -n "$start_hour" ] && echo       "    start_hour = $start_hour"
                [ -n "$start_minute" ] && echo     "    start_minute = $start_minute"
                echo "  }"
            fi
        done
    done
}