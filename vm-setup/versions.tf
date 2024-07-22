terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.6"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
