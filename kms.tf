####
# KMS
####

locals {
  should_create_kms_key          = var.volume_kms_key_create && (var.root_block_device_encrypted || var.extra_volume_count > 0)
  should_grant_asg_to_access_key = var.root_block_device_encrypted && var.use_autoscaling_group && var.volume_kms_key_arn != null

  volume_kms_key_arn = local.should_create_kms_key ? aws_kms_key.this_volume.*.arn[0] : var.volume_kms_key_arn
}

resource "aws_kms_key" "this_volume" {
  count = local.should_create_kms_key ? 1 : 0

  description              = "KMS key for ${format("%s%s", var.prefix, var.name)} instance(s) volume(s)."
  customer_master_key_spec = var.volume_kms_key_customer_master_key_spec
  policy                   = var.volume_kms_key_policy


  tags = merge(
    {
      "Name" = format("%s%s", var.prefix, var.volume_kms_key_name)
    },
    var.tags,
    var.volume_kms_key_tags,
    local.tags,
  )
}

resource "aws_kms_alias" "this_volume" {
  count = local.should_create_kms_key ? 1 : 0

  name          = format("alias/%s%s", var.prefix, var.volume_kms_key_alias)
  target_key_id = aws_kms_key.this_volume[0].key_id
}

resource "aws_kms_grant" "this_volume" {
  count = local.should_grant_asg_to_access_key ? 1 : 0

  name              = "AllowASGToAccessKMS"
  key_id            = local.volume_kms_key_arn
  grantee_principal = aws_iam_service_linked_role.asg.*.arn[0]
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey", "CreateGrant", "GenerateDataKeyWithoutPlaintext", "ReEncryptFrom", "ReEncryptTo", "RetireGrant"]
}
