
locals {

  aws_vpc_subnet_create_boolean = var.aws_vpc_subnet_id == "new" ? true : false

  # Directories start with "C:..." on Windows; All other OSs use "/" for root.
  detect_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  detect_shell = substr(pathexpand("~"), 0, 1) == "/" ? true : false

  # Used for displaying Shell ssh connection output
  # /proc/version contains WSL subsstring, if detected then running Windows Subsystem for Linux
  not_wsl = fileexists("/proc/version") ? length(regexall("WSL", file("/proc/version"))) > 0 ? false : true : true

  # Used for displaying Windows PowerShell ssh connection output
  # /proc/version contains WSL subsstring, if detected then running Windows Subsystem for Linux
  is_wsl = fileexists("/proc/version") ? length(regexall("WSL", file("/proc/version"))) > 0 ? true : false : false

  aws_region = replace(var.aws_vpc_availability_zone,"/[a-c]$/","")

}


variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "sap_vm_provision_resource_prefix" {
  description = "Prefix to resource names"
}

variable "aws_vpc_availability_zone" {
  description = "Target AWS VPC Availability Zone (the AWS Region will be calculated from this value)"
}

variable "aws_vpc_subnet_id" {
  description = "Enter existing/target VPC Subnet ID, or enter 'new' to create a VPC with a default VPC prefix range"
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

  #validation {
  #  condition     = var.sap_vm_provision_bastion_ssh_port > 49152 && var.sap_vm_provision_bastion_ssh_port < 65535
  #  error_message = "Bastion host SSH Port must fall within IANA Dynamic Ports range (49152 to 65535)."
  #}
}


variable "map_os_image_regex" {
  description = "Map of operating systems OS Image regex, to identify latest OS Image for the OS major.minor version"
  type = map(any)

  default = {

    rhel-8-1 = "*RHEL-8.1*_HVM*x86_64*"

    rhel-8-2 = "*RHEL-8.2*_HVM*x86_64*"

    rhel-8-4 = "*RHEL-8.4*_HVM*x86_64*"

    rhel-8-6 = "*RHEL-8.6*_HVM*x86_64*"

    rhel-7-7-sap-ha = "*RHEL-SAP-7.7*"

    rhel-7-9-sap-ha = "*RHEL-SAP-7.9*"

    rhel-8-1-sap-ha = "*RHEL-SAP-8.1.0*"

    rhel-8-2-sap-ha = "*RHEL-SAP-8.2.0*"

    rhel-8-4-sap-ha = "*RHEL-SAP-8.4.0*"

    rhel-8-6-sap-ha = "*RHEL-SAP-8.6.0*"

    sles-15-2 = "*suse-sles-15-sp2-v202*-hvm-ssd-x86_64*"

    sles-15-3 = "*suse-sles-15-sp3-v202*-hvm-ssd-x86_64*"

    sles-15-4 = "*suse-sles-15-sp4-v202*-hvm-ssd-x86_64*"

    sles-12-5-sap-ha = "*suse-sles-sap-12-sp5-v202*-hvm-ssd-x86_64*"

    sles-15-1-sap-ha = "*suse-sles-sap-15-sp1-v202*-hvm-ssd-x86_64*"

    sles-15-2-sap-ha = "*suse-sles-sap-15-sp2-v202*-hvm-ssd-x86_64*"

    sles-15-3-sap-ha = "*suse-sles-sap-15-sp3-v202*-hvm-ssd-x86_64*"

    sles-15-4-sap-ha = "*suse-sles-sap-15-sp4-v202*-hvm-ssd-x86_64*"

  }
}

variable "sap_vm_provision_host_specification_plan" {
  description = "Host specification plans are xsmall_256gb. This variable uses the locals mapping with a nested list of host specifications, and will alter host provisioning."
}

variable "sap_vm_provision_aws_ec2_vs_host_os_image" {
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


variable "map_host_specifications" {
  description = "Map of host specficiations for SAP HANA single node install"
  type = map(any)


  default = {

    xsmall_256gb = {

      hana-p = {  // Hostname

        sap_host_type = "hana_primary" # hana_primary, nwas_ascs, nwas_pas, nwas_aas
        ec2_instance_type = "r5.8xlarge"
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
