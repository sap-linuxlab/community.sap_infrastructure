
# Terraform declaration

terraform {
  required_version = ">= 1.0, <= 1.5.5"
  required_providers {
    google = {
      #source  = "localdomain/provider/google" // Local, on macOS path to place files would be $HOME/.terraform.d/plugins/localdomain/provider/google/1.xx.xx/darwin_amd6
      source  = "hashicorp/google" // Terraform Registry
      version = ">=4.50.0"
    }
  }
}

# Terraform Provider declaration
#
# Nested provider configurations cannot be used with depends_on meta-argument between modules
#
# The calling module block can use either:
# - "providers" argument in the module block
# - none, inherit default (un-aliased) provider configuration
#
# Therefore the below is blank and is only for reference if this module needs to be executed manually


# Terraform Provider declaration

provider "google" {
  project     = var.gcp_project
  region      = local.gcp_region
  zone        = var.gcp_region_zone

  credentials = var.gcp_credentials_json

}


module "run_account_init_module" {

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//gcp_ce_vm/account_init?ref=main"

  module_var_resource_prefix                = var.sap_vm_provision_resource_prefix

  module_var_gcp_region                     = local.gcp_region
  module_var_gcp_vpc_subnet_create_boolean  = local.gcp_vpc_subnet_create_boolean
  module_var_gcp_vpc_subnet_name            = local.gcp_vpc_subnet_create_boolean ? 0 : var.gcp_vpc_subnet_name

}


module "run_account_bootstrap_module" {

  depends_on = [
    module.run_account_init_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//gcp_ce_vm/account_bootstrap?ref=main"

  module_var_resource_prefix                = var.sap_vm_provision_resource_prefix

  module_var_gcp_vpc_subnet_name            = module.run_account_init_module.output_vpc_subnet_name

  module_var_dns_root_domain_name           = var.sap_vm_provision_dns_root_domain

}


module "run_bastion_inject_module" {

  depends_on = [
    module.run_account_bootstrap_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//gcp_ce_vm/bastion_inject?ref=main"

  module_var_resource_prefix                = var.sap_vm_provision_resource_prefix

  module_var_gcp_region                     = local.gcp_region
  module_var_gcp_region_zone                = var.gcp_region_zone
  module_var_gcp_vpc_subnet_name            = module.run_account_init_module.output_vpc_subnet_name

  module_var_bastion_user                   = var.sap_vm_provision_bastion_user
  module_var_bastion_ssh_port               = var.sap_vm_provision_bastion_ssh_port
  module_var_bastion_os_image               = var.map_os_image_regex[var.sap_vm_provision_bastion_os_image]

  module_var_bastion_private_ssh_key        = module.run_account_bootstrap_module.output_bastion_private_ssh_key
  module_var_bastion_public_ssh_key         = module.run_account_bootstrap_module.output_bastion_public_ssh_key

}


module "run_host_network_access_sap_module" {

  depends_on = [
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//gcp_ce_vm/host_network_access_sap?ref=main"

  module_var_resource_prefix                = var.sap_vm_provision_resource_prefix

  module_var_gcp_vpc_subnet_name            = module.run_account_init_module.output_vpc_subnet_name

  module_var_sap_nwas_abap_ascs_instance_no = var.sap_nwas_abap_ascs_instance_no
  module_var_sap_nwas_abap_pas_instance_no  = var.sap_nwas_abap_pas_instance_no
  module_var_sap_hana_instance_no           = var.sap_hana_install_instance_nr

}


module "run_host_network_access_sap_public_via_proxy_module" {

  depends_on = [
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//gcp_ce_vm/host_network_access_sap_public_via_proxy?ref=main"

  module_var_resource_prefix                = var.sap_vm_provision_resource_prefix

  module_var_gcp_vpc_subnet_name            = module.run_account_init_module.output_vpc_subnet_name

  module_var_sap_hana_instance_no           = var.sap_hana_install_instance_nr
  module_var_sap_nwas_abap_pas_instance_no  = var.sap_nwas_abap_pas_instance_no

  module_var_bastion_subnet_name = module.run_bastion_inject_module.output_bastion_subnet_name

}


module "run_host_nfs_module" {

  depends_on = [
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//gcp_ce_vm/host_nfs?ref=main"

  module_var_resource_prefix                = var.sap_vm_provision_resource_prefix

  module_var_gcp_region_zone                = var.gcp_region_zone
  module_var_gcp_vpc_subnet_name            = module.run_account_init_module.output_vpc_subnet_name

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
    module.run_bastion_inject_module,
    module.run_host_nfs_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//gcp_ce_vm/host_provision?ref=main"

  # Set Terraform Module Variables using Terraform Variables at runtime

  module_var_resource_prefix                = var.sap_vm_provision_resource_prefix

  module_var_gcp_region_zone                = var.gcp_region_zone
  module_var_gcp_vpc_subnet_name            = module.run_account_init_module.output_vpc_subnet_name

  module_var_dns_root_domain_name           = var.sap_vm_provision_dns_root_domain
  module_var_dns_zone_name                  = module.run_account_bootstrap_module.output_dns_zone_name

  module_var_host_os_image                  = var.map_os_image_regex[var.sap_vm_provision_gcp_ce_vm_host_os_image]

  module_var_bastion_ssh_port               = var.sap_vm_provision_bastion_ssh_port
  module_var_bastion_user                   = var.sap_vm_provision_bastion_user
  module_var_bastion_private_ssh_key        = module.run_account_bootstrap_module.output_bastion_private_ssh_key
  module_var_bastion_ip                     = module.run_bastion_inject_module.output_bastion_ip

  module_var_host_ssh_public_key            = module.run_account_bootstrap_module.output_host_public_ssh_key
  module_var_host_ssh_private_key           = module.run_account_bootstrap_module.output_host_private_ssh_key



  # Set Terraform Module Variables using for_each loop on a map Terraform Variable with nested objects

  for_each = toset([
    for key, value in var.map_host_specifications[var.sap_vm_provision_host_specification_plan] : key
  ])

  module_var_virtual_machine_hostname = each.key

  module_var_virtual_machine_profile  = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].virtual_machine_profile
  module_var_disable_ip_anti_spoofing = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].disable_ip_anti_spoofing

  module_var_storage_definition = [ for storage_item in var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key]["storage_definition"] : storage_item if contains(keys(storage_item),"disk_size") && try(storage_item.swap_path,"") == "" ]

}


