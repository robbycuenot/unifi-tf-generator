# Network Reference Architecture

## Overview

This document outlines the VLAN configuration for the network, detailing each VLAN's purpose, associated CIDR, and category. Terraform code for deploying this infrastructure can be found at [reference/unifi_networks.tf](reference/unifi_networks.tf)

## VLAN Configuration

Below is the table of VLANs, showing their designated current CIDRs, maximum expandable CIDRs, and the number of usable IPs for each.

| VLAN | VLAN Name    | CIDR          | Max CIDR      | Category           | Usable IPs | Max Usable IPs |
|------|--------------|---------------|---------------|--------------------|------------|----------------|
| 1    | Default      | 10.0.0.1/24   | 10.0.0.1/20   | High Security      | 254        | 4094           |
| 16   | Management   | 10.0.16.1/24  | 10.0.16.1/20  | High Security      | 254        | 4094           |
| 32   | Storage      | 10.0.32.1/24  | 10.0.32.1/20  | High Security      | 254        | 4094           |
| 48   | CI/CD        | 10.0.48.1/24  | 10.0.48.1/20  | High Security      | 254        | 4094           |
| 64   | Lab Prod     | 10.0.64.1/24  | 10.0.64.1/20  | Lab Environments   | 254        | 4094           |
| 80   | Lab Dev      | 10.0.80.1/24  | 10.0.80.1/20  | Lab Environments   | 254        | 4094           |
| 96   | Lab Sandbox  | 10.0.96.1/24  | 10.0.96.1/20  | Lab Environments   | 254        | 4094           |
| 112  | Personal     | 10.0.112.1/24 | 10.0.112.1/20 | Low Security       | 254        | 4094           |
| 128  | VPN          | 10.0.128.1/24 | 10.0.128.1/20 | Low Security       | 254        | 4094           |
| 144  | Printers     | 10.0.144.1/24 | 10.0.144.1/20 | Low Security       | 254        | 4094           |
| 160  | IoT          | 10.0.160.1/24 | 10.0.160.1/20 | Low Security       | 254        | 4094           |
| 176  | Guest        | 10.0.176.1/24 | 10.0.176.1/20 | Low Security       | 254        | 4094           |
| 192  | AWS          | 10.0.192.1/24 | 10.0.192.1/20 | Cloud Environments | 254        | 4094           |
| 208  | Azure        | 10.0.208.1/24 | 10.0.208.1/20 | Cloud Environments | 254        | 4094           |
| 224  | Google Cloud | 10.0.224.1/24 | 10.0.224.1/20 | Cloud Environments | 254        | 4094           |
|      | Reserved     |               | 10.0.240.1/20 | Reserved           |            | 4094           |

### Key Points:
- **Current CIDR:** The subnet currently in use for each VLAN.
- **Maximum CIDR:** The largest subnet space reserved for potential expansion of the corresponding VLAN.
- **Category:** The type of environment or use case for each VLAN.
- **Usable IPs:** The number of usable IP addresses in the current and maximum allocations.

## Conclusion

This VLAN configuration is structured to provide a clear, logical, and secure network environment, catering to various requirements from high security to cloud integrations. It's designed for scalability and efficient management, ensuring that network resources are optimally utilized and future expansions can be accommodated.
