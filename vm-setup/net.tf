resource "libvirt_network" "lab" {
    name = "lab"
    mode = "nat"
    domain = "lab.local"
    addresses = ["10.0.0.0/8"]
}
