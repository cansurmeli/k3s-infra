output "k3s_main_ip" {
    description = "Public IPv4 of the k3s main"
    value = digitalocean_droplet.k3s_main.ipv4_address
}

output "k3s_main_id" {
    description = "DigitalOcean Droplet ID of the k3s main"
    value = digitalocean_droplet.k3s_main.id
}

output "k3s_main_name" {
    description = "DNS-like name"
    value = digitalocean_droplet.k3s_main.name
}

output "volume_id" {
    description = "DigitalOcean Volume ID for k3s data"
    value = digitalocean_volume.k3s_data.id
}

output "volume_region" {
    description = "DigitalOcean region for the k3s data volume"
    value = digitalocean_volume.k3s_data.region
}

output "volume_device_hint" {
    description = "Linux device path hint (by-id) for the data volume"
    value = "/dev/disk/by-id/scsi-0DO_Volume_${digitalocean_volume.k3s_data.name}"
}
