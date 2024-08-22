resource "terraform_data" "local_exec_tf_last_deployed" {
    provisioner "local-exec" {
        command = "bash update_tf_last_deployed.sh"
    }
    triggers_replace = {
        time_rotating_daily_id = time_rotating.daily.rotation_rfc3339
    }
}

resource "time_rotating" "daily" {
    rotation_days = 1
}

## Network
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    depends_on = [
        terraform_data.local_exec_tf_last_deployed
    ]
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_nat_gateway" "ngw" {
    subnet_id = aws_subnet.public1.id
    allocation_id = aws_eip.ngw.id
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "ngw" {
    domain = "vpc"
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "${var.name_tag}-Public"
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.ngw.id
    }

    tags = {
        Name = "${var.name_tag}-Private"
    }
}

resource "aws_route_table_association" "public1" {
    subnet_id      = aws_subnet.public1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
    subnet_id      = aws_subnet.public2.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "public1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public1_cidr
    map_public_ip_on_launch = true
    availability_zone = "${var.region}a"
    tags = {
        Name = "${var.name_tag}-Public1"
    }
}

resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public2_cidr
    map_public_ip_on_launch = true
    availability_zone = "${var.region}b"
    tags = {
        Name = "${var.name_tag}-Public2"
    }
}

resource "aws_security_group" "public" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.name_tag}-Public"
    }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
    security_group_id = aws_security_group.public.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
    security_group_id = aws_security_group.public.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "http_to_private" {
    security_group_id = aws_security_group.public.id
    referenced_security_group_id = aws_security_group.private.id
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "https_to_internet" {
    security_group_id = aws_security_group.private.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
}

resource "aws_alb" "alb" {
    load_balancer_type = "application"
    security_groups    = [
        aws_security_group.public.id
    ]
    subnets            = [
        aws_subnet.public1.id,
        aws_subnet.public2.id
    ]
}

resource "aws_lb_target_group" "private" {
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "name" {
    target_group_arn = aws_lb_target_group.private.arn
    target_id = aws_instance.sg.id
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_alb_listener" "http" {
    load_balancer_arn = aws_alb.alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            status_code = "HTTP_301"
            protocol = "HTTPS"
            port = "443"
      }
    }
}

resource "aws_alb_listener" "https" {
    load_balancer_arn = aws_alb.alb.arn
    port = 443
    protocol = "HTTPS"
    certificate_arn = aws_acm_certificate.alb.arn
    depends_on = [ aws_acm_certificate_validation.alb ]
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.private.arn
    }
}

resource "aws_route53_record" "alb" {
    zone_id = var.route53_zone_id
    name    = var.dns_host_name
    type    = "A"
    alias {
        name                   = aws_alb.alb.dns_name
        zone_id                = aws_alb.alb.zone_id
        evaluate_target_health = false
    }
}

resource "aws_acm_certificate" "alb" {
    domain_name       = "${var.dns_host_name}.${var.dns_domain_name}"
    validation_method = "DNS"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_acm_certificate_validation" "alb" {
    certificate_arn         = aws_acm_certificate.alb.arn
    validation_record_fqdns = [for record in aws_route53_record.acm_cert_dns_validation_records : record.fqdn]
}

resource "aws_route53_record" "acm_cert_dns_validation_records" {
    allow_overwrite = true
    count = length(aws_acm_certificate.alb.domain_validation_options)
    zone_id = var.route53_zone_id
    name    = element(aws_acm_certificate.alb.domain_validation_options.*.resource_record_name, count.index)
    type    = element(aws_acm_certificate.alb.domain_validation_options.*.resource_record_type, count.index)
    records = [element(aws_acm_certificate.alb.domain_validation_options.*.resource_record_value, count.index)]
    ttl     = 60
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = "${var.region}${var.private-az}"
    cidr_block = var.private_cidr
    tags = {
        Name = "${var.name_tag}-Private"
    }
}

resource "aws_security_group" "private" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.name_tag}-Private"
    }
}

resource "aws_vpc_security_group_ingress_rule" "http_from_alb" {
    security_group_id = aws_security_group.private.id
    referenced_security_group_id = aws_security_group.public.id
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_private_subnet" {
    security_group_id = aws_security_group.private.id
    referenced_security_group_id = aws_security_group.private.id
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "ssh_to_private_subnet" {
    security_group_id = aws_security_group.private.id
    referenced_security_group_id = aws_security_group.private.id
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_ec2_instance_connect_endpoint" "connect" {
    subnet_id = aws_subnet.private.id
    security_group_ids = [ aws_security_group.private.id ]
}

## Instance

data "aws_ami" "sg" {
    most_recent = true
    owners = ["840044800169"]

    filter {
        name   = "name"
        values = ["Sourcegraph-${var.sourcegraph_ami_tshirt_size}*${var.sourcegraph_version}*"]
    }
}

resource "aws_instance" "sg" {
    ami                     = data.aws_ami.sg.id
    availability_zone       = "${var.region}${var.private-az}"
    instance_type           = var.ec2_instance_type
    subnet_id               = aws_subnet.private.id
    vpc_security_group_ids  = [aws_security_group.private.id]

    lifecycle {
      create_before_destroy = true
    }

    depends_on = [
        terraform_data.local_exec_tf_last_deployed
    ]
}

resource "terraform_data" "initialize_admin" {
    provisioner "local-exec" {
        command = "bash initialize_site_admin.sh ${var.dns_host_name} ${var.dns_domain_name} ${var.sg_initial_admin_email} ${var.sg_initial_admin_username} ${var.sg_initial_admin_password} ${var.sg_initial_admin_timeout_seconds}"

    }
    triggers_replace = aws_instance.sg.id
    depends_on = [
        aws_instance.sg
    ]
}

# resource "aws_ebs_volume" "data" {
#     availability_zone = "${var.region}${var.private-az}"
#     size = 500
# }

# import {
#     to = aws_ebs_volume.data
#     id = "vol-0f9fdeb8b8cceb8cd"
# }

# resource "aws_volume_attachment" "data" {
#     device_name = "/dev/sdb"
#     volume_id   = aws_ebs_volume.data.id
#     instance_id = aws_instance.sg.id
# }

# import {
#     to = aws_volume_attachment.data
#     id = "/dev/sdb:vol-0f9fdeb8b8cceb8cd:i-0122cbbc7984688bd"
# }

