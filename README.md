# reference-ami-terraform
This repo contains some example Terraform code a customer could use to deploy an AMI instance and keep it up to date

## Prerequisites

This assumes you have a DNS zone in Route53 (variable "route53_zone_id"), with a domain name in it (variable "dns_domain_name").

## Resources

This repo deploys a new VPC, and all subsequent network resources, to enable:
- 2x public subnets
    - ALB, with DNS record, TLS cert from ACM, and port 80 -> 443 redirect
    - Nat Gateway
    - Internet Gateway
- 1x private subnet
    - Sourcegraph instance
    - EC2 Instance Connect Private Endpoint

## TODO

1. Data volume
    1. Import and retain existing data volume
    2. Detach new (empty) data volume from newly deployed instance
    3. Attach existing data volume to newly deployed instance
2. Initialize site admin
    1. Just need to add a check or delay, to wait till /site-init is available