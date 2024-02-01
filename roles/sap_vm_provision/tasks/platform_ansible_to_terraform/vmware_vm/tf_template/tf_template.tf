# Terraform declaration
terraform {
  required_version = ">= 1.0, <= 1.5.7"
  required_providers {
    vsphere = {
#      source  = "localdomain/provider/vsphere" // Local, on macOS path to place files would be $HOME/.terraform.d/plugins/localdomain/provider/vsphere/1.xx.xx/darwin_amd6
      source = "hashicorp/vsphere"
      version = ">=2.6.0"
    }
  }
}

# Terraform Provider declaration
provider "vsphere" {

  # Define Provider inputs from given Terraform Variables
  user           = var.vmware_vcenter_user
  password       = var.vmware_vcenter_user_password
  vsphere_server = var.vmware_vcenter_server

  # Self-signed certificate
  allow_unverified_ssl = true

}


module "run_host_bootstrap_module" {

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//vmware_vm/host_bootstrap?ref=main"

}


module "run_host_provision_module" {

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//vmware_vm/host_provision?ref=main"

  # Set Terraform Module Variables using Terraform Variables at runtime

  module_var_resource_prefix = var.sap_vm_provision_resource_prefix

  module_var_host_public_ssh_key  = module.run_host_bootstrap_module.output_host_public_ssh_key
  module_var_host_private_ssh_key = module.run_host_bootstrap_module.output_host_private_ssh_key


  module_var_vmware_vcenter_server = var.vmware_vcenter_server
  module_var_vmware_vcenter_user = var.vmware_vcenter_user
  module_var_vmware_vcenter_user_password = var.vmware_vcenter_user_password

  module_var_vmware_vsphere_datacenter_name = var.vmware_vsphere_datacenter_name
  module_var_vmware_vsphere_datacenter_compute_cluster_name = var.vmware_vsphere_datacenter_compute_cluster_name
  module_var_vmware_vsphere_datacenter_compute_cluster_host_fqdn = var.vmware_vsphere_datacenter_compute_cluster_host_fqdn

  module_var_vmware_vsphere_datacenter_compute_cluster_folder_name = var.vmware_vsphere_datacenter_compute_cluster_folder_name
  module_var_vmware_vsphere_datacenter_storage_datastore_name = var.vmware_vsphere_datacenter_storage_datastore_name
  module_var_vmware_vsphere_datacenter_network_primary_name = var.vmware_vsphere_datacenter_network_primary_name

  module_var_vmware_vm_template_name = var.vmware_vm_template_name

  module_var_vmware_vm_dns_root_domain_name = var.sap_vm_provision_dns_root_domain

  # Set Terraform Module Variables using for_each loop on a map Terraform Variable with nested objects

  for_each = toset([
    for key, value in var.map_host_specifications[var.sap_vm_provision_host_specification_plan] : key
  ])

  module_var_vmware_vm_hostname = each.key

  module_var_vmware_vm_compute_cpu_threads = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].vmware_vm_cpu_threads
  module_var_vmware_vm_compute_ram_gb = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].vmware_vm_memory_gib

  module_var_storage_definition = [ for storage_item in var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key]["storage_definition"] : storage_item if contains(keys(storage_item),"disk_size") && try(storage_item.swap_path,"") == "" ]

  module_var_web_proxy_enable = false
  module_var_os_vendor_enable = false

  module_var_web_proxy_url       = ""
  module_var_web_proxy_exclusion = ""

  module_var_os_vendor_account_user          = ""
  module_var_os_vendor_account_user_passcode = ""
  module_var_os_systems_mgmt_host            = ""

}
