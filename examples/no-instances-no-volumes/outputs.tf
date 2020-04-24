####
# Instance Profile
####

output "iam_instance_profile_id" {
  value = module.example.iam_instance_profile_id
}

output "iam_instance_profile_external_name" {
  value = module.example.iam_instance_profile_external_name
}

output "iam_instance_profile_unique_id" {
  value = module.example.iam_instance_profile_unique_id
}

output "iam_instance_profile_iam_role_arn" {
  value = module.example.iam_instance_profile_iam_role_arn
}

output "iam_instance_profile_iam_role_id" {
  value = module.example.iam_instance_profile_iam_role_id
}

output "iam_instance_profile_iam_role_unique_id" {
  value = module.example.iam_instance_profile_iam_role_unique_id
}
