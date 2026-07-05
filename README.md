# k3s-infra

## Terraform State

Terraform uses a DigitalOcean Spaces bucket through the S3-compatible backend.
The workflows create the Space automatically if it does not exist. Configure
these GitHub environment variables for `prod`:

- `TF_STATE_BUCKET`: Spaces bucket name for Terraform state

Optional GitHub environment variable:

- `TF_STATE_REGION`: Spaces region, defaults to `fra1`
- `ALLOW_EMPTY_TERRAFORM_STATE`: set to `true` only for a first bootstrap into
  an empty DigitalOcean project; leave unset/false when importing existing
  resources

Configure these GitHub environment secrets for `prod`:

- `DO_SPACES_ACCESS_KEY_ID`: Spaces access key
- `DO_SPACES_SECRET_ACCESS_KEY`: Spaces secret key

The state key is:

```text
k3s-infra/prod/terraform.tfstate
```

`Deploy` calls a reusable Terraform state import workflow before applying. If
remote state is empty or incomplete, it imports existing DigitalOcean resources
before `terraform apply`.

If there are duplicate resource names, set these GitHub environment variables to
disambiguate:

- `TF_IMPORT_DROPLET_ID`
- `TF_IMPORT_VOLUME_ID`
- `TF_IMPORT_FIREWALL_ID`
- `TF_IMPORT_VOLUME_ATTACHMENT_ID`
