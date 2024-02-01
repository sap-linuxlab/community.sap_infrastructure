
locals {
  ibmpowervc_template_compute_name_create_boolean = var.ibmpowervc_template_compute_name == "new" ? true : false
  #ibmpowervc_template_storage_name_create_boolean = var.ibmpowervc_template_storage_name == "new" ? true : false
}


variable "ibmpowervc_auth_endpoint" {
  description = "IBM PowerVC: Authentication Endpoint (e.g. https://powervc-host:5000/v3/)"
}

variable "ibmpowervc_user" {
  description = "IBM PowerVC: Username"
}

variable "ibmpowervc_user_password" {
  description = "IBM PowerVC: User Password"
}

variable "ibmpowervc_project_name" {
  description = "IBM PowerVC: Project Name"
}

variable "ibmpowervc_host_group_name" {
  description = "IBM PowerVC: Host Group Name"
}

variable "ibmpowervc_network_name" {
  description = "IBM PowerVC: Network Name"
}

variable "ibmpowervc_template_compute_name" {
  description = "IBM PowerVC: Enter 'new' to create a Compute Template from the CPU and RAM in the host specification plan, or use an existing/target Compute Template Name"
}

variable "ibmpowervc_storage_storwize_hostname_short" {
  description = "IBM PowerVC - Storage with IBM Storwize: Hostname short (e.g. v7000)"
}

variable "ibmpowervc_storage_storwize_storage_pool" {
  description = "IBM PowerVC - Storage with IBM Storwize: Storage Pool (e.g. V7000_01)"
}

variable "ibmpowervc_storage_storwize_storage_pool_flash" {
  description = "IBM PowerVC - Storage with IBM Storwize: Storage Pool with Flash Storage (e.g. FS900_01)"
}

variable "ibmpowervc_os_image_name" {
  description = "IBM PowerVC: OS Image Name"
}


variable "sap_vm_provision_resource_prefix" {
  description = "Prefix to resource names"
}

variable "sap_vm_provision_dns_root_domain" {
  description = "Root Domain for Private DNS used with the Virtual Server"
}

variable "sap_vm_provision_host_specification_plan" {
  description = "Host specification plans are xsmall_256gb. This variable uses the locals mapping with a nested list of host specifications, and will alter host provisioning."
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


variable "map_host_specifications" {

  description = "Map of host specficiations for SAP BW/4HANA single node install"

  type = map(any)

  default = {

    small_256gb = {

      bwh01 = { // Hostname
        ibmpowervc_compute_cpu_threads = 32
        ibmpowervc_compute_ram_gb      = 256
        storage_definition = [
          {
            name = "hana_data"
            mountpoint = "/hana/data"
            disk_size = 512
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
            filesystem_type = "xfs"
          },
          {
            name = "hana_shared"
            mountpoint = "/hana/shared"
            disk_size = 256
            filesystem_type = "xfs"
          },
          {
            name = "usr_sap"
            mountpoint = "/usr/sap"
            disk_size = 96
            filesystem_type = "xfs"
          },
          {
            name = "sapmnt"
            mountpoint = "/sapmnt"
            disk_size = 96
            filesystem_type = "xfs"
          },
          {
            name = "swap"
            mountpoint = "/swap"
            disk_size = 32
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
