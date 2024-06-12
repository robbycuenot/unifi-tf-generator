# Source the utility scripts
source ./scripts/json_utils.sh
source ./scripts/log_utils.sh
source ./scripts/mapping_utils.sh
source ./scripts/terraform_utils.sh

readonly json_file_name="json/networks.json"
readonly KEYS=(
  "_id"                          
  "attr_hidden_id"              
  "attr_no_delete"              
  "auto_scale_enabled"          
  "dhcp_relay_enabled"          
  "dhcpd_boot_enabled"          
  "dhcpd_boot_filename"         
  "dhcpd_boot_server"           
  "dhcpd_dns_1"                 
  "dhcpd_dns_2"                 
  "dhcpd_dns_3"                 
  "dhcpd_dns_4"                 
  "dhcpd_dns_enabled"           
  "dhcpd_enabled"               
  "dhcpd_gateway"               
  "dhcpd_gateway_enabled"       
  "dhcpd_ip_1"                  
  "dhcpd_ip_2"                  
  "dhcpd_ip_3"                  
  "dhcpd_leasetime"             
  "dhcpd_mac_1"                 
  "dhcpd_mac_2"                 
  "dhcpd_mac_3"                 
  "dhcpd_ntp_1"                 
  "dhcpd_ntp_2"                 
  "dhcpd_ntp_enabled"           
  "dhcpd_start"                 
  "dhcpd_stop"                  
  "dhcpd_tftp_server"           
  "dhcpd_time_offset_enabled"   
  "dhcpd_unifi_controller"      
  "dhcpd_wins_1"                
  "dhcpd_wins_2"                
  "dhcpd_wins_enabled"          
  "dhcpd_wpad_url"              
  "dhcpdv6_allow_slaac"         
  "dhcpdv6_dns_1"               
  "dhcpdv6_dns_2"               
  "dhcpdv6_dns_3"               
  "dhcpdv6_dns_4"               
  "dhcpdv6_dns_auto"            
  "dhcpdv6_enabled"             
  "dhcpdv6_leasetime"           
  "dhcpdv6_start"               
  "dhcpdv6_stop"                
  "dhcpguard_enabled"           
  "domain_name"                 
  "dpi_enabled"                 
  "dpigroup_id"                 
  "enabled"                     
  "exposed_to_site_vpn"         
  "gateway_type"                
  "igmp_fastleave"              
  "igmp_proxy_downstream"       
  "igmp_querier"                
  "igmp_snooping"               
  "igmp_supression"             
  "internet_access_enabled"     
  "ip_subnet"                   
  "ipsec_dynamic_routing"       
  "ipsec_pfs"                   
  "ipv6_client_address_assignme"
  "ipv6_interface_type"         
  "ipv6_pd_auto_prefixid_enable"
  "ipv6_pd_interface"           
  "ipv6_pd_prefixid"            
  "ipv6_pd_start"               
  "ipv6_pd_stop"                
  "ipv6_ra_enabled"             
  "ipv6_ra_preferred_lifetime"  
  "ipv6_ra_priority"            
  "ipv6_ra_valid_lifetime"      
  "ipv6_setting_preference"     
  "ipv6_subnet"                 
  "is_nat"                      
  "l2tp_allow_weak_ciphers"     
  "lte_lan_enabled"             
  "mac_override"                
  "mac_override_enabled"        
  "mdns_enabled"                
  "name"                        
  "nat_outbound_ip_addresses"   
  "networkgroup"                
  "pptpc_require_mppe"          
  "purpose"                     
  "radiusprofile_id"            
  "remote_site_id"              
  "report_wan_event"            
  "require_mschapv2"            
  "setting_preference"          
  "site_id"                     
  "upnp_lan_enabled"            
  "usergroup_id"                
  "vlan"                        
  "vlan_enabled"                
  "vpn_client_default_route"    
  "vpn_client_pull_dns"         
  "wan_dhcpv6_pd_size"          
  "wan_dns1"                    
  "wan_dns2"                    
  "wan_dns3"                    
  "wan_dns4"                    
  "wan_egress_qos"              
  "wan_gateway"                 
  "wan_gateway_v6"              
  "wan_ip"                      
  "wan_ipv6"                    
  "wan_netmask"                 
  "wan_networkgroup"            
  "wan_prefixlen"               
  "wan_provider_capabilities"   
  "wan_smartq_enabled"          
  "wan_type"                    
  "wan_type_v6"                 
  "wan_username"                
  "wan_vlan_enabled"            
  "x_wan_password"
)

