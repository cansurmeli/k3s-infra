#!/usr/bin/env bash
set -euo pipefail

missing=()
for name in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY TF_STATE_BUCKET; do
    if [ -z "${!name:-}" ]; then
        missing+=("${name}")
    fi
done

if [ "${#missing[@]}" -gt 0 ]; then
    echo "Missing required Terraform backend environment values: ${missing[*]}"
    echo "Set TF_STATE_BUCKET, DO_SPACES_ACCESS_KEY_ID, and DO_SPACES_SECRET_ACCESS_KEY in the GitHub prod environment."
    exit 1
fi

TF_STATE_REGION="${TF_STATE_REGION:-fra1}"
TF_STATE_KEY="${TF_STATE_KEY:-k3s-infra/prod/terraform.tfstate}"

cat > backend.hcl <<EOF
bucket = "${TF_STATE_BUCKET}"
key = "${TF_STATE_KEY}"
region = "${TF_STATE_REGION}"
endpoints = {
  s3 = "https://${TF_STATE_REGION}.digitaloceanspaces.com"
}
skip_credentials_validation = true
skip_requesting_account_id = true
skip_metadata_api_check = true
skip_region_validation = true
skip_s3_checksum = true
EOF

terraform init -backend-config=backend.hcl
