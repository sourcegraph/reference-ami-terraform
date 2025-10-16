
resource "aws_iam_instance_profile" "sg" {

    name = "sg"
    role = aws_iam_role.sg.name

}

resource "aws_iam_role" "sg" {

    name               = "sg"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }
}
EOF

}

resource "aws_iam_role_policy_attachment" "sg_ssm" {

    role       = aws_iam_role.sg.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}
