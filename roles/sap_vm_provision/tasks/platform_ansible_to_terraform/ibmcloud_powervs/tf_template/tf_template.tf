# Terraform declaration

terraform {
  required_version = ">= 1.0, <= 1.5.7"
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
  alias = "standard"
  # Define Provider inputs from given Terraform Variables
  ibmcloud_api_key = var.ibmcloud_api_key
  region = local.ibmcloud_region
  zone = lower(var.ibmcloud_powervs_location) // Required for IBM Power VS only
}

# Terraform Provider (with Alias) declaration - for IBM Power Infrastructure environment via IBM Cloud
provider "ibm" {
  alias = "powervs_secure_enclave"
  # Define Provider inputs from given Terraform Variables
  ibmcloud_api_key = var.ibmcloud_api_key
  region = local.ibmcloud_powervs_region // IBM Power VS Region
  zone = lower(var.ibmcloud_powervs_location) // IBM Power VS Location
}


module "run_account_init_module" {

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/account_init?ref=main"

  providers = { ibm = ibm.standard }

  module_var_resource_group_name           = local.resource_group_create_boolean ? 0 : var.ibmcloud_resource_group
  module_var_resource_group_create_boolean = local.resource_group_create_boolean

  module_var_resource_prefix = var.sap_vm_provision_resource_prefix

  module_var_ibmcloud_vpc_subnet_name           = local.ibmcloud_vpc_subnet_create_boolean ? 0 : var.ibmcloud_vpc_subnet_name
  module_var_ibmcloud_vpc_subnet_create_boolean = local.ibmcloud_vpc_subnet_create_boolean
  module_var_ibmcloud_vpc_availability_zone     = var.map_ibm_powervs_to_vpc_az[lower(var.ibmcloud_powervs_location)]

}


module "run_account_bootstrap_module" {

  depends_on = [
    module.run_account_init_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/account_bootstrap?ref=main"

  providers = { ibm = ibm.standard }

  module_var_resource_group_id = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix   = var.sap_vm_provision_resource_prefix

  module_var_ibmcloud_vpc_subnet_name           = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name
  module_var_ibmcloud_vpc_availability_zone     = var.map_ibm_powervs_to_vpc_az[lower(var.ibmcloud_powervs_location)]

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

  providers = { ibm = ibm.standard }

  module_var_resource_group_id = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix   = var.sap_vm_provision_resource_prefix
  module_var_resource_tags     = var.resource_tags

  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name

  module_var_bastion_user            = var.sap_vm_provision_bastion_user
  module_var_bastion_ssh_port        = var.sap_vm_provision_bastion_ssh_port
  module_var_bastion_ssh_key_id      = module.run_account_bootstrap_module.output_bastion_ssh_key_id
  module_var_bastion_public_ssh_key  = module.run_account_bootstrap_module.output_bastion_public_ssh_key
  module_var_bastion_private_ssh_key = module.run_account_bootstrap_module.output_bastion_private_ssh_key

  module_var_bastion_os_image = var.map_os_image_regex_bastion[var.sap_vm_provision_bastion_os_image]

}


module "run_host_network_access_sap_public_via_proxy_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/host_network_access_sap_public_via_proxy?ref=main"

  providers = { ibm = ibm.standard }

  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name

  module_var_bastion_security_group_id = module.run_bastion_inject_module.output_bastion_security_group_id
  module_var_bastion_connection_security_group_id = module.run_bastion_inject_module.output_bastion_connection_security_group_id
  module_var_host_security_group_id   = module.run_account_bootstrap_module.output_host_security_group_id

  module_var_sap_hana_instance_no     = var.sap_hana_install_instance_nr

}


module "run_account_bootstrap_powervs_workspace_module" {

  depends_on = [
    module.run_account_bootstrap_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_powervs/account_bootstrap_powervs_workspace?ref=main"

  # Define TF Module child provider name = TF Template parent provider name
  providers = {
    ibm.main = ibm.standard ,
    ibm.powervs_secure_enclave = ibm.powervs_secure_enclave
  }

  module_var_resource_group_id        = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix          = var.sap_vm_provision_resource_prefix
  module_var_ibmcloud_power_zone      = lower(var.ibmcloud_powervs_location)
  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name

}


module "run_account_bootstrap_powervs_networks_module" {

  depends_on = [
    module.run_account_bootstrap_module,
    module.run_account_bootstrap_powervs_workspace_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_powervs/account_bootstrap_powervs_networks?ref=main"

  # Define TF Module child provider name = TF Template parent provider name
  providers = {
    ibm.main = ibm.standard ,
    ibm.powervs_secure_enclave = ibm.powervs_secure_enclave
  }

  module_var_resource_group_id               = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix                 = var.sap_vm_provision_resource_prefix
  module_var_ibmcloud_power_zone             = lower(var.ibmcloud_powervs_location)
  module_var_ibmcloud_powervs_workspace_guid = module.run_account_bootstrap_powervs_workspace_module.output_power_guid
  module_var_ibmcloud_vpc_crn                = module.run_account_bootstrap_powervs_workspace_module.output_power_target_vpc_crn
  module_var_ibmcloud_tgw_instance_name      = module.run_account_bootstrap_module.output_tgw_name

}


module "run_powervs_interconnect_sg_update_module" {

