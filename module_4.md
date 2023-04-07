Afin d'éviter les dégats si un utilisteur se fait ppiquer une clé ssh de connection, on a tendnace à donner des autorisations à un rôle ou un groupe et de donner se rôle/groupe à des utilisteurs.


Atelier : We use a prepared system to tets the IAM rights and everything related 

url : https://402078987205.signin.aws.amazon.com/console

documentation :

https://registry.terraform.io/providers/hashicorp/aws/latest/docs


Trouver arn pour les identifiers : On va dasn AMI, on va dasn les utilisteurs, on choppe l'arn de n'importe lequel jusque %role/%, puis ensuite on le met dans role et on le met dans le 

resource "random_string" "topic_name_suffix" // pour donner un nom aléatoire pour notre policy
{
  length    = 10
  special   = false
  min_lower = 10
}

resource "aws_sns_topic" "default" //on créer une politique avec un nom
{
  name         = "${var.school}-${random_string.topic_name_suffix.result}"
  display_name = "CPE default topic"
}


resource "aws_sns_topic_policy" "default" 
{
  arn = aws_sns_topic.default.arn // le topic que l'on a crée

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}


data "aws_iam_policy_document" "sns_topic_policy" 
{
  policy_id = "__default_policy_ID"

  // the rights of the service concerned
  statement 
  {
    actions = ["SNS:Publish"]

    effect = "Deny"

    principals 
    {
      type        = "AWS"
      identifiers = ["arn:aws:iam::149294902279:role/voclabs"]
    }

    resources = [aws_sns_topic.default.arn]

    sid = "__default_statement_ID"
  }
}