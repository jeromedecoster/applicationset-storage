locals {
  bucket_name = format("%s-%s", var.service_name, substr(sha256(data.aws_caller_identity.current.account_id), 0, 6))
  # https://www.terraform.io/language/expressions/references#filesystem-and-workspace-info
  # target the $PROJECT_DIR
  project_dir = abspath("${path.root}/..")
}


resource "null_resource" "env-file" {

  triggers = {
    everytime = uuid()
  }

  provisioner "local-exec" {
    command = "scripts/env-file.sh .env AWS_ACCOUNT_ID AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_S3_BUCKET REPOSITORY_URL"

    working_dir = local.project_dir

    environment = {
      AWS_ACCOUNT_ID        = data.aws_caller_identity.current.account_id
      AWS_ACCESS_KEY_ID     = aws_iam_access_key.user_key.id
      AWS_SECRET_ACCESS_KEY = aws_iam_access_key.user_key.secret
      AWS_S3_BUCKET         = local.bucket_name
      REPOSITORY_URL        = aws_ecr_repository.repository.repository_url
    }
  }
}
