resource "unifi_network" "default" {
  name          = "Default"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.0.1/24"

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.0.100"
  dhcp_stop                  = "10.0.0.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "default.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = true
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "management" {
  name          = "Management"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.16.1/24"
  vlan_id            = 16

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.16.100"
  dhcp_stop                  = "10.0.16.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "management.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "storage" {
  name          = "Storage"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.32.1/24"
  vlan_id            = 32

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.32.100"
  dhcp_stop                  = "10.0.32.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "storage.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "ci_cd" {
  name          = "CI/CD"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.48.1/24"
  vlan_id            = 48

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.48.100"
  dhcp_stop                  = "10.0.48.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "ci-cd.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "lab_prod" {
  name          = "Lab Prod"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.64.1/24"
  vlan_id            = 64

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.64.100"
  dhcp_stop                  = "10.0.64.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "lab-prod.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "lab_dev" {
  name          = "Lab Dev"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.80.1/24"
  vlan_id            = 80

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.80.100"
  dhcp_stop                  = "10.0.80.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "lab-dev.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "lab_sandbox" {
  name          = "Lab Sandbox"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.96.1/24"
  vlan_id            = 96

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.96.100"
  dhcp_stop                  = "10.0.96.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "lab-sandbox.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "personal" {
  name          = "Personal"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.112.1/24"
  vlan_id            = 112

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.112.100"
  dhcp_stop                  = "10.0.112.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "personal.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "vpn" {
  name          = "VPN"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.128.1/24"
  vlan_id            = 128

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.128.100"
  dhcp_stop                  = "10.0.128.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "vpn.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "printers" {
  name          = "Printers"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.144.1/24"
  vlan_id            = 144

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.144.100"
  dhcp_stop                  = "10.0.144.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "printers.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "iot" {
  name          = "IoT"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.160.1/24"
  vlan_id            = 160

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.160.100"
  dhcp_stop                  = "10.0.160.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "iot.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "guest" {
  name          = "Guest"
  site          = local.unifi_site_Default.name
  purpose       = "guest"
  network_group = "LAN"

  subnet             = "10.0.176.1/24"
  vlan_id            = 176

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.176.100"
  dhcp_stop                  = "10.0.176.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "guest.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "aws" {
  name          = "AWS"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.192.1/24"
  vlan_id            = 192

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.192.100"
  dhcp_stop                  = "10.0.192.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "aws.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "azure" {
  name          = "Azure"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.208.1/24"
  vlan_id            = 208

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.208.100"
  dhcp_stop                  = "10.0.208.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "azure.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "unifi_network" "google_cloud" {
  name          = "Google Cloud"
  site          = local.unifi_site_Default.name
  purpose       = "corporate"
  network_group = "LAN"

  subnet             = "10.0.224.1/24"
  vlan_id            = 224

  dhcp_enabled               = true
  dhcp_lease                 = 86400
  dhcp_relay_enabled         = false
  dhcp_start                 = "10.0.224.100"
  dhcp_stop                  = "10.0.224.254"
  dhcp_v6_dns_auto           = true
  dhcpd_boot_enabled         = false
  domain_name                = "google-cloud.lan"
  igmp_snooping              = false
  internet_access_enabled    = true
  ipv6_interface_type        = "none"
  ipv6_ra_enable             = false
  ipv6_ra_preferred_lifetime = 14400
  ipv6_ra_valid_lifetime     = 86400
  multicast_dns              = true

  lifecycle {
    prevent_destroy = true
  }
}

