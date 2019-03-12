# GCP Shared VPC (Terraform)

This terraform sample will create a GCP Shared VPC setup.

## tl;dr

The following tasks will be performed:
1. Create a Org Folder
2. Create 3 projects:
   1. 1x host project
   2. 2x service projects
3. Create a custom VPC network and subnet to be used as a shared resource

### Terraform

Run terraform:

```
terraform apply -var="org_id=<ORG_ID>" -var="billing_id=<BILLING_ID>"
```

Destroy:

```
terraform destroy -var="org_id=<ORG_ID>" -var="billing_id=<BILLING_ID>"
```

## License

This project is licensed under the Apache-2.0 License - see the [LICENSE](LICENSE) file for details