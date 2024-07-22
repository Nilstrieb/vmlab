locals {
  cloudinit_user_data = file("${path.module}/user-data")
}

resource "libvirt_cloudinit_disk" "user_data" {
  name      = "commoninit.iso"
  user_data = local.cloudinit_user_data
}

resource "local_file" "debian-node-disk" {
  count = local.vm_count

  content = ""
  filename = "${path.module}/state/debian-node-${count.index}.qcow2.stamp"

  provisioner "local-exec" {
    command = <<EOT
        cp "${path.module}/tmp/debian-12-generic-amd64-bigger.qcow2" "${path.module}/state/debian-node-${count.index}.qcow2"
        chmod 777 "${path.module}/state/debian-node-${count.index}.qcow2"
    EOT
  }
}

resource "libvirt_domain" "debian-node" {
    count = local.vm_count
    name = "debian-node-${count.index}"

    memory = "2048"
    vcpu = 2

    cloudinit = libvirt_cloudinit_disk.user_data.id

    network_interface {
        network_id = libvirt_network.lab.id
        hostname = "debian-node-${count.index}"
        addresses = ["10.0.1.${count.index+1}"]
    }

    disk {
        file = "${abspath(path.module)}/state/debian-node-${count.index}.qcow2"
    }
}
