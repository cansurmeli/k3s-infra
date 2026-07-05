# k3s-infra

## Terraform State

Terraform uses a DigitalOcean Spaces bucket through the S3-compatible backend.
Create the bucket before running the workflows, then configure these GitHub
environment secrets for `prod`:

- `TF_STATE_BUCKET`: Spaces bucket name for Terraform state
- `DO_SPACES_ACCESS_KEY_ID`: Spaces access key
- `DO_SPACES_SECRET_ACCESS_KEY`: Spaces secret key

Optional GitHub environment variable:

- `TF_STATE_REGION`: Spaces region, defaults to `fra1`
- `ALLOW_EMPTY_TERRAFORM_STATE`: set to `true` only for a first bootstrap into
  an empty DigitalOcean project; leave unset/false when importing existing
  resources

The state key is:

```text
k3s-infra/prod/terraform.tfstate
```

If resources already exist in DigitalOcean, run the `Import Terraform State`
workflow once with the real Droplet, Volume, Firewall, and Volume Attachment IDs
before running `Deploy` again.
