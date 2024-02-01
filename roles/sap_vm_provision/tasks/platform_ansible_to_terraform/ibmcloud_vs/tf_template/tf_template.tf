# Terraform declaration

terraform {
  required_version = ">= 1.0, <= 1.5.5"
  required_providers {
    ibm = {
      #source  = "localdomain/provider/ibm" // Local, on macOS path to place files would be $HOME/.terraform.d/plugins/localdomain/provider/ibm/1.xx.xx/darwin_amd6
      source  = "IBM-Cloud/ibm" // Terraform Registry
      version = ">=1.45.0"
    }
  }
}


# Terraform Provider declaration

provider "ibm" {

  # Define Provider inputs manually
  #  ibmcloud_api_key = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Define Provider inputs from given Terraform Variables
  ibmcloud_api_key = var.ibmcloud_api_key

  # If using IBM Cloud Automation Manager, the Provider declaration values are populated automatically
  # from the Cloud Connection credentials (by using Environment Variables)

  # If using IBM Cloud Schematics, the Provider declaration values are populated automatically

  region = local.ibmcloud_region

}


module "run_account_init_module" {

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/account_init?ref=main"

  module_var_resource_group_name           = local.resource_group_create_boolean ? 0 : var.ibmcloud_resource_group
  module_var_resource_group_create_boolean = local.resource_group_create_boolean

  module_var_resource_prefix = var.sap_vm_provision_resource_prefix

  module_var_ibmcloud_vpc_subnet_name           = local.ibmcloud_vpc_subnet_create_boolean ? 0 : var.ibmcloud_vpc_subnet_name
  module_var_ibmcloud_vpc_subnet_create_boolean = local.ibmcloud_vpc_subnet_create_boolean
  module_var_ibmcloud_vpc_availability_zone     = var.ibmcloud_vpc_availability_zone

}


module "run_account_bootstrap_module" {

  depends_on = [
    module.run_account_init_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/account_bootstrap?ref=main"

  module_var_resource_group_id = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix   = var.sap_vm_provision_resource_prefix

  module_var_ibmcloud_vpc_subnet_name           = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name
  module_var_ibmcloud_vpc_availability_zone     = var.ibmcloud_vpc_availability_zone

  module_var_dns_root_domain_name = var.sap_vm_provision_dns_root_domain

}


#module "run_account_iam_module" {
#
#  depends_on = [
#    module.run_account_bootstrap_module
#  ]
#
#  count = var.ibmcloud_iam_yesno == "yes" ? 1 : 0
#
#  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/account_iam?ref=main"
#
#  module_var_resource_group_id = module.run_account_init_module.output_resource_group_id
#  module_var_resource_prefix   = var.sap_vm_provision_resource_prefix
#
#}


module "run_bastion_inject_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/bastion_inject?ref=main"

  module_var_resource_group_id = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix   = var.sap_vm_provision_resource_prefix
  module_var_resource_tags     = var.resource_tags

  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name

  module_var_bastion_user            = var.sap_vm_provision_bastion_user
  module_var_bastion_ssh_port        = var.sap_vm_provision_bastion_ssh_port
  module_var_bastion_ssh_key_id      = module.run_account_bootstrap_module.output_bastion_ssh_key_id
  module_var_bastion_public_ssh_key  = module.run_account_bootstrap_module.output_bastion_public_ssh_key
  module_var_bastion_private_ssh_key = module.run_account_bootstrap_module.output_bastion_private_ssh_key

  module_var_bastion_os_image = var.map_os_image_regex[var.sap_vm_provision_bastion_os_image]

}


module "run_host_network_access_sap_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/host_network_access_sap?ref=main"

  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name
  module_var_host_security_group_id   = module.run_account_bootstrap_module.output_host_security_group_id

  module_var_sap_hana_instance_no = var.sap_hana_install_instance_nr

}


module "run_host_network_access_sap_public_via_proxy_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/host_network_access_sap_public_via_proxy?ref=main"

  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name

  module_var_bastion_security_group_id = module.run_bastion_inject_module.output_bastion_security_group_id
  module_var_bastion_connection_security_group_id = module.run_bastion_inject_module.output_bastion_connection_security_group_id
  module_var_host_security_group_id   = module.run_account_bootstrap_module.output_host_security_group_id

  module_var_sap_hana_instance_no     = var.sap_hana_install_instance_nr

}


module "run_host_nfs_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/host_nfs?ref=main"

  module_var_resource_prefix          = var.sap_vm_provision_resource_prefix
  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name
  module_var_host_security_group_id   = module.run_account_bootstrap_module.output_host_security_group_id

  module_var_nfs_boolean_sapmnt   = sum(flatten(
    [
      for host in var.map_host_specifications[var.sap_vm_provision_host_specification_plan] :
        [ for storage_item in host["storage_definition"] : try(storage_item.nfs_path,"ignore") != "ignore" ? 1 : 0 ]
    ] )) >0 ? true : false

}


module "run_host_provision_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/host_provision?ref=main"

  # Set Terraform Module Variables using Terraform Variables at runtime

  module_var_resource_group_id = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix   = var.sap_vm_provision_resource_prefix
  module_var_resource_tags     = var.resource_tags

  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name

  module_var_bastion_user            = var.sap_vm_provision_bastion_user
  module_var_bastion_ssh_port        = var.sap_vm_provision_bastion_ssh_port
  module_var_bastion_private_ssh_key = module.run_account_bootstrap_module.output_bastion_private_ssh_key

  module_var_bastion_floating_ip                  = module.run_bastion_inject_module.output_bastion_ip
  module_var_bastion_connection_security_group_id = module.run_bastion_inject_module.output_bastion_connection_security_group_id

  module_var_host_ssh_key_id        = module.run_account_bootstrap_module.output_host_ssh_key_id
  module_var_host_private_ssh_key   = module.run_account_bootstrap_module.output_host_private_ssh_key
  module_var_host_security_group_id = module.run_account_bootstrap_module.output_host_security_group_id

  module_var_host_os_image = var.map_os_image_regex[var.sap_vm_provision_ibmcloud_vs_host_os_image]

  module_var_dns_root_domain_name  = var.sap_vm_provision_dns_root_domain
  module_var_dns_services_instance = module.run_account_bootstrap_module.output_host_dns_services_instance


  # Set Terraform Module Variables using for_each loop on a map Terraform Variable with nested objects

  for_each = toset([
    for key, value in var.map_host_specifications[var.sap_vm_provision_host_specification_plan] : key
  ])

  module_var_virtual_server_hostname = each.key

  module_var_virtual_server_profile = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].virtual_machine_profile

  module_var_disable_ip_anti_spoofing = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].disable_ip_anti_spoofing

  module_var_storage_definition = [ for storage_item in var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key]["storage_definition"] : storage_item if contains(keys(storage_item),"disk_size") && try(storage_item.swap_path,"") == "" ]

}
