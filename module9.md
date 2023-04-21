On créer un fichier vpc.tf   

```

module "vpc" {   
  source = "terraform-aws-modules/vpc/aws"   

  name = "my-vpc"   
  cidr = "10.0.0.0/16"   

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]   
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

On créer un module ec2.tf   

```   
      
// on récupère la version la plus récente de ec2   
data "aws_ami" "amazon_linux_2_ami" {   
  most_recent = true   
  name_regex  = "^amzn2-ami-hvm-[\\d.]+-x86_64-gp2$"   
  owners      = ["amazon"]   
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
  vpc_security_group_ids = ["sg-12345678"]   
  subnet_id              = module.vpc.private_subnets[0]     

  tags = {   
    Terraform   = "true"   
    Environment = "dev"   
  }   
}    
   
```   
On créer un fichier security_groupe.tf   

```   

module "web_server_sg" {   
  source = "terraform-aws-modules/security-group/aws//modules/http-80"   

  name        = "ec2"   
  description = "Security group for the ec2"   
  vpc_id      = module.vpc.vpc_id   

  ingress_cidr_blocks = ["10.10.0.0/16"]   
}   
```    