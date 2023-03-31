Question 4 :

Create an aws_s3_bucket_notification on your source bucket : (dans : 2-sns.tf)

################## to add 

################ ajouté dans 2-sns pour lancer la lamnbda quand on modifit le s3 source et autoriser le truc

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.move_s3_object_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}


resource "aws_lambda_permission" "allow_bucket_change" {
  statement_id  = "AllowExecutionFromBucketsource"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.move_s3_object_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.source_bucket.arn
  #qualifier     = aws_lambda_alias.test_alias.name
}
















































######################### trucs apportés pour autoriser l'envoit de la fin de la copie du fichier ans le deuxième bucket

data "aws_iam_policy_document" "topic" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:${var.project}-s3-notification"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [data.aws_s3_bucket.target_bucket.arn]
    }
  }
}
