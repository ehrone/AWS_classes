## TP1

# Question 1 : Créer une valeur aléatoire 

Dans le fichier random.tf on écrit :

    # variable qui nous sert à set up le min 
    variable "min" { 
        type = number
        default = 10
    }

    # variable qui nous sert à set up le max
    variable "max" {
        type = number
        default = 20
    }

    # On utilise le module random_integer pour créer une variable aléatoire appelée random_int
    resource "random_integer" "random_int" {
        min = var.min
        max = var.max
    }

    # On affiche le contenu de la variable de type random_integer
    output "random_integer" {
        value = random_integer.random_int.result # le contenu de la variable
        description = " Valeur aléatoire entre 10 et 20 "
    }


On sauvegarde le fichier puis on l'éxécute :

    terraform init 
    terraform plan 
    terrafomr apply 

    # Pour pouvoir recréer une valeur aléatoire faut déjà détruir celle créer et on recommence les commandes 
    terraform destroy

# Question 2 : Créer un test S3 bucket et télécharger un des fichier du PC dedans

    # On créee un bucket 
    resource "aws_s3_bucket" "b" {
        source = "terraform-aws-modules/s3-bucket/aws"
        bucket = "nom qui doit être unique dans le monde "
    }
