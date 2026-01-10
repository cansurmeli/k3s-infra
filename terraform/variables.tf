variable do_token {
    type = string
    sensitive = true
    description = "DigitalOcean API token"
}

variable project_name {
    type = string
    default = "k3s-main"
    description = "Base name for all resources"
}

variable region {
    type = string
    default = "fra1"
    description = "DigitalOcean region"
}
variable droplet_size {
    type = string
    default = "s-2vcpu-4gb"
    description = "DigitalOcean Droplet size"
}

variable "volume_size_gb" {
    type = number
    default = 100
    description = "Size of the block storage volume in GB"
}

variable "ssh_key_fingerprints" {
    type        = list(string)
    description = "DigitalOcean SSH key fingerprints to inject into the droplet"
}

variable "ssh_port" {
    type = number
    default = 53971
    description = "SSH port for accessing the droplets"
}

variable "allowed_ip_cidrs" {
    type = list(string)
    default = ["0.0.0.0/0", "::/0"]
    description = "List of CIDR blocks allowed to access the droplets via SSH"
}
