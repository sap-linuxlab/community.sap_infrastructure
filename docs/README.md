# Documentation of community.sap_infrastructure Ansible Collection

## Introduction

The `sap_infrastructure` Ansible Collection executes various SAP Infrastructure related tasks, creating resources needed for hosts of SAP Systems.

These Ansible Roles are often run first and combined with other Ansible Collections to provide end-to-end automation.


## Functionality

This Ansible Collection provides a variety of tasks related to SAP Infrastructure (networks, storage, compute). The code structure and logic has been separated to support a flexible execution of different steps for various Infrastructure Platforms and hosting options.

At a high-level, the key functionality of this Ansible Collection includes:

- Preconfigure Hypervisor nodes ready to host Virtual Machines running SAP Systems
- Preconfigure Virtual Machines with specific tasks for the Infrastructure Platform
- Provision Virtual Machines
    - on target Infrastructure Platform, using Ansible or Ansible to Terraform (to perform minimal landing zone setup of an Infrastructure Platform)
    - with High Availability resources if required for the Infrastructure Platform (e.g. Routing and Load Balancers on Cloud Hyperscalers)
- Assignment of Temporary Virtual IP required for High Availability installations on selected Infrastructure Platforms


Compatibility is available within the Ansible Collection for various Infrastructure Platforms:

- Cloud Hyperscalers - AWS EC2 VS, GCP CE VM, IBM Cloud VS, IBM Power VS from IBM Cloud, MS Azure VM
- Hypervisors - IBM PowerVM VM, OVirt VM, KubeVirt VM, VMware VM


## Execution

An Ansible Playbook is the file created and executed by an end-user, which imports from Ansible Collections to perform various activities on the target hosts.

The Ansible Playbook can call either an Ansible Role, or directly call the individual Ansible Modules:

- **Ansible Roles** (runs multiple Ansible Modules)
- **Ansible Modules** (and adjoining Python/Bash Functions)

It is strongly recommended to execute these Ansible Roles in accordance to best practice Ansible usage, where an Ansible Playbook is executed from a host and Ansible will login to a target host to perform the activities.

> If an Ansible Playbook is executed from the target host itself (similar to logging in and running a shell script), this is known as an Ansible Playbook 'localhost execution' and is not recommended as it has limitations on SAP Software installations (particularly installations across multiple hosts).

At a high-level, complex executions with various interlinked activities are run in parallel or sequentially using the following execution structure:

```
Ansible Playbook
-> source Ansible Collection
-> execute Ansible Task
---> run Ansible Role
-----> run Ansible Module (e.g. built-in Ansible Module for Shell)
```

### Execution examples

There are various methods to execute the Ansible Collection, dependent on the use case.

For more information, see [sample Ansible Playbooks in `/playbooks`](../playbooks/).


## Requirements and Dependencies

### Execution/Controller host - Operating System requirements

Execution of Ansible Playbooks using this Ansible Collection have been tested with:
- Python 3.9.7 and above (i.e. CPython distribution)
- Ansible Core 2.12.0 and above _(included with optional installation of Ansible Community Edition 5.0 and above)_
- OS: macOS with Homebrew, RHEL, SLES, and containers in Task Runners (e.g. Azure DevOps)

#### Ansible Core version

This Ansible Collection was designed for maximum backwards compatibility, with full compatibility starting from Ansible Core 2.12.0 and above.

**Note 1:** Ansible 2.9 was the last release before the Ansible project was split into Ansible Core and Ansible Community Edition, and was before Ansible Collections functionality was introduced. This Ansible Collection should execute when Ansible 2.9 is used, but it is not recommended and errors should be expected (and will not be resolved).

**Note 2:** Ansible Core versions prior to 2.14.12 , 2.15.8 , and 2.16.1 where `CVE-2023-5764` (templating inside `that` statement of `assert` Ansible Tasks) security fix was addressed, will work after `v1.3.4` of this Ansible Collection. Otherwise an error similar to the following will occur:

```yaml
fatal: [host01]: FAILED! =>
  msg: 'The conditional check ''13 <= 128'' failed. The error was: Conditional is marked as unsafe, and cannot be evaluated.'
```


## Testing

Various Infrastructure Platforms and SAP Software solutions have been extensively tested.

Prior to each release, basic scenarios are executed to confirm functionality is working as expected; including SAP S/4HANA installation.

Important note: it is not possible for the project maintainers to test every Infrastructure Platform setup and all SAP Software for each OS, if an error is identified please raise a [GitHub Issue](/../../issues/).


### Ansible Roles Lint Status

| Role Name | Ansible Lint Status |
| :--- | :--- |
| [sap_hypervisor_node_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_hypervisor_node_preconfigure) | [![Ansible Lint for sap_hypervisor_node_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_hypervisor_node_preconfigure.yml/badge.svg)](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_hypervisor_node_preconfigure.yml) |
| [sap_vm_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_preconfigure) | [![Ansible Lint for sap_vm_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_preconfigure.yml/badge.svg)](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_preconfigure.yml) |
| [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision) | [![Ansible Lint for sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_provision.yml/badge.svg)](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_provision.yml) |
| [sap_vm_temp_vip](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_temp_vip) | [![Ansible Lint for sap_vm_temp_vip](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_temp_vip.yml/badge.svg)](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_temp_vip.yml) |
| [sap_vm_verify](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_verify) | [![Ansible Lint for sap_vm_verify](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_verify.yml/badge.svg)](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_verify.yml) |