write_resource() {
    local -n args=$1

    {
        echo "resource \"unifi_network\" \"${args[sanitized_id]}\" {"
        c_echo "name"                   "  name          = \"%s\""
        c_echo "site_resource_name"     "  site          = local.%s.name"
        c_echo "purpose"                "  purpose       = \"%s\""
        c_echo "networkgroup"           "  network_group = \"%s\""
        echo ""
        c_echo "ip_subnet"              "  subnet             = \"%s\""
        c_echo "ipv6_subnet"            "  ipv6_static_subnet = \"%s\""
        c_echo "vlan"                   "  vlan_id            = %s"
        echo ""
        c_echo_dns "dhcpd_dns_1" "dhcpd_dns_2" "dhcpd_dns_3" "dhcpd_dns_4" "dhcp_dns"
        c_echo "dhcpd_enabled"          "  dhcp_enabled               = %s"
        c_echo "dhcpd_leasetime"        "  dhcp_lease                 = %s"
        c_echo "dhcp_relay_enabled"     "  dhcp_relay_enabled         = %s"
        c_echo "dhcpd_start"            "  dhcp_start                 = \"%s\""
        c_echo "dhcpd_stop"             "  dhcp_stop                  = \"%s\""
        c_echo_dns "dhcpdv6_dns_1" "dhcpdv6_dns_2" "dhcpdv6_dns_3" "dhcpdv6_dns_4" "dhcp_v6_dns"
        c_echo "dhcpdv6_dns_auto"           "  dhcp_v6_dns_auto           = %s"
        c_echo "dhcpdv6_enabled"            "  dhcp_v6_enabled            = %s"
        c_echo "dhcpdv6_start"              "  dhcp_v6_start              = \"%s\""
        c_echo "dhcpdv6_stop"               "  dhcp_v6_stop               = \"%s\""
        c_echo "dhcpd_boot_enabled"         "  dhcpd_boot_enabled         = %s"
        c_echo "dhcpd_boot_filename"        "  dhcpd_boot_filename        = \"%s\""
        c_echo "dhcpd_boot_server"          "  dhcpd_boot_server          = \"%s\""
        c_echo "domain_name"                "  domain_name                = \"%s\""
        c_echo "igmp_snooping"              "  igmp_snooping              = %s"
        c_echo "internet_access_enabled"    "  internet_access_enabled    = %s"
        c_echo "ipv6_interface_type"        "  ipv6_interface_type        = \"%s\""
        c_echo "ipv6_pd_interface"          "  ipv6_pd_interface          = \"%s\""
        c_echo "ipv6_pd_prefixid"           "  ipv6_pd_prefixid           = \"%s\""
        c_echo "ipv6_pd_start"              "  ipv6_pd_start              = \"%s\""
        c_echo "ipv6_pd_stop"               "  ipv6_pd_stop               = \"%s\""
        c_echo "ipv6_ra_enabled"            "  ipv6_ra_enable             = %s"
        c_echo "ipv6_ra_preferred_lifetime" "  ipv6_ra_preferred_lifetime = %s"
        c_echo "ipv6_ra_priority"           "  ipv6_ra_priority           = \"%s\""
        c_echo "ipv6_ra_valid_lifetime"     "  ipv6_ra_valid_lifetime     = %s"
        c_echo "mdns_enabled"               "  multicast_dns              = %s"
        c_echo "wan_dhcpv6_pd_size"         "  wan_dhcp_v6_pd_size        = %s"
        c_echo_dns "wan_dns1" "wan_dns2" "wan_dns3" "wan_dns4" "wan_dns"
        c_echo "wan_egress_qos"         "  wan_egress_qos             = %s"
        c_echo "wan_gateway"            "  wan_gateway                = \"%s\""
        c_echo "wan_gateway_v6"         "  wan_gateway_v6             = \"%s\""
        c_echo "wan_ip"                 "  wan_ip                     = \"%s\""
        c_echo "wan_ipv6"               "  wan_ipv6                   = \"%s\""
        c_echo "wan_netmask"            "  wan_netmask                = \"%s\""
        c_echo "wan_networkgroup"       "  wan_networkgroup           = \"%s\""
        c_echo "wan_prefixlen"          "  wan_prefixlen              = %s"
        c_echo "wan_type"               "  wan_type                   = \"%s\""
        c_echo "wan_type_v6"            "  wan_type_v6                = \"%s\""
        c_echo "wan_username"           "  wan_username               = \"%s\""
        c_echo "x_wan_password"         "  x_wan_password             = var.unifi_network_${args[sanitized_name]}_x_wan_password"
        echo ""
        echo "  lifecycle {"
        echo "    prevent_destroy = true"
        echo "  }"
        echo "}"
        echo ""
    } >> unifi_networks.tf
}

write_import() {
    local -n args=$1

    {
        echo "import {"
        echo "    to = unifi_network.${args[sanitized_id]}"
        echo "    id = \"${args[_id]}\""
        echo "}"
        echo ""
    } >> unifi_networks_import.tf
}

write_local() {
    local -n args=$1

    echo "  unifi_network_${args[sanitized_name]} = unifi_network.${args[sanitized_id]}" >> unifi_networks_map.tf
}

main() {
    # Load the site mappings
    load_site_mappings

    # Clear existing files or create them if they don't exist
    > unifi_networks.tf
    > unifi_networks_import.tf
    > unifi_networks_map.tf

    echo "locals {" > unifi_networks_map.tf

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
      resource_args[site_resource_name]="${site_id_to_name[${resource_args[site_id]}]}"

      log_debug "  Writing object: id=${resource_args[_id]} name=${resource_args[name]}"

      # Write the resource blocks
      write_resource resource_args

      # Write the import blocks
      write_import resource_args

      # Write the locals block
      write_local resource_args
        
    done < <(read_json "$json_file_name" KEYS)

    # Close the locals block
    echo "}" >> unifi_networks_map.tf
}

# Execute the main function
main
