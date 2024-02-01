
# Terraform declaration
terraform {
  required_version = ">= 1.0, <= 1.5.5"
  required_providers {
    azurerm = {
      #source  = "localdomain/provider/azurerm" // Local, on macOS path to place files would be $HOME/.terraform.d/plugins/localdomain/provider/azurerm/1.xx.xx/darwin_amd6
      source  = "hashicorp/azurerm" // Terraform Registry
      version = ">=2.90.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = ">=1.3.0"
    }
  }
}

# Terraform Provider declaration

provider "azurerm" {

  features {}

  tenant_id       = var.az_tenant_id       // Azure Tenant ID, linked to the Azure Active Directory instance
  subscription_id = var.az_subscription_id // Azure Subscription ID, linked to an Azure Tenant.  All resource groups belong to the Azure Subscription.

  client_id     = var.az_app_client_id     // Azure Client ID, defined in the Azure Active Directory instance; equivalent to Active Directory Application ID.
  client_secret = var.az_app_client_secret // Azure Application ID Password, defined in the Azure Active Directory instance

  # Role-based Access Control (RBAC) permissions control the actions for resources within the Azure Subscription.
  # The Roles are assigned to a Security Principal - which can be a User, Group, Service Principal or Managed Identity.

}

provider "azapi" {
  tenant_id       = var.az_tenant_id       // Azure Tenant ID, linked to the Azure Active Directory instance
  subscription_id = var.az_subscription_id // Azure Subscription ID, linked to an Azure Tenant.  All resource groups belong to the Azure Subscription.

  client_id     = var.az_app_client_id     // Azure Client ID, defined in the Azure Active Directory instance; equivalent to Active Directory Application ID.
  client_secret = var.az_app_client_secret // Azure Application ID Password, defined in the Azure Active Directory instance
}


module "run_account_init_module" {

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//msazure_vm/account_init?ref=main"

  module_var_az_resource_group_name           = local.resource_group_create_boolean ? 0 : var.az_resource_group_name
  module_var_az_resource_group_create_boolean = local.resource_group_create_boolean

  module_var_resource_prefix = var.sap_vm_provision_resource_prefix

  module_var_az_location_region               = var.az_location_region
  module_var_az_location_availability_zone_no = var.az_location_availability_zone_no

  module_var_az_vnet_name                = local.az_vnet_name_create_boolean ? 0 : var.az_vnet_name
  module_var_az_vnet_name_create_boolean = local.az_vnet_name_create_boolean

  module_var_az_vnet_subnet_name                = local.az_vnet_subnet_name_create_boolean ? 0 : var.az_vnet_subnet_name
  module_var_az_vnet_subnet_name_create_boolean = local.az_vnet_subnet_name_create_boolean

}


module "run_account_bootstrap_module" {

  depends_on = [
    module.run_account_init_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//msazure_vm/account_bootstrap?ref=main"

  module_var_az_resource_group_name = module.run_account_init_module.output_resource_group_name
  module_var_resource_prefix        = var.sap_vm_provision_resource_prefix

  module_var_az_location_region               = var.az_location_region
  module_var_az_location_availability_zone_no = var.az_location_availability_zone_no

  module_var_az_vnet_name        = module.run_account_init_module.output_vnet_name
  module_var_az_vnet_subnet_name = module.run_account_init_module.output_vnet_subnet_name

  module_var_dns_root_domain_name = var.sap_vm_provision_dns_root_domain
}


#module "run_account_iam_module" {
#
#  depends_on = [
#    module.run_account_bootstrap_module
#  ]
#
#  count = var.az_iam_yesno == "yes" ? 1 : 0
#
#  source = "github.com/sap-linuxlab/terraform.modules_for_sap//msazure_vm/account_iam?ref=main"
#
#  module_var_az_resource_group_name = module.run_account_init_module.output_resource_group_name
#  module_var_resource_prefix = var.sap_vm_provision_resource_prefix
#
#}


module "run_bastion_inject_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//msazure_vm/bastion_inject?ref=main"

  module_var_az_resource_group_name = module.run_account_init_module.output_resource_group_name
  module_var_resource_prefix        = var.sap_vm_provision_resource_prefix

  module_var_az_location_region               = var.az_location_region
  module_var_az_location_availability_zone_no = var.az_location_availability_zone_no

  module_var_az_vnet_name        = module.run_account_init_module.output_vnet_name
  module_var_az_vnet_subnet_name = module.run_account_init_module.output_vnet_subnet_name

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

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//msazure_vm/host_network_access_sap?ref=main"

  module_var_az_resource_group_name = module.run_account_init_module.output_resource_group_name

  module_var_az_vnet_name        = module.run_account_init_module.output_vnet_name
  module_var_az_vnet_subnet_name = module.run_account_init_module.output_vnet_subnet_name

  module_var_host_security_group_name = module.run_account_bootstrap_module.output_host_security_group_name

