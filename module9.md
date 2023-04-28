
# Module 9   
Attention, rien n'est rangé dans un odule, du coup va falloir prévoir les output et tt dans le main, pour faire passer les variables et tt le bordel.   

On créée trois fichiers, main.tf, variables.tf et output.tf.   

## Création du vpc :     

Dans variables.tf :  

```   
variable "region" {   
  type    = string   
  default = "us-east-1"   
}   

variable "school" {   
  type    = string   
  default = "cpe"   
}   

variable "project" {   
  type    = string   
  default = "06-compute"   
}   
```   

On créer un fichier vpc.tf :   

```

module "vpc" {   
  source = "terraform-aws-modules/vpc/aws"   

  name = "my-vpc"   
  cidr = "10.0.0.0/16"   

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]   
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]   
  public_subnets  = ["10.0.96.0/24", "10.0.128.0/24", "10.0.160.0/19"]   

  enable_nat_gateway = true   
  enable_vpn_gateway = false    

  tags = {   
    Terraform = "true"   
    Environment = "dev"   
  }   
}   


```   
La même mais en uilisant des variables :     

```   
module "vpc" {   
  source = "terraform-aws-modules/vpc/aws"   

  name = "my-vpc-${var.school}"   
  cidr = "10.0.0.0/16"   

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]   
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]   
  public_subnets  = ["10.0.96.0/24", "10.0.128.0/24", "10.0.160.0/19"]   

  enable_nat_gateway = true   
  enable_vpn_gateway = true   

  tags = {   
    Terraform = "true"   
    Environment = "dev"   
  }   
}   
```  

## Création du security group pour l'EC2 :   

On créer un fichier security_groupe.tf .  

Avec les modules prés-faits :   

```   
module "web_server_sg" {   
  source = "terraform-aws-modules/security-group/aws//modules/http-80"   

  name        = "ec2"   
  description = "Security group for the ec2"   
  vpc_id      = module.vpc.vpc_id   

  ingress_cidr_blocks = ["10.10.0.0/16"]   
  ingress_rules =[]   
}   
```    

direct avec la doc, sans modules prés faits :   

```
resource "aws_security_group" "ec2_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {   
    secutiry_groups = [aws_security_group.lb_sg.id]   
    from_port        = 0   
    to_port          = 80   
    protocol         = "tcp"      
  }   

  egress {   
    from_port        = 0   
    to_port          = 0   
    protocol         = "-1"   
    cidr_blocks      = ["0.0.0.0/0"]   
    ipv6_cidr_blocks = ["::/0"]   
  }

}
```


## Bash installation nginx, pour l'installer sur l'EC2 :   
On créer un fichier : ngnix_instll.sh  

```
#!/bin/bash   

yum update && yum upgrade   
yum install nginx -y    
systemctl enable nginx.service   
systemctl start nginx.service   
```

## Création de l'EC2 :   

On créer un module ec2.tf. Attention, la on utilise un module prés fait pour créer notre EC2.   

```     
// on récupère la version la plus récente de ec2   
data "aws_ami" "amazon_linux_2_ami" {   
  most_recent = true   
  name_regex  = "^amzn2-ami-hvm-[\\d.]+-x86_64-gp2$"   
  owners      = ["amazon"]   
}

data "aws_iam_instance_profile" "ssm_instance_profile" {   
  name = "LabInstanceProfile"   
}   

// On créer notre EC2   
module "ec2_instance" {   
  source  = "terraform-aws-modules/ec2-instance/aws"   
  version = "~> 3.0"   

  name = "single-instance"   
  ami                    = data.aws_ami.amazon_linux_2_ami.id   
  instance_type          = "t3.small"   
  key_name               = "user1"   
  monitoring             = true   
  iam_instance_profile   = data.aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]   
  subnet_id              = module.vpc.private_subnets[0]  
  user_data = file( "${path.module}/ngnix_instll.sh" )   

  instance_tenancy= data.aws_iam_instance_profile.ssm_instance_profile.name
}    
   
```  

## Création sécurity group pour le load balancer :   

``` 
resource "aws_security_group" "lb_sg" {   
  name        = "allow_http"   
  description = "Allow http"   
  vpc_id      = module.vpc.vpc_id  

  ingress {   
    description      = "tcp for load balancer VPC"   
    protocol         = "TCP"  
    from_port        =80   
    to_port          =80
    ipv6_cidr_blocks = [0.0.0.0/0]   
  }   

  tags = {   
    Name = "allow_tls"   
  }   
}   
``` 

## Création du load balancer :      

On créer un fichier lb.tf :   

``` 
resource "aws_lb" "test" {    
  name               = "test-lb-tf"   
  internal           = false   
  load_balancer_type = "application"   
  security_groups    = [aws_security_group.lb_sg.id]   
  subnets            = module.vpc.public_subnets   
  internal = false   // demandé dans le sujet   

  enable_deletion_protection = true   
  
}   


// partiie a check sur la correction, elle est bizarre

resource "aws_lb_listener" "front_end" {   
  load_balancer_arn = aws_lb.front_end.arn   
  port              = "80"   
  protocol          = "HTTP"   

  default_action {
    type = "forward"
    target_group_arn = // un truc avec target groupe, aller voir sur la correction : lb_target_group juste en dessous.
    }
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "tf-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.vpc_id
}


```   

