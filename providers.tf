terraform {
    required_providers {

        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.63"
        }
    }
}

# Configure the AWS Provider
provider "aws" {
    region = var.region
    default_tags {
        tags = {
            Name = var.name_tag
            Repo = var.repo_tag
        }
    }
}
