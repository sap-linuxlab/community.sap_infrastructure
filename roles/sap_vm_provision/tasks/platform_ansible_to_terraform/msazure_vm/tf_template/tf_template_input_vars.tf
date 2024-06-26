
locals {

  resource_group_create_boolean = var.az_resource_group_name == "new" ? true : false

  az_vnet_name_create_boolean = var.az_vnet_name == "new" ? true : false

  az_vnet_subnet_name_create_boolean = var.az_vnet_subnet_name == "new" ? true : false

  # Directories start with "C:..." on Windows; All other OSs use "/" for root.
  detect_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  detect_shell = substr(pathexpand("~"), 0, 1) == "/" ? true : false

  # Used for displaying Shell ssh connection output
  # /proc/version contains WSL subsstring, if detected then running Windows Subsystem for Linux
  not_wsl = fileexists("/proc/version") ? length(regexall("WSL", file("/proc/version"))) > 0 ? false : true : true

  # Used for displaying Windows PowerShell ssh connection output
  # /proc/version contains WSL subsstring, if detected then running Windows Subsystem for Linux
  is_wsl = fileexists("/proc/version") ? length(regexall("WSL", file("/proc/version"))) > 0 ? true : false : false

}


variable "az_tenant_id" {
  description = "Azure Tenant ID"
}

variable "az_subscription_id" {
  description = "Azure Subscription ID"
}

variable "az_app_client_id" {
  description = "Azure AD App Client ID"
}

variable "az_app_client_secret" {
  description = "Azure AD App Client Secret"
}

variable "sap_vm_provision_resource_prefix" {
  description = "Enter prefix to resource names"
}

variable "az_resource_group_name" {
  description = "Enter existing/target Azure Resource Group name, or enter 'new' to create a Resource Group using the defined prefix for all resources"
}

variable "az_location_region" {
  description = "Target Azure Region aka. Azure Location Display Name (e.g. 'West Europe')"
}

variable "az_location_availability_zone_no" {
  description = "Target Azure Availability Zone (e.g. 1)"
}

variable "az_vnet_name" {
  description = "Enter existing/target Azure VNet name, or enter 'new' to create a VPC with a default VPC Address Prefix Range (cannot be 'new' if using existing VNet Subnet)"
}

variable "az_vnet_subnet_name" {
  description = "Enter existing/target Azure VNet Subnet name, or enter 'new' to create a VPC with a default VPC Address Prefix Range (if using existing VNet, ensure default subnet range matches to VNet address space and does not conflict with existing Subnet)"
}

variable "sap_vm_provision_dns_root_domain" {
  description = "Root Domain for Private DNS used with the Virtual Machine"
}

variable "sap_vm_provision_bastion_os_image" {
  description = "Bastion OS Image. This variable uses the locals mapping with regex of OS Images, and will alter bastion provisioning."
}

variable "sap_vm_provision_bastion_user" {
  description = "OS User to create on Bastion host to avoid pass-through root user (e.g. bastionuser)"
}

variable "sap_vm_provision_bastion_ssh_port" {
  type        = number
  description = "Bastion host SSH Port from IANA Dynamic Ports range (49152 to 65535)"

  validation {
    condition     = var.sap_vm_provision_bastion_ssh_port > 49152 && var.sap_vm_provision_bastion_ssh_port < 65535
    error_message = "Bastion host SSH Port must fall within IANA Dynamic Ports range (49152 to 65535)."
  }
}

variable "sap_vm_provision_host_specification_plan" {
  description = "Host specification plans are xsmall_256gb. This variable uses the locals mapping with a nested list of host specifications, and will alter host provisioning."
}

variable "sap_vm_provision_msazure_vm_host_os_image" {
  description = "Host OS Image. This variable uses the locals mapping with regex of OS Images, and will alter host provisioning."
}

variable "sap_install_media_detect_source_directory" {
  description = "Mount point for downloads of SAP Software"

  validation {
    error_message = "Directory must start with forward slash."
    condition = can(regex("^/", var.sap_install_media_detect_source_directory))
  }

}


