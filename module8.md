##Question 3 : Créer un db subnet group (on met la base de données dans un réseau privé):  

Dans le module database :  

    Dans variables.tf :  
        ```variable "subnet_priv_a" // attention ce nom doit correspondre à celui déclaré plus bas dans le main du dosier module !  
        {
            type = string  
        }```

    Dans 0-rds.tf du module database :  

        ```resource "aws_db_subnet_group" "default"  
        {
            name       = "main"  
            subnet_ids = [var.subnet_priv_a]  

            tags = {  
                Name = "My DB subnet group"  
            }  
        }```

Dans le module network :  

    Dans outputs.tf :
        ```output "subnet_priv_a"  
        {  
            value = aws_subnet.private_subnet_a.id // on donne en sortie l'id de notre réseau privé  
        }```

Dans le main: module "database" :  
    On rajoute : ```subnet_priv_a = module.network.subnet_priv_a // c'est l'id de notre réseau que l'on affecte à la variable subnet_priv_a de database```  

##Question 4 :  On définit un sécurity group pour notre RDS (il sera lié à notre base de donnée plus tard)

```
resource "aws_security_group" "RDS_security_group" // on crée un security group  
{  
  name        = "RDS-security-group"  
  description = "RDS security group"  
  vpc_id      = var.vpc_id  

  tags = {  
    Name = "RDS-security-group"  
  }  
}

// the ingress rule ( pour tt ce qui est en input)  
resource "aws_vpc_security_group_ingress_rule" "RDS_security_group_ingress_rule"  
{  
  security_group_id = aws_security_group.RDS_security_group.id  

  cidr_ipv4   = "10.0.0.0/16"  
  from_port   = 5432  
  to_port     = 5432  
  ip_protocol = "tcp"  
}  
```

Question 5 : Créer une RDS instance  une data base 

```
resource "aws_db_instance" "DB_instance" {  
  allocated_storage    = 10  
  db_name              = "main"  
  engine               = "postgres"  
  instance_class       = "db.t3.small"  
  username             = "main"  
  password             = "aaaaaaaa"  
  vpc_security_group_ids = [aws_security_group.RDS_security_group.id]  
  skip_final_snapshot  = true  
  db_subnet_group_name ="main"
}

```

Question 6 : Security group de la data base 

