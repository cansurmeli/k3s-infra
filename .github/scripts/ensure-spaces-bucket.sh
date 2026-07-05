#!/usr/bin/env bash
set -euo pipefail

missing=()
for name in DO_SPACES_ACCESS_KEY_ID DO_SPACES_SECRET_ACCESS_KEY TF_STATE_BUCKET; do
    if [ -z "${!name:-}" ]; then
        missing+=("${name}")
    fi
done

if [ "${#missing[@]}" -gt 0 ]; then
    echo "Missing required DigitalOcean Spaces values: ${missing[*]}"
    echo "Set TF_STATE_BUCKET, DO_SPACES_ACCESS_KEY_ID, and DO_SPACES_SECRET_ACCESS_KEY in the GitHub prod environment."
    exit 1
fi

TF_STATE_REGION="${TF_STATE_REGION:-fra1}"
SPACES_ENDPOINT="https://${TF_STATE_REGION}.digitaloceanspaces.com"

export AWS_ACCESS_KEY_ID="${DO_SPACES_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${DO_SPACES_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${TF_STATE_REGION}"

if ! command -v aws >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y awscli
fi

if aws --endpoint-url "${SPACES_ENDPOINT}" s3api head-bucket --bucket "${TF_STATE_BUCKET}" >/dev/null 2>&1; then
    echo "DigitalOcean Space ${TF_STATE_BUCKET} already exists."
else
    echo "Creating DigitalOcean Space ${TF_STATE_BUCKET} in ${TF_STATE_REGION}."
    aws --endpoint-url "${SPACES_ENDPOINT}" s3 mb "s3://${TF_STATE_BUCKET}"
fi
