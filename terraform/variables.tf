variable "region" {
  description = "Default region"
  default     = "us-central1"
}

variable "zone" {
  description = "Default zone"
  default     = "us-central1-a"
}

variable "project_name" {
  description = "Default project name prefix"
  default     = "shared-vpc"
}

variable "subnet_cidr" {
  description = "Default network subnet"
  default     = "10.10.0.0/24"
}

variable "org_id" {
  description = "Organization ID"
}

variable "billing_id" {
  description = "Associated billing acount"
}

# https://github.com/terraform-providers/terraform-provider-google/blob/master/examples/shared-vpc/main.tf
# https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform

