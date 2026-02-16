resource "digitalocean_firewall" "k3s_main_fw" {
    name = "${var.project_name}-fw-${digitalocean_droplet.k3s_main.id}"

    droplet_ids = [
        digitalocean_droplet.k3s_main.id
    ]
    inbound_rule {
        protocol = "tcp"
        port_range = "22"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }

    inbound_rule {
        protocol         = "tcp"
        port_range       = "80"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }

    inbound_rule {
        protocol         = "tcp"
        port_range       = "443"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol              = "tcp"
        port_range            = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol              = "udp"
        port_range            = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
}