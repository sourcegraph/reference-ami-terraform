## tf_last_deployed tag

resource "terraform_data" "local_exec_tf_last_deployed" {
    # Used to tag all resources with tf_last_deployed
    provisioner "local-exec" {
        command = "bash update_tf_last_deployed.sh"
    }
    triggers_replace = {
        time_rotating_daily_id = time_rotating.daily.rotation_rfc3339
    }
}

resource "time_rotating" "daily" {
    # Used to tag all resources with tf_last_deployed
    rotation_days = 1
}


## Try to initialize the initial Sourcegraph site admin on deployment

resource "terraform_data" "initialize_admin" {
    provisioner "local-exec" {
        command = "bash initialize_site_admin.sh ${var.dns_host_name} ${var.dns_domain_name} ${var.sg_initial_admin_email} ${var.sg_initial_admin_username} ${var.sg_initial_admin_password} ${var.sg_initial_admin_timeout_seconds}"

    }
    triggers_replace = aws_instance.sg.id
    depends_on = [
        aws_instance.sg
    ]
}


## AWS management tooling

resource "aws_ec2_instance_connect_endpoint" "connect" {
    subnet_id = aws_subnet.private.id
    security_group_ids = [ aws_security_group.private.id ]
}

