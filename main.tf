data "aws_ami" "sg" {
    most_recent = true
    owners = ["840044800169"]

    filter {
        name   = "name"
        values = ["Sourcegraph*${var.sg_version}*"]
    }
}

resource "aws_instance" "sg" {
    ami                     = data.aws_ami.sg.id
    availability_zone       = "${var.region}${var.private-az}"
    instance_type           = var.ec2_instance_type
    iam_instance_profile    = aws_iam_instance_profile.sg.name
    metadata_options {
        http_tokens         = "required" # Enable IMDSv2
    }
    subnet_id               = aws_subnet.private.id
    vpc_security_group_ids  = [aws_security_group.private.id]

    lifecycle {
      create_before_destroy = true
    }

    depends_on = [
        terraform_data.local_exec_tf_last_deployed
    ]
}