  depends_on = [
    module.run_bastion_inject_module,
    module.run_account_bootstrap_powervs_networks_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/powervs_interconnect_sg_update?ref=main"

  providers = { ibm = ibm.standard }

  module_var_bastion_security_group_id    = module.run_bastion_inject_module.output_bastion_security_group_id
  module_var_host_security_group_id       = module.run_account_bootstrap_module.output_host_security_group_id

  module_var_power_network_private_subnet = module.run_account_bootstrap_powervs_networks_module.output_power_network_private_subnet

}


module "run_powervs_interconnect_proxy_provision_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module,
    module.run_powervs_interconnect_sg_update_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_vs/powervs_interconnect_proxy_provision?ref=main"

  providers = { ibm = ibm.standard }

  # Set Terraform Module Variables using Terraform Variables at runtime

  module_var_resource_group_id = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix   = var.sap_vm_provision_resource_prefix
  module_var_resource_tags     = var.resource_tags

  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name

  module_var_bastion_user            = var.sap_vm_provision_bastion_user
  module_var_bastion_ssh_port        = var.sap_vm_provision_bastion_ssh_port
  module_var_bastion_public_ssh_key  = module.run_account_bootstrap_module.output_bastion_public_ssh_key
  module_var_bastion_private_ssh_key = module.run_account_bootstrap_module.output_bastion_private_ssh_key

  module_var_bastion_floating_ip                  = module.run_bastion_inject_module.output_bastion_ip
  module_var_bastion_connection_security_group_id = module.run_bastion_inject_module.output_bastion_connection_security_group_id

  module_var_host_ssh_key_id        = module.run_account_bootstrap_module.output_host_ssh_key_id
  module_var_host_private_ssh_key   = module.run_account_bootstrap_module.output_host_private_ssh_key
  module_var_host_security_group_id = module.run_account_bootstrap_module.output_host_security_group_id

  module_var_proxy_os_image = var.map_os_image_regex_bastion[var.sap_vm_provision_bastion_os_image]

  module_var_dns_root_domain_name  = var.sap_vm_provision_dns_root_domain
  module_var_dns_services_instance = module.run_account_bootstrap_module.output_host_dns_services_instance

  module_var_virtual_server_hostname = "${var.sap_vm_provision_resource_prefix}-powervs-proxy"

  module_var_virtual_server_profile = "cx2-8x16"

}


module "run_host_provision_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module,
    module.run_powervs_interconnect_sg_update_module,
    module.run_powervs_interconnect_proxy_provision_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//ibmcloud_powervs/host_provision?ref=main"

  # Define TF Module child provider name = TF Template parent provider name
  providers = {
    ibm.main = ibm.standard ,
    ibm.powervs_secure_enclave = ibm.powervs_secure_enclave
  }

  module_var_resource_group_id = module.run_account_init_module.output_resource_group_id
  module_var_resource_prefix   = var.sap_vm_provision_resource_prefix
  module_var_resource_tags     = var.resource_tags

  module_var_ibm_power_guid = module.run_account_bootstrap_powervs_workspace_module.output_power_guid
  module_var_power_networks = module.run_account_bootstrap_powervs_networks_module.output_power_networks

  module_var_ibmcloud_vpc_subnet_name = local.ibmcloud_vpc_subnet_create_boolean ? module.run_account_init_module.output_vpc_subnet_name : var.ibmcloud_vpc_subnet_name

  module_var_bastion_user            = var.sap_vm_provision_bastion_user
  module_var_bastion_ssh_port        = var.sap_vm_provision_bastion_ssh_port
  module_var_bastion_private_ssh_key = module.run_account_bootstrap_module.output_bastion_private_ssh_key
  module_var_bastion_ip              = module.run_bastion_inject_module.output_bastion_ip

  module_var_host_public_ssh_key  = module.run_account_bootstrap_module.output_host_public_ssh_key
  module_var_host_private_ssh_key = module.run_account_bootstrap_module.output_host_private_ssh_key

  module_var_host_os_image = var.map_os_image_regex[var.sap_vm_provision_ibmcloud_powervs_host_os_image]

  module_var_dns_root_domain_name  = var.sap_vm_provision_dns_root_domain
  module_var_dns_services_instance = module.run_account_bootstrap_module.output_host_dns_services_instance

  module_var_dns_custom_resolver_ip = module.run_powervs_interconnect_proxy_provision_module.output_dns_custom_resolver_ip

  module_var_web_proxy_enable    = true
  module_var_web_proxy_url       = "http://${module.run_powervs_interconnect_proxy_provision_module.output_proxy_private_ip}:${module.run_powervs_interconnect_proxy_provision_module.output_proxy_port_squid}"
  module_var_web_proxy_exclusion = "localhost,127.0.0.1,${var.sap_vm_provision_dns_root_domain}" // Web Proxy exclusion list for hosts running on IBM Power (e.g. localhost,127.0.0.1,custom.root.domain)

  module_var_os_vendor_enable                = false # After Terraform has provisioned hosts, this will be done by Ansible
  module_var_os_vendor_account_user          = ""
  module_var_os_vendor_account_user_passcode = ""

  # Set Terraform Module Variables using for_each loop on a map Terraform Variable with nested objects

  for_each = toset([
    for key, value in var.map_host_specifications[var.sap_vm_provision_host_specification_plan] : key
  ])

  module_var_virtual_server_hostname = each.key

  module_var_hardware_machine_type  = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].ibmcloud_powervs_hardware_machine_type
  module_var_virtual_server_profile = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].virtual_machine_profile

  module_var_storage_definition = [ for storage_item in var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key]["storage_definition"] : storage_item if contains(keys(storage_item),"disk_size") && try(storage_item.swap_path,"") == "" ]

}
