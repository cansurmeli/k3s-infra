output "k3s_main_ip" {
    description = "Public IPv4 of the k3s main"
    value = digitalocean_droplet.k3s_main.ipv4_address
}

output "k3s_main_name" {
    description = "DNS-like name"
    value = digitalocean_droplet.k3s_main.name
}
output "volume_device_hint" {
    description = "Linux device path hint (by-id) for the data volume"
    value = "/dev/disk/by-id/scsi-0DO_Volume_${digitalocean_volume.k3s_data.name}"
}