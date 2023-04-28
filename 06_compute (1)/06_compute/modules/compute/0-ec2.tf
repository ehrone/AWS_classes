data "aws_ami" "amazon_linux_2_ami" {
  most_recent = true
  name_regex  = "^amzn2-ami-hvm-[\\d.]+-x86_64-gp2$"
  owners      = ["amazon"]
}

data "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "LabInstanceProfile"
}

resource "aws_security_group" "ssh_security_group" {
  name        = "${var.project}-ssh-security-group"
  description = "SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-ssh-security-group"
  }
}

resource "aws_vpc_security_group_egress_rule" "ssh_security_group_egress_rule" {
  security_group_id = aws_security_group.ssh_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_security_group_ingress_rule" {
  security_group_id = aws_security_group.ssh_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.amazon_linux_2_ami.id
  instance_type        = "t3.small"
  subnet_id            = var.public_subnet_id
  iam_instance_profile = data.aws_iam_instance_profile.ssm_instance_profile.name
  key_name             = aws_key_pair.ssh_key_pair.key_name
  vpc_security_group_ids = [
    aws_security_group.ssh_security_group.id
  ]

  tags = {
    Name = "bastion"
  }
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "public_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUJ6QyGiN43jjy6uAxcs3U3kyuiapSX9SSQH6basDskvYJNPrah6Exnhq5S6yNVZ5mkbErCgkvC4B4wYyJHuacLS2hdmZAuUOu9czohkUNoP5Qv+AyvasVylXzh2X3c00ydNnyBKaLbgBbpsRBQ4+Ot5VSEokTouJkR9ANL/pHv7d03i6kQrNoYzmAENAndVU/FgtZCDa4HG3AgBk6+FXNhcjDMUb6svaa4xPHeMottLUsOpqzbdM40kfQWtOBrKUZ1Lz5M3fx2+KI/qoeEJoSxU84UFzPYslRSXKzonrJB/pviePm1RfOr+ZJmiwxhdaNv+hUlPVZXMpzHB6hgB+b ec2-user@ip-172-31-90-39.ec2.internal"
}

resource "aws_instance" "web_server" {
  ami                  = data.aws_ami.amazon_linux_2_ami.id
  instance_type        = "t3.small"
  subnet_id            = var.private_subnet_id
  iam_instance_profile = data.aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.web_server_security_group.id
  ]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo yum update
  sudo yum install httpd -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "*** Completed Installing apache2"
  EOF

  tags = {
    Name = "web-server"
  }
}

resource "aws_security_group" "web_server_security_group" {
  name        = "${var.project}-web-server-security-group"
  description = "Web access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-web-server-security-group"
  }
}

resource "aws_vpc_security_group_egress_rule" "web_server_security_group_egress_rule" {
  security_group_id = aws_security_group.web_server_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "web_server_security_group_ingress_rule" {
  security_group_id = aws_security_group.web_server_security_group.id

  cidr_ipv4   = "10.0.0.0/16"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}