variable "sap_hana_install_instance_nr" {
  description = "Ansible - SAP HANA install: Instance Number (e.g. 90)"

  validation {
    error_message = "Cannot use Instance Number 43 (HA port number) or 89 (Windows Remote Desktop Services)."
    condition = !can(regex("(43|89)", var.sap_hana_install_instance_nr))
  }

}


variable "sap_nwas_abap_ascs_instance_no" {
  description = "Ansible - SAP NetWeaver AS (ABAP) - ABAP Central Services (ASCS) instance number"

  validation {
    error_message = "Cannot use Instance Number 43 (HA port number) or 89 (Windows Remote Desktop Services)."
    condition = !can(regex("(43|89)", var.sap_nwas_abap_ascs_instance_no))
  }

}

variable "sap_nwas_abap_pas_instance_no" {
  description = "Ansible - SAP NetWeaver AS (ABAP) - Primary Application Server instance number"

  validation {
    error_message = "Cannot use Instance Number 43 (HA port number) or 89 (Windows Remote Desktop Services)."
    condition = !can(regex("(43|89)", var.sap_nwas_abap_pas_instance_no))
  }

}

variable "map_os_image_regex" {

  description = "Map of operating systems OS Image regex, to identify latest OS Image for the OS major.minor version"

  type = map(any)

  default = {

    rhel-8-4 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "84-gen2"
    },

    rhel-8-1-sap-ha = {
      publisher = "RedHat"
      offer     = "RHEL-SAP-HA"
      sku       = "81sapha-gen2"
    },

    rhel-8-2-sap-ha = {
      publisher = "RedHat"
      offer     = "RHEL-SAP-HA"
      sku       = "82sapha-gen2"
    },

    rhel-8-4-sap-ha = {
      publisher = "RedHat"
      offer     = "RHEL-SAP-HA"
      sku       = "84sapha-gen2"
    },

    rhel-8-1-sap-applications = {
      publisher = "RedHat"
      offer     = "RHEL-SAP-APPS"
      sku       = "81sapapps-gen2"
    },

    rhel-8-2-sap-applications = {
      publisher = "RedHat"
      offer     = "RHEL-SAP-APPS"
      sku       = "82sapapps-gen2"
    },

    rhel-8-4-sap-applications = {
      publisher = "RedHat"
      offer     = "RHEL-SAP-APPS"
      sku       = "84sapapps-gen2"
    }

  }

}



variable "map_host_specifications" {
  description = "Map of host specficiations for SAP HANA single node install"
  type = map(any)

  default = {

    xsmall_256gb = {

      hana-p = {  // Hostname

        sap_host_type = "hana_primary" # hana_primary, nwas_ascs, nwas_pas, nwas_aas
        vm_instance = "Standard_D32s_v5"
        disable_ip_anti_spoofing = false

        storage_definition = [

          {
            name = "hana_data"
            mountpoint = "/hana/data"
            disk_count = 4
            disk_size = 64
            disk_type = "P6"
            #disk_iops =
            filesystem_type = "xfs"
            #lvm_lv_name =
            #lvm_lv_stripes =
            #lvm_lv_stripe_size =
            #lvm_vg_name =
            #lvm_vg_options =
            #lvm_vg_physical_extent_size =
            #lvm_pv_device =
            #lvm_pv_options =
            #nfs_path =
            #nfs_server =
            #nfs_filesystem_type =
            #nfs_mount_options =
          },
          {
            name = "hana_log"
            mountpoint = "/hana/log"
            disk_count = 3
            disk_size = 128
            disk_type = "P10"
            filesystem_type = "xfs"
          },
          {
            name = "hana_shared"
            mountpoint = "/hana/shared"
            disk_size = 256
            disk_type = "P15"
            filesystem_type = "xfs"
          },
          {
            name = "swap"
            mountpoint = "/swapfile"
            disk_size = 2
            filesystem_type = "swap"
          },
          {
            name = "software"
            mountpoint = "/software"
            disk_size = 128
            disk_type = "P10"
            filesystem_type = "xfs"
          }

        ]

      }

    }

  }

}
