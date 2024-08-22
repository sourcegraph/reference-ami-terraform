### Variables to maintain

variable "sourcegraph_version" {
    default = "5.6.185"
    description = "Provide a specific Sourcegraph version if you'd like to pin versions instead of always getting latest. ex. v5.5.1337"
}

variable "sourcegraph_ami_tshirt_size" {
    default = "XS"
}

variable "ec2_instance_type" {
    default = "m6a.2xlarge"
}

### Required variables

variable "route53_zone_id" {
    description = "Zone ID of your Route53 DNS zone, to create a record"
}

variable "dns_domain_name" {
    description = "The parent domain name your hostname will fall under"
    default = "internal.example.com"
}

variable "dns_host_name" {
    description = "The host portion of the FQDN"
    default = "sourcegraph"
}

variable "sg_initial_admin_email" {
    description = "The email address of the initial Sourcegraph site admin account, recommended to be an email distribution group"
    default = "sourcegraph-admin-team+sourcegraph-initial-site-admin@example.com"
    #sensitive = true
}

variable "sg_initial_admin_username" {
    description = "The username of the initial Sourcegraph site admin account, recommended to not be 'admin'"
    default = "sourcegraph-initial-site-admin"
    #sensitive = true
}

variable "sg_initial_admin_password" {
    description = "The password of the initial Sourcegraph site admin account, recommended to not be 'admin', and do not store this as code"
    #sensitive = true
}

### Optional variables

variable "name_tag" {
    default = "ami"
}

variable "repo_tag" {
    default = "https://github.com/sourcegraph/reference-ami-terraform"
}

variable "region" {
    default = "us-east-2"
}

variable "private-az" {
    default = "a"
}

variable "vpc_cidr" {
    default = "10.0.0.0/24"
}

variable "private_cidr" {
    default = "10.0.0.0/28"
}

variable "public1_cidr" {
    default = "10.0.0.128/26"
}

variable "public2_cidr" {
    default = "10.0.0.192/26"
}

variable "sg_initial_admin_timeout_seconds" {
    default = "180"
}

### Automated variables

variable "tf_last_deployed" {
    default = ""
}
