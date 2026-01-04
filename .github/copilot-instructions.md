# AI Coding Agent Instructions for k3s-infra

## Project Overview
This repository manages infrastructure as code for a single-node k3s (lightweight Kubernetes) cluster on DigitalOcean. It uses Terraform for provisioning cloud resources and Ansible for server configuration.

## Architecture
- **Terraform** (`terraform/`): Provisions DigitalOcean droplet, persistent block storage volume, and firewall rules
- **Ansible** (`ansible/`): Configures the server with storage setup, user management, and k3s installation
- **CI/CD** (`.github/workflows/`): Automated planning on PRs and deployment on main branch pushes

## Key Components
- Single DigitalOcean droplet (`s-2vcpu-4gb`) running Debian 12
- 100GB persistent volume for k3s data (`/srv/k3s-data`)
- Custom SSH port (53971) with restricted access
- Admin user "can" with passwordless sudo
- k3s v1.29.3+k3s1 installed to `/usr/local/bin`

## Development Workflows

### Local Terraform Development
```bash
cd terraform
terraform init
terraform plan -var-file=envs/prod.tfvars
terraform apply -var-file=envs/prod.tfvars
```

### Local Ansible Configuration
1. Update `ansible/inventories/prod/hosts.ini` with droplet IP from Terraform outputs
2. Run playbook:
```bash
cd ansible
ansible-playbook -i inventories/prod/hosts.ini site.yaml
```

### Inventory Format
```
[k3s_main]
k3s-main-01 ansible_host=<DROPLET_IP> ansible_user=root
```

## Project Conventions

### Resource Naming
- All DigitalOcean resources prefixed with `project_name` variable (default: "k3s-main")
- Tags: `[project_name, "k3s", "main"]` for droplet, `[project_name, "k3s-data"]` for volume

### Storage Setup
- Volume device path: `/dev/disk/by-id/scsi-0DO_Volume_{project_name}-data`
- Mount point: `/srv/k3s-data`
- K3s data directory: `/srv/k3s-data/k3s`

### Security
- SSH access restricted to `allowed_ip_cidrs` (default: 0.0.0.0/0 for development)
- HTTP/HTTPS open to world
- Admin user created with sudo privileges, no password required

### Ansible Roles
- `storage`: Partition, format, and mount persistent volume
- `user`: Create admin user with sudo access
- Additional roles (`ssh_hardening`, `firewall`, `k3s`, `validation`) referenced but not implemented

## CI/CD Integration
- **Plan**: Runs on PRs affecting terraform/ - validates, formats, and plans changes
- **Deploy**: On main pushes - applies Terraform, generates Ansible inventory, runs playbook
- Uses secrets: `DO_TOKEN`, `SSH_PRIVATE_KEY`, `ANSIBLE_VAULT_PASSWORD`

## Key Files
- `terraform/variables.tf`: All configurable parameters
- `ansible/group_vars/prod.yaml`: Ansible variables for production
- `ansible/site.yaml`: Main playbook applying all roles
- `.github/workflows/deploy.yaml`: Full deployment pipeline

## Dependencies
- Terraform >=1.7.0
- DigitalOcean provider ~2.40
- Ansible (for configuration)
- k3s v1.29.3+k3s1

When modifying infrastructure, always test locally first, then create PRs to trigger plan checks before merging to main for deployment.</content>
<parameter name="filePath">/Users/can/Documents/github/k3s-infra/.github/copilot-instructions.md