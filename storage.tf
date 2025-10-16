# TODO: Find a way to maintain the data volume across redeploying the AMI instance

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
