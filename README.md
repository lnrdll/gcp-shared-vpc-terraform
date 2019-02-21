## Results

This terraform script will perform the following tasks:
1. Create a Org Folder
2. Create 3 projects:
   1. 1x host project
   2. 2x service projects
3. Create a custom VPC network and subnet to be used as a shared resource

## Setup tl;dr

1. Set up environment variables
2. Create service account, grant permissions, create key credentials
3. You need the following GCP information:
   1. organization ID
   2. billing ID
4. Run terraform

## Set up the environment

Export the following variables:

```sh
export TF_ADMIN=tf-admin
export TF_CREDS=~/.config/gcloud/${TF_ADMIN}.json
```

## Terraform service account

Create a service account and credentials that will be used to create and manage projects.

```sh
gcloud iam service-accounts create terraform --display-name "Terraform admin account"
gcloud iam service-accounts keys create ${TF_CREDS} --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com
```

Grant the service account the proper permissions to:
* create projects
* assign billing accounts
* create shared vpc

```sh
gcloud organizations add-iam-policy-binding ${ORG_ID} --member serviceAccount:terraform
```