# https://github.com/cloudposse/terraform-aws-ssm-parameter-store/blob/master/README.md#usage
module "ssm_parameters" {
  # source  = "cloudposse/ssm-parameter-store/aws"
  # version = "0.10"

  # source with git@... does not allow version attribute
  source = "git@github.com:cloudposse/terraform-aws-ssm-parameter-store.git"

  parameter_write = [
    # https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-advanced-parameters.html
    # Standard parameter (4 KB + No policy) are free

    # https://github.com/cloudposse/terraform-aws-ssm-parameter-store/blob/master/README.md#input_parameter_write_defaults
    # default is `overwrite:false` `tier:Standard` `type:SecureString`

    # https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_PutParameter.html
    # type valid values: String | StringList | SecureString
    # Items in a StringList must be separated by a comma (,).
    {
      name      = "/${var.project_name}/access_key_id"
      value     = aws_iam_access_key.user_key.id
      type      = "String"
      overwrite = true
    },
    {
      name      = "/${var.project_name}/secret_access_key"
      value     = aws_iam_access_key.user_key.secret
      type      = "String"
      overwrite = true
    },
    {
      name      = "/${var.project_name}/s3_bucket"
      value     = local.bucket_name
      type      = "String"
      overwrite = true
    }
  ]
}

# /!\ managing ssm parameters with terraform can be annoying :
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter#overwrite
# 1) TF fails if the parameter already exists, even if the parameter `overwrite = true`

# https://www.terraform.io/language/meta-arguments/lifecycle#prevent_destroy
# 2) there is no solution if you want to keep the parameter online after a terraform destroy 
#    the lifecycle { prevent_destroy = true } just warn you that you can't apply the destroy
#    and make TF fails

# the only solution I found to resolve the 2 points above is to use a `local-exec` + `aws-cli` command

/*
resource "null_resource" "ssm_parameters" {
  triggers = {
    everytime = uuid()
  }

  provisioner "local-exec" {

    # https://stackoverflow.com/a/7527438/1503073
    # &>/dev/null : redirect stdout + stderr to the same (is not working)

    # /!\ name must start with a slash `/`
    command = "aws ssm put-parameter --name /${var.project_name}/access_key_id --type String --value ${aws_iam_access_key.user_key.id} 1>/dev/null 2>/dev/null"

    # https://www.terraform.io/language/resources/provisioners/syntax#failure-behavior
    on_failure = continue
  }
}
*/