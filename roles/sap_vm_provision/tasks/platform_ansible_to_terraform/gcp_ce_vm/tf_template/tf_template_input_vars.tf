
locals {

  gcp_vpc_subnet_create_boolean = var.gcp_vpc_subnet_name == "new" ? true : false

  gcp_region = replace(var.gcp_region_zone, "/-[^-]*$/", "")

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


variable "gcp_project" {
  description = "Target GCP Project ID"
}

variable "gcp_region_zone" {
  description = "Target GCP Zone, the GCP Region will be calculated from this value (e.g. europe-west9-a)"
}

variable "gcp_credentials_json" {
  description = "Enter path to GCP Key File for Service Account (or Google Application Default Credentials JSON file for GCloud CLI)"
}

variable "gcp_vpc_subnet_name" {
  description = "Enter existing/target VPC Subnet name, or enter 'new' to create a VPC"
}

variable "sap_vm_provision_resource_prefix" {
  description = "Prefix to resource names"
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

variable "sap_vm_provision_gcp_ce_vm_host_os_image" {
  description = "Host OS Image. This variable uses the locals mapping with regex of OS Images, and will alter host provisioning."
}

variable "sap_software_download_directory" {
  description = "Mount point for downloads of SAP Software"

  validation {
    error_message = "Directory must start with forward slash."
    condition = can(regex("^/", var.sap_software_download_directory))
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


# There is no Terraform Resource for data lookup of all GCP OS Images, therefore the input does not use wildcard
variable "map_os_image_regex" {

  description = "Map of operating systems OS Image, static OS Image names, to identify latest OS Image for the OS major.minor version"

  type = map(any)

  default = {

    rhel-8-latest = {
      project = "rhel-cloud"
      family  = "rhel-8"
    },

    rhel-7-7-sap-ha = {
      project = "rhel-sap-cloud"
      family  = "rhel-7-7-sap-ha"
    },

    rhel-7-9-sap-ha = {
      project = "rhel-sap-cloud"
      family  = "rhel-7-9-sap-ha"
    },

    rhel-8-1-sap-ha = {
      project = "rhel-sap-cloud"
      family  = "rhel-8-1-sap-ha"
    },

    rhel-8-2-sap-ha = {
      project = "rhel-sap-cloud"
      family  = "rhel-8-2-sap-ha"
    },

    rhel-8-4-sap-ha = {
      project = "rhel-sap-cloud"
      family  = "rhel-8-4-sap-ha"
    },

    rhel-8-6-sap-ha = {
      project = "rhel-sap-cloud"
      family  = "rhel-8-6-sap-ha"
    },

    sles-15-latest = {
      project = "suse-cloud"
      family  = "sles-15"
    },

    sles-12-sp5-sap = {
      project = "suse-sap-cloud"
      family  = "sles-12-sp5-sap"
    },

    sles-15-sp1-sap = {
      project = "suse-sap-cloud"
      family  = "sles-15-sp1-sap"
    },

    sles-15-sp2-sap = {
      project = "suse-sap-cloud"
      family  = "sles-15-sp2-sap"
    },

    sles-15-sp3-sap = {
      project = "suse-sap-cloud"
      family  = "sles-15-sp3-sap"
    },

    sles-15-sp4-sap = {
      project = "suse-sap-cloud"
      family  = "sles-15-sp4-sap"
    },

  }

}

variable "map_host_specifications" {
  description = "Map of host specficiations for SAP HANA single node install"
  type = map(any)


  default = {

    xsmall_256gb = {

      hana-p = {  // Hostname

        sap_host_type = "hana_primary" # hana_primary, nwas_ascs, nwas_pas, nwas_aas
        virtual_machine_profile = "n2-highmem-32" // 32 vCPU, 256GB Memory
        disable_ip_anti_spoofing = false

        storage_definition = [

          {
            name = "hana_data"
            mountpoint = "/hana/data"
            #disk_count = 1
            disk_size = 384
            disk_type = "pd-ssd"
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
            disk_size = 128
            disk_type = "pd-ssd"
            filesystem_type = "xfs"
          },
          {
            name = "hana_shared"
            mountpoint = "/hana/shared"
            disk_size = 320
            disk_type = "pd-balanced"
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