  module_var_sap_nwas_abap_ascs_instance_no = var.sap_nwas_abap_ascs_instance_no
  module_var_sap_nwas_abap_pas_instance_no  = var.sap_nwas_abap_pas_instance_no
  module_var_sap_hana_instance_no           = var.sap_hana_install_instance_nr

}


module "run_host_network_access_sap_public_via_proxy_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//msazure_vm/host_network_access_sap_public_via_proxy?ref=main"

  module_var_az_resource_group_name = module.run_account_init_module.output_resource_group_name

  module_var_az_vnet_name        = module.run_account_init_module.output_vnet_name
  module_var_az_vnet_subnet_name = module.run_account_init_module.output_vnet_subnet_name
  module_var_az_vnet_bastion_subnet_name = module.run_bastion_inject_module.output_vnet_bastion_subnet_name

  module_var_host_security_group_name               = module.run_account_bootstrap_module.output_host_security_group_name
  module_var_bastion_security_group_name            = module.run_bastion_inject_module.output_bastion_security_group_name
  module_var_bastion_connection_security_group_name = module.run_bastion_inject_module.output_bastion_connection_security_group_name

  module_var_sap_nwas_abap_pas_instance_no = var.sap_nwas_abap_pas_instance_no
  module_var_sap_hana_instance_no          = var.sap_hana_install_instance_nr

}


module "run_host_nfs_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//msazure_vm/host_nfs?ref=main"

  module_var_az_resource_group_name           = module.run_account_init_module.output_resource_group_name
  module_var_resource_prefix                  = var.sap_vm_provision_resource_prefix

  module_var_az_location_region               = var.az_location_region
  module_var_az_location_availability_zone_no = var.az_location_availability_zone_no

  module_var_az_vnet_name                     = module.run_account_init_module.output_vnet_name
  module_var_az_vnet_subnet_name              = module.run_account_init_module.output_vnet_subnet_name

  module_var_host_security_group_name         = module.run_account_bootstrap_module.output_host_security_group_name

  module_var_nfs_boolean_sapmnt   = sum(flatten(
    [
      for host in var.map_host_specifications[var.sap_vm_provision_host_specification_plan] :
        [ for storage_item in host["storage_definition"] : try(storage_item.nfs_path,"ignore") != "ignore" ? 1 : 0 ]
    ] )) >0 ? true : false


  module_var_dns_zone_name                    = module.run_account_bootstrap_module.output_dns_zone_name
}


module "run_host_provision_module" {

  depends_on = [
    module.run_account_init_module,
    module.run_account_bootstrap_module,
    module.run_bastion_inject_module
  ]

  source = "github.com/sap-linuxlab/terraform.modules_for_sap//msazure_vm/host_provision?ref=main"

  module_var_az_resource_group_name = module.run_account_init_module.output_resource_group_name
  module_var_resource_prefix        = var.sap_vm_provision_resource_prefix

  module_var_az_location_region               = var.az_location_region
  module_var_az_location_availability_zone_no = var.az_location_availability_zone_no

  module_var_az_vnet_name        = module.run_account_init_module.output_vnet_name
  module_var_az_vnet_subnet_name = module.run_account_init_module.output_vnet_subnet_name

  module_var_bastion_user             = var.sap_vm_provision_bastion_user
  module_var_bastion_ssh_port         = var.sap_vm_provision_bastion_ssh_port
  module_var_bastion_private_ssh_key  = module.run_account_bootstrap_module.output_bastion_private_ssh_key
  module_var_bastion_ip               = module.run_bastion_inject_module.output_bastion_ip
  module_var_bastion_connection_sg_id = module.run_bastion_inject_module.output_bastion_connection_security_group_id

  module_var_host_ssh_key_id      = module.run_account_bootstrap_module.output_host_ssh_key_id
  module_var_host_ssh_public_key  = module.run_account_bootstrap_module.output_host_public_ssh_key
  module_var_host_ssh_private_key = module.run_account_bootstrap_module.output_host_private_ssh_key
  module_var_host_sg_id           = module.run_account_bootstrap_module.output_host_security_group_id

  module_var_host_os_image = var.map_os_image_regex[var.sap_vm_provision_msazure_vm_host_os_image]

  module_var_dns_zone_name        = module.run_account_bootstrap_module.output_dns_zone_name
  module_var_dns_root_domain_name = var.sap_vm_provision_dns_root_domain


  # Set Terraform Module Variables using for_each loop on a map Terraform Variable with nested objects

  for_each = toset([
    for key, value in var.map_host_specifications[var.sap_vm_provision_host_specification_plan] : key
  ])

  module_var_host_name = each.key

  module_var_az_vm_instance = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].virtual_machine_profile
  module_var_disable_ip_anti_spoofing = var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key].disable_ip_anti_spoofing

  module_var_storage_definition = [ for storage_item in var.map_host_specifications[var.sap_vm_provision_host_specification_plan][each.key]["storage_definition"] : storage_item if contains(keys(storage_item),"disk_size") && try(storage_item.swap_path,"") == "" ]

}

