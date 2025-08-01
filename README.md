# community.sap_infrastructure Ansible Collection

![Ansible Lint](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint.yml/badge.svg?branch=main)

## Description
This Ansible Collection provides a set of Ansible Roles designed to automate various infrastructure-related tasks for SAP systems. It focuses on creating and configuring the necessary resources on different infrastructure platforms, including cloud hyperscalers and hypervisors.

These roles are typically used as a foundational step in end-to-end automation workflows, often in conjunction with other Ansible Collections that handle higher-level configurations, such as SAP application deployments.

The included roles cover a range of tasks, such as:
- Provisioning Virtual Machines on target infrastructure platforms, using `Ansible` or `Terraform`.
  - This also includes provisioning of High Availability resources (Routing, Load Balancers, etc.), where applicable.
- Assigning temporary Virtual IP Addresses for application installation, before they are managed by a cluster.
- Pre-configuring hypervisor nodes for hosting virtual machines for SAP systems.
- Pre-configuring virtual machines (`Work in Progress`).
- Verifying provisioned virtual machines (`Work in Progress`).


## Requirements
**Please read the detailed documentation for each Ansible Role to understand their specific requirements.** 

Always follow official [Ansible Documentation](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-core-support-matrix) for compatibility matrix between Control and Managed nodes.

### Control Nodes
Supported Operating systems:
- Any operating system with required Python and Ansible versions.

Component versions:
| Component | Version |
| --- | --- |
| Python | 3.11 or higher |
| ansible-core | 2.16 or higher |

**NOTE:** We recommend using the latest version of components. </br>
Each minor version of `ansible-core` can bring Security fixes (CVE) that can affect functionality. Examples:
- `CVE-2023-5764` changed `assert` functionality in `2.14.12`, `2.15.8` and `2.16.1`.
- `CVE-2024-11079` changed `hostvars` functionality in `2.16.14`, `2.17.7` and `2.18.1`.

### Managed Nodes
Supported Operating systems:
- SUSE Linux Enterprise Server for SAP applications (SLE4SAP): 15 SP5-SP7 and 16
- Red Hat Enterprise Linux for SAP Solutions (RHEL4SAP): 8.x, 9.x and 10.x

**NOTE: Operating system needs to have access to required package repositories either directly or via a subscription registration.**

Component versions:
| Component | Version |
| --- | --- |
| Python | 3.6 or higher |


## Installation Instructions

### Installation
Install this collection with Ansible Galaxy command:
```console
ansible-galaxy collection install community.sap_infrastructure
```

Optionally you can include collection in requirements.yml file and include it together with other collections using: `ansible-galaxy collection install -r requirements.yml`.</br>
**NOTE: This is not recommended for this collection, because you will need only specific subset of collections for your chosen Infrastructure Platform.**</br>

Requirements file need to be maintained in following format:
```yaml
collections:
  - name: community.sap_infrastructure
```

### Upgrade
Installed Ansible Collection will not be upgraded automatically when Ansible package is upgraded.

To upgrade the collection to the latest available version, run the following command:
```console
ansible-galaxy collection install community.sap_infrastructure --upgrade
```

You can also install a specific version of the collection if you encounter issues with the latest version. Please report such issues in the affected Role repository.
For example, to install version 1.1.0:
```
ansible-galaxy collection install community.sap_infrastructure:==1.1.0
```

See [Installing collections](https://docs.ansible.com/ansible/latest/collections_guide/collections_installing.html) for more details on installation methods.


### Ansible Roles
All included roles can be executed independently or as part of [ansible.playbooks_for_sap](https://github.com/sap-linuxlab/ansible.playbooks_for_sap) playbooks.

| Name | Summary |
| :--- | :--- |
| [sap_hypervisor_node_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_hypervisor_node_preconfigure)`Beta` | Vendor-specific configuration preparation tasks for Hypervisor nodes hosting Virtual Machines running SAP Systems |
| ~~[sap_vm_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_preconfigure)~~`WIP` | ~~Vendor-specific configuration preparation tasks for Virtual Machines running SAP Systems~~ |
| [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision) | Provision Virtual Machines to different Infrastructure Platforms; with optional Ansible to Terraform to provision minimal landing zone. |
| [sap_vm_temp_vip](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_temp_vip)<br/> | Temporary Virtual IP (VIP) assigned to OS Network Interface prior to Linux Pacemaker ownership |
| ~~[sap_vm_verify](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_verify)~~ `WIP` | ~~Verification of Virtual Machine state and readiness to perform SAP Software installation~~ |


## Testing
This Ansible Collection has been tested across different operating systems, SAP products, and scenarios.  

Prior to each release, basic scenarios are executed to confirm functionality is working as expected, including SAP S/4HANA installation.   

**NOTE: It is not possible for the project maintainers to test every combination of Infrastructure Platform, Operating System and SAP Software for every release.**


## Contributing
For information on how to contribute, please see our [contribution guidelines](https://sap-linuxlab.github.io/initiative_contributions/).


## Contributors
You can find list of Contributors at [/docs/contributors](./docs/CONTRIBUTORS.md).


## Support
You can report any issues using [GitHub Issues](https://github.com/sap-linuxlab/community.sap_infrastructure/issues).


## Release Notes and Roadmap
The release notes for this collection can be found in the [CHANGELOG file](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/CHANGELOG.rst).


## Further Information

### Variable Precedence Rules
Please follow [Ansible Precedence guidelines](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) on how to pass variables when using this collection.


## License
[Apache 2.0](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/LICENSE)
