//#####
//# EC2 with options
//#####
//
//output "options" {
//  value = module.options
//}
//
//#####
//# EC2 with extra volumes
//#####
//
//output "with_volumes" {
//  value = module.with_volumes
//}

#####
# EC2 with extra NICs & EIP
#####

output "with_nic_and_eips" {
  value = module.with_nic_and_eips
}
//
//#####
//# EC2 using external resources
//#####
//
//output "externals" {
//  value = module.externals
//}
