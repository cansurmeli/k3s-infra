#!/usr/bin/env bash
set -euo pipefail

missing=()
for name in TF_VAR_do_token DROPLET_ID VOLUME_ID VOLUME_REGION; do
    if [ -z "${!name:-}" ]; then
        missing+=("${name}")
    fi
done

if [ "${#missing[@]}" -gt 0 ]; then
    echo "Missing required DigitalOcean volume attachment values: ${missing[*]}"
    exit 1
fi

api_get() {
    local path="$1"
    curl -fsSL \
        -H "Authorization: Bearer ${TF_VAR_do_token}" \
        -H "Content-Type: application/json" \
        "https://api.digitalocean.com/v2/${path}"
}

api_post() {
    local path="$1"
    local payload="$2"
    curl -fsSL \
        -X POST \
        -H "Authorization: Bearer ${TF_VAR_do_token}" \
        -H "Content-Type: application/json" \
        -d "${payload}" \
        "https://api.digitalocean.com/v2/${path}"
}

volume_payload="$(api_get "volumes/${VOLUME_ID}")"
if jq -e --argjson droplet_id "${DROPLET_ID}" '.volume.droplet_ids | index($droplet_id)' <<< "${volume_payload}" >/dev/null; then
    echo "Volume ${VOLUME_ID} is already attached to Droplet ${DROPLET_ID}."
    exit 0
fi

echo "Attaching Volume ${VOLUME_ID} to Droplet ${DROPLET_ID}."
attach_payload="$(jq -n \
    --arg type "attach" \
    --argjson droplet_id "${DROPLET_ID}" \
    --arg region "${VOLUME_REGION}" \
    '{type: $type, droplet_id: $droplet_id, region: $region}')"
action_payload="$(api_post "volumes/${VOLUME_ID}/actions" "${attach_payload}")"
action_id="$(jq -r '.action.id' <<< "${action_payload}")"

for _ in $(seq 1 60); do
    action_status="$(api_get "actions/${action_id}" | jq -r '.action.status')"
    case "${action_status}" in
        completed)
            echo "Volume attach action ${action_id} completed."
            exit 0
            ;;
        errored)
            echo "Volume attach action ${action_id} failed."
            exit 1
            ;;
    esac
    sleep 2
done

echo "Timed out waiting for volume attach action ${action_id}."
exit 1
