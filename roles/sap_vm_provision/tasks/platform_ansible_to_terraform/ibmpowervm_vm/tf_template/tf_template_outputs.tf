
output "sap_host_list" {
  value = [
    for key in module.run_host_provision_module: {
      "output_host_name" : key.output_host_name ,
      "output_host_ip" : key.output_host_private_ip ,
      "output_host_os_user" : "root" ,
      "output_ansible_inventory_group" : var.map_host_specifications[var.sap_vm_provision_host_specification_plan][key.output_host_name].sap_host_type
#      "output_ansible_inventory_group" : can(regex("^hana.*",key.output_host_name)) ? "hana_primary" : can(regex("^nw.*",key.output_host_name)) ? can(regex(".*ascs.*",key.output_host_name)) ? "nwas_ascs" : can(regex(".*pas.*",key.output_host_name)) ? "nwas_pas" : can(regex(".*aas.*",key.output_host_name)) ? "nwas_aas" : "ERROR" : "ERROR"
    }
  ]
}


##############################################################
# Export SSH key to file on local
##############################################################

# Use path object to store key files temporarily in root of execution - https://www.terraform.io/docs/language/expressions/references.html#filesystem-and-workspace-info
resource "local_file" "hosts_rsa" {
  content         = module.run_host_bootstrap_module.output_host_private_ssh_key
  filename        = "${path.root}/ssh/hosts_rsa"
  file_permission = "0400"
}
