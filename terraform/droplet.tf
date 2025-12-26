resource "digitalocean_droplet" "k3s_main" {
    name = "${var.project_name}"
    region = var.region
    size = var.droplet_size
    image = "debian-12-x64"
    ssh_keys = var.ssh_key_ids
    backups = false
    ipv6 = true
    monitoring = true
    tags = [
        var.project_name,
        "k3s",
        "main"
    ]
}