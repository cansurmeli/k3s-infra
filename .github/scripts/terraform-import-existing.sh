#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TF_VAR_do_token:-}" ]; then
    echo "Missing TF_VAR_do_token for DigitalOcean API lookup."
    exit 1
fi

PROJECT_NAME="${PROJECT_NAME:-k3s-main}"
VOLUME_NAME="${VOLUME_NAME:-${PROJECT_NAME}-data-01}"
FIREWALL_NAME_PREFIX="${FIREWALL_NAME_PREFIX:-${PROJECT_NAME}-fw-}"

api_get() {
    local path="$1"
    curl -fsSL \
        -H "Authorization: Bearer ${TF_VAR_do_token}" \
        -H "Content-Type: application/json" \
        "https://api.digitalocean.com/v2/${path}"
}

discover_single() {
    local description="$1"
    local jq_filter="$2"
    local payload="$3"
    local discovered
    discovered="$(jq -r "${jq_filter}" <<< "${payload}")"
    local count
    count="$(wc -l <<< "${discovered}" | tr -d ' ')"

    if [ -z "${discovered}" ]; then
        echo "Could not discover ${description}."
        return 1
    fi

    if [ "${count}" -ne 1 ]; then
        echo "Found multiple ${description} candidates:"
        echo "${discovered}"
        echo "Set the matching TF_IMPORT_* GitHub environment variable to disambiguate."
        return 1
    fi

    echo "${discovered}"
}

import_if_missing() {
    local address="$1"
    local id="$2"

    if terraform state show "${address}" >/dev/null 2>&1; then
        echo "${address} already exists in state"
    else
        terraform import -var-file=envs/prod.tfvars "${address}" "${id}"
    fi
}

if terraform state show digitalocean_droplet.k3s_main >/dev/null 2>&1 \
    && terraform state show digitalocean_volume.k3s_data >/dev/null 2>&1 \
    && terraform state show digitalocean_firewall.k3s_main_fw >/dev/null 2>&1; then
    echo "All managed DigitalOcean resources already exist in Terraform state."
    exit 0
fi

if ! terraform state list | grep -q . && [ "${ALLOW_EMPTY_TERRAFORM_STATE:-false}" = "true" ]; then
    echo "ALLOW_EMPTY_TERRAFORM_STATE=true; skipping import and allowing Terraform to create resources."
    exit 0
fi

echo "Terraform state is empty or incomplete; attempting to import existing DigitalOcean resources."

droplet_id="${TF_IMPORT_DROPLET_ID:-}"
volume_id="${TF_IMPORT_VOLUME_ID:-}"
firewall_id="${TF_IMPORT_FIREWALL_ID:-}"

if [ -z "${droplet_id}" ]; then
    droplets_payload="$(api_get "droplets?tag_name=${PROJECT_NAME}")"
    droplet_id="$(discover_single "Droplet named ${PROJECT_NAME}" ".droplets[] | select(.name == \"${PROJECT_NAME}\") | .id" "${droplets_payload}")"
fi

if [ -z "${volume_id}" ]; then
    volumes_payload="$(api_get "volumes?name=${VOLUME_NAME}")"
    volume_id="$(discover_single "Volume named ${VOLUME_NAME}" ".volumes[] | select(.name == \"${VOLUME_NAME}\") | .id" "${volumes_payload}")"
fi

if [ -z "${firewall_id}" ]; then
    firewalls_payload="$(api_get "firewalls")"
    firewall_id="$(discover_single "Firewall attached to Droplet ${droplet_id}" ".firewalls[] | select((.name | startswith(\"${FIREWALL_NAME_PREFIX}\")) and (.droplet_ids | index(${droplet_id}))) | .id" "${firewalls_payload}")"
fi

import_if_missing digitalocean_droplet.k3s_main "${droplet_id}"
import_if_missing digitalocean_volume.k3s_data "${volume_id}"
import_if_missing digitalocean_firewall.k3s_main_fw "${firewall_id}"
