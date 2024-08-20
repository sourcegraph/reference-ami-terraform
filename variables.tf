variable "sourcegraph_version" {
    default = ""
    description = "Provide a specific Sourcegraph version if you'd like to pin versions instead of always getting latest. ex. v5.5.1337"
}

variable "sourcegraph_ami_tshirt_size" {
    default = "XS"
}

variable "ec2_instance_type" {
    default = "m6a.2xlarge"
}

variable "admin_ssh_ip" {
    sensitive = true
}

variable "sg_initial_admin_email" {
    sensitive = true
}

variable "sg_initial_admin_username" {
    sensitive = true
}

variable "sg_initial_admin_password" {
    sensitive = true
}

variable "name_tag" {
    default = "ami"
}

variable "repo_tag" {
}

variable "region" {
    default = "us-west-2"
}

variable "private-az" {
    default = "b"
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

variable "route53_zone_id" {
    description = "Zone ID of your Route53 DNS zone, to create a record"
}

variable "dns_domain_name" {
}

variable "dns_host_name" {
    default = "ami"
}
