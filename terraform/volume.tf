resource "digitalocean_volume" "k3s_data" {
    name = "${var.project_name}-data-01"
    region = var.region
    size = var.volume_size_gb

    description = "Persistent data volume for k3s main node"
    tags = [var.project_name, "k3s-data"]
}

resource "digitalocean_volume_attachment" "k3s_data_attach" {
    droplet_id = digitalocean_droplet.k3s_main.id
    volume_id  = digitalocean_volume.k3s_data.id
}