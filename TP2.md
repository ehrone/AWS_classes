Addresse DNS IPV4 Publique :
    ec2-3-238-4-155.compute-1.amazonaws.com


Création des sous réseaux dans le VPC :
    medium.com/@aliatakan/terraform-create-a-vpc-subnets-and-more-6ef43f0bf4c1

Code :

        resource "aws_subnet" "public_subnet"{
        
        vpc_id=aws_vpc.vpc.id
        cidr_block="10.0.2.0/24"
        map_public_ip_on_launch = "true" // to makethe subnet public
        availability_zone="us-east-1a"
        }
        

        resource "aws_subnet" "private_subnet"{
        
        vpc_id=aws_vpc.vpc.id
        cidr_block="10.0.1.0/24"
        map_public_ip_on_launch = "false" // to makethe subnet public
        availability_zone="us-east-1a"
        
        }




