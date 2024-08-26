
# This file defines all Terraform Input Variables, with values to be provided interactively or using a vars file

locals {

  resource_group_create_boolean = var.ibmcloud_resource_group == "new" ? true : false

  ibmcloud_vpc_subnet_create_boolean = var.ibmcloud_vpc_subnet_name == "new" ? true : false

  ibmcloud_vpc_subnet_name_entry_is_ip = (
    can(
      regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)([/][0-3][0-2]?|[/][1-2][0-9]|[/][0-9])$",
        var.ibmcloud_vpc_subnet_name
      )
  ) ? true : false)

  ibmcloud_region = replace(var.ibmcloud_vpc_availability_zone, "/-[^-]*$/", "")

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


variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key"
}

variable "resource_tags" {
  type        = list(string)
  description = "Tags applied to each resource created"
  default = [ "sap" ]
}

variable "sap_vm_provision_resource_prefix" {
  description = "Prefix to resource names"
}

variable "ibmcloud_resource_group" {
  description = "Enter existing/target Resource Group name, or enter 'new' to create a Resource Group using the defined prefix for all resources"
}

variable "ibmcloud_vpc_availability_zone" {
  description = "Target IBM Cloud Availability Zone (e.g. us-south-1). The IBM Cloud Region will be calculated from this value"

  validation {
    error_message = "Please enter an IBM Cloud Availability Zone (e.g. us-south-1)."
    condition = can(regex("^([a-zA-Z0-9]*-[a-zA-Z0-9]*){2}$", var.ibmcloud_vpc_availability_zone))
  }

}

#variable "ibmcloud_iam_yesno" {
#  description = "Please choose 'yes' or 'no' for setup of default IBM Cloud Identity and Access Management (IAM) controls, for use by technicians to view and edit resources of SAP Systems run on IBM Cloud (NOTE: Requires admin privileges on API Key)"
#}

variable "ibmcloud_vpc_subnet_name" {
  description = "Enter existing/target VPC Subnet name, or enter 'new' to create a VPC with a default VPC Address Prefix Range. If using an existing VPC Subnet, it must be attached to a Public Gateway (i.e. SNAT)"
}

variable "sap_vm_provision_dns_root_domain" {
  description = "Root Domain for Private DNS used with the Virtual Server"
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



variable "map_os_image_regex" {

  description = "Map of operating systems OS Image regex, to identify latest OS Image for the OS major.minor version"

  type = map(any)

  default = {

    rhel-7-6-sap-ha = ".*redhat.*7-6.*amd64.*hana.*"

    rhel-8-1-sap-ha = ".*redhat.*8-1.*amd64.*hana.*"

    rhel-8-2-sap-ha = ".*redhat.*8-2.*amd64.*hana.*"

    rhel-8-4-sap-ha = ".*redhat.*8-4.*amd64.*hana.*"

    rhel-7-6-sap-applications = ".*redhat.*7-6.*amd64.*applications.*"

    rhel-8-1-sap-applications = ".*redhat.*8-1.*amd64.*applications.*"

    rhel-8-2-sap-applications = ".*redhat.*8-2.*amd64.*applications.*"

    rhel-8-4-sap-applications = ".*redhat.*8-4.*amd64.*applications.*"

    rhel-8-4 = ".*redhat.*8-4.*minimal.*amd64.*"

    sles-12-4-sap-ha = ".*sles.*12-4.*amd64.*hana.*"

    sles-15-1-sap-ha = ".*sles.*15-1.*amd64.*hana.*"

    sles-15-2-sap-ha = ".*sles.*15-2.*amd64.*hana.*"

    sles-12-4-sap-applications = ".*sles.*12-4.*amd64.*applications.*"

    sles-15-1-sap-applications = ".*sles.*15-1.*amd64.*applications.*"

    sles-15-2-sap-applications = ".*sles.*15-2.*amd64.*applications.*"

  }

}

variable "sap_vm_provision_host_specification_plan" {
  description = "Host specification plans are xsmall_256gb. This variable uses the locals mapping with a nested list of host specifications, and will alter host provisioning."
}

variable "sap_vm_provision_ibmcloud_vs_host_os_image" {
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
  description = "Ansible - SAP HANA - Instance Number (e.g. 90)"

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


variable "map_host_specifications" {
  description = "Map of host specficiations for SAP HANA single node install"
  type = map(any)


  default = {

    xsmall_256gb = {

      hana-p = {  // Hostname

        sap_host_type = "hana_primary" # hana_primary, nwas_ascs, nwas_pas, nwas_aas
        virtual_server_profile = "mx2-32x256"
        disable_ip_anti_spoofing = false

        storage_definition = [

          {
            name = "hana_data"
            mountpoint = "/hana/data"
            #disk_count = 1
            disk_size = 384
            #disk_type = gp3
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
            disk_size = 384
            filesystem_type = "xfs"
          },
          {
            name = "hana_shared"
            mountpoint = "/hana/shared"
            disk_size = 384
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
            disk_size = 100
            filesystem_type = "xfs"
          }

        ]

      }

    }

  }

}
