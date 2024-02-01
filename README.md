# community.sap_infrastructure Ansible Collection

![Ansible Lint](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint.yml/badge.svg?branch=main)

This Ansible Collection executes various SAP Infrastructure related tasks, creating resources needed for hosts of SAP Systems.

These Ansible Roles are often run first and combined with other Ansible Collections to provide end-to-end automation.

Various Infrastructure Platforms (Cloud Hyperscalers and Hypervisors) are compatible and tested with this Ansible Collection.


**Please read the [full documentation](./docs#readme) for how-to guidance, requirements, and all other details. Summary documentation is below:**


## Contents

Within this Ansible Collection, there are various Ansible Roles and no custom Ansible Modules.

### Ansible Roles

| Name | Summary |
| :--- | :--- |
| [sap_hypervisor_node_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_hypervisor_node_preconfigure)<br/>`Beta` | Vendor-specific configuration preparation tasks for Hypervisor nodes hosting Virtual Machines running SAP Systems |
| ~~[sap_vm_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_preconfigure)~~<br/>`WIP` | ~~Vendor-specific configuration preparation tasks for Virtual Machines running SAP Systems~~ |
| [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision) | Provision Virtual Machines to different Infrastructure Platforms; with optional Ansible to Terraform to provision minimal landing zone (partial compatibility via [Terraform Modules for SAP](https://github.com/sap-linuxlab/terraform.modules_for_sap)) |
| [sap_vm_temp_vip](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_temp_vip)<br/>`Beta` | Temporary Virtual IP (VIP) assigned to OS Network Interface prior to Linux Pacemaker ownership |
| ~~[sap_vm_verify](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_verify)~~<br/>`WIP` | ~~Verification of Virtual Machine state and readiness to perform SAP Software installation~~ |


## License

- [Apache 2.0](./LICENSE)


## Contributors

Contributors to the Ansible Roles within this Ansible Collection, are shown within [/docs/contributors](./docs/CONTRIBUTORS.md).
