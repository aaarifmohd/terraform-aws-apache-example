terraform {
  cloud {
    organization = "TF_arif_local_org"
    workspaces {
      name = "terraform_arif"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "> 5.49.0"
    }
  }
}