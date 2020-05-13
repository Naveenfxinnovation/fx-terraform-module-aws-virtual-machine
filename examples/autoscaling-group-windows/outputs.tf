#####
# with-nlb-and-external-volumes
#####

output "with_nlb_and_external_volumes" {
  value = module.with_lb_and_external_volumes
}

#####
# no_target_groups_and_no_external_volumes
#####

output "no_target_groups_and_no_external_volumes" {
  value = module.no_target_groups_and_no_external_volumes
}
