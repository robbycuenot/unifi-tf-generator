terraform {
  required_version = ">= 1.6.3"
  cloud {
    organization = "example"

    workspaces {
      name = "unifi-management"
    }
  }

  required_providers {
    unifi = {
      source = "paultyng/unifi"
      version = "0.41.0"
    }
  }
}

provider "unifi" {}