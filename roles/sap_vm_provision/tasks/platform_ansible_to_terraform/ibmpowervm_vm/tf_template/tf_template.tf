# Terraform declaration
terraform {
  required_version = ">= 1.0, <= 1.5.7"
  required_providers {
    openstack = {
      #source  = "localdomain/provider/openstack" // Local, on macOS path to place files would be $HOME/.terraform.d/plugins/localdomain/provider/openstack/1.xx.xx/darwin_amd6
      source  = "terraform-provider-openstack/openstack"
      version = "1.45.0"
    }
  }
}

# Terraform Provider declaration
provider "openstack" {

  # Define Provider inputs from given Terraform Variables
  auth_url  = var.ibmpowervc_auth_endpoint
  user_name = var.ibmpowervc_user
  password  = var.ibmpowervc_user_password

  tenant_name = var.ibmpowervc_project_name
  #domain_name = "Default"
  insecure = true
}


module "run_host_bootstrap_module" {

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmpowervc/host_bootstrap?ref=main"

  # Set Terraform Module Variables using Terraform Variables at runtime
  module_var_resource_prefix = var.sap_vm_provision_resource_prefix

}


module "run_host_provision_module" {

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmpowervc/host_provision?ref=main"

  # Set Terraform Module Variables using Terraform Variables at runtime

  module_var_ibmpowervc_template_compute_name                = local.ibmpowervc_template_compute_name_create_boolean ? 0 : var.ibmpowervc_template_compute_name
  module_var_ibmpowervc_template_compute_name_create_boolean = local.ibmpowervc_template_compute_name_create_boolean

  module_var_resource_prefix = var.sap_vm_provision_resource_prefix

  module_var_host_ssh_key_name    = module.run_host_bootstrap_module.output_host_ssh_key_name
  module_var_host_public_ssh_key  = module.run_host_bootstrap_module.output_host_public_ssh_key
  module_var_host_private_ssh_key = module.run_host_bootstrap_module.output_host_private_ssh_key

  module_var_ibmpowervc_host_group_name = var.ibmpowervc_host_group_name
  module_var_ibmpowervc_network_name    = var.ibmpowervc_network_name

  module_var_ibmpowervc_compute_cpu_threads = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].ibmpowervm_vm_cpu_threads
  module_var_ibmpowervc_compute_ram_gb      = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].ibmpowervm_vm_memory_gib

  module_var_ibmpowervc_os_image_name = var.ibmpowervc_os_image_name

  module_var_dns_root_domain_name = var.sap_vm_provision_dns_root_domain

  # Set Terraform Module Variables using for_each loop on a map Terraform Variable with nested objects

  for_each = toset([
    for key, value in var.map_host_specifications[var.sap_vm_provision_host_specification_plan] : key
  ])

  module_var_lpar_hostname = each.key

  module_var_ibmpowervc_storage_storwize_hostname_short     = var.ibmpowervc_storage_storwize_hostname_short
  module_var_ibmpowervc_storage_storwize_storage_pool       = var.ibmpowervc_storage_storwize_storage_pool
  module_var_ibmpowervc_storage_storwize_storage_pool_flash = var.ibmpowervc_storage_storwize_storage_pool_flash

  module_var_storage_definition = [ for storage_item in var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key]["storage_definition"] : storage_item if contains(keys(storage_item),"disk_size") && try(storage_item.swap_path,"") == "" ]

  module_var_web_proxy_enable = false
  module_var_os_vendor_enable = false

  module_var_web_proxy_url       = ""
  module_var_web_proxy_exclusion = ""

  module_var_os_vendor_account_user          = ""
  module_var_os_vendor_account_user_passcode = ""
  module_var_os_systems_mgmt_host            = ""

}
