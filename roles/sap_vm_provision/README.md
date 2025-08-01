<!-- BEGIN Title -->
# sap_vm_provision Ansible Role
<!-- END Title -->
![Ansible Lint for sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_provision.yml/badge.svg)

## Description
<!-- BEGIN Description -->
The Ansible Role `sap_vm_provision` is used to provision Virtual Machines to host SAP Software.  
The provisioning methods are:
- `Ansible` - Used with existing minimal landing zone.
- `Terraform` - Used to provision minimal landing zone. Partially compatible with [Terraform Modules for SAP](https://github.com/sap-linuxlab/terraform.modules_for_sap).

This Ansible Role follows requirements and best practices of each Infrastructure Platform, while providing near-homogenous setup across all of them.
<!-- END Description -->

<!-- BEGIN Dependencies -->
<!-- END Dependencies -->

<!-- BEGIN Prerequisites -->
## Prerequisites (Control Node)
The prerequisites are listed only for Control Node, because Managed Nodes are provisioned during runtime.

For a list of requirements and recommended authorizations on each Infrastructure Platform, please see the separate [Infrastructure Platform Guidance](./PLATFORM_GUIDANCE.md) document and the drop-down for each different Infrastructure Platform.

### Base Prerequisites
For list of all collection prerequisites, please see [Ansible Collection Readme](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/README.md#equirements)
- Operating System packages:
  - Python 3.11 or higher
  - Terraform 1.0.0 to 1.5.5 _(when Ansible to Terraform, or legacy Ansible Collection for IBM Cloud)_
- Python libraries and modules:
  - `ansible-core` 2.16 or higher
  - `requests` 2.0 or higher
  - `passlib` 1.7 or higher
  - `jmespath` 1.0.1 or higher
- Ansible Collections:
  - `cloud.common`
  - `cloud.terraform` When `Ansible to Terraform` is used.

### Amazon Web Services (AWS) Prerequisites
- Python libraries and modules:
  - `boto3`
- Ansible Collections:
  - `amazon.aws`
  - `community.aws` - Optional, as AWS is moving Ansible Modules from `community.aws` to `amazon.aws`.

### Google Cloud (GCP) Prerequisites
- Python libraries and modules:
  - `google-auth`
- Ansible Collections:
  - `google.cloud`

### Microsoft Azure Prerequisites
- Python libraries and modules:
  - The list is maintained at [Azure Collection github](https://github.com/ansible-collections/azure/blob/dev/requirements.txt)
  - Installation steps:
    - Download file [in raw format](https://raw.githubusercontent.com/ansible-collections/azure/refs/heads/dev/requirements.txt)
    - Install using pip `pip3 install -r requirements.txt`
  - **NOTE:** Some requirements can be in conflict with other Infrastructure Platforms. We recommend installing Microsoft Azure a separate Python Virtual Environment.
- Ansible Collections:
  - `azure.azcollection`

### IBM Cloud Prerequisites
- Operating System packages:
  - IBM Cloud CLI
- Ansible Collections:
  - `ibm.cloudcollection` _(legacy, to be replaced with `ibm.cloud` in future)_

### IBM PowerVC Prerequisites
- Python libraries and modules:
  - `openstacksdk`

### KubeVirt Prerequisites
- Python libraries and modules:
  - `kubernetes`
- Ansible Collections:
  - `kubevirt.core`

### OVirt Prerequisites
- Python libraries and modules:
  - `ovirt-engine-sdk-python`
- Ansible Collections:
  - `ovirt.ovirt`

### VMware Prerequisites
- Python libraries and modules:
  - `aiohttp`
- Ansible Collections:
  - `vmware.vmware_rest`
<!-- END Prerequisites -->

## Execution
<!-- BEGIN Execution -->
A series of choices are deciding Ansible Role behavior:
- Infrastructure-as-Code Type `sap_vm_provision_iac_type` - Defines the provisioning method.
- Infrastructure Platform `sap_vm_provision_iac_platform` - Defines the target Infrastructure Platform.
- Host Specification Dictionary - Defines the definition of provisioned SAP system hosts.

### Supported Infrastructure Platforms
- AWS EC2 Virtual Server instance
- Google Cloud Compute Engine Virtual Machines
- IBM Cloud, Intel Virtual Servers
- IBM Cloud, Power Virtual Servers
- Microsoft Azure Virtual Machines
- IBM PowerVM Virtual Machines _(formerly LPAR)_
- OVirt Virtual Machines `[Experimental]`
- KubeVirt Virtual Machines `[Experimental]` (e.g. Red Hat OpenShift Virtualization)
- VMware vSphere Virtual Machines `[Experimental]`
<!-- END Execution -->

### Execution Flow
<!-- BEGIN Execution Flow -->
1. Assert that required inputs were provided.
2. Load Infrastructure Platform specific variables.
3. Provision hosts on selected Infrastructure Platform.
4. Create Ansible Inventory during runtime, based on the variable `sap_host_type` defined in Host Specification Dictionary.
5. Configure hosts (e.g. DNS Records, `/etc/hosts`, register OS for Packages, register Web Forward Proxy).
6. Provision High Availability resources, when required.
7. Set variables if other Ansible Roles are to be executed (e.g. variables for Ansible Roles in the `sap_install` Ansible Collection).
8. Remove temporary High Availability configurations (i.e. LB Health Check Port moved to Linux Pacemaker listener) when executed with variable `sap_vm_provision_iac_post_deployment: true`.
<!-- END Execution Flow -->

### Example
<!-- BEGIN Execution Example -->
The playbooks using this Ansible Role are required to dynamically crate Ansible Inventory group during runtime, which will allow parallel provisioning of resources.

**Reasoning behind this concept:** This required structure avoids the Ansible Role using a sequential loop, where each host will execute all Ansible Tasks before the next host is provisioned; or using an async loop which hides all Ansible Task output from the end user.

For more examples on how to use this role in different installation scenarios, refer to the [ansible.playbooks_for_sap](https://github.com/sap-linuxlab/ansible.playbooks_for_sap) playbooks.
- These playbooks include Parallelization concept explained above.

Example for `aws_ec2_vs`:
```yaml
- name: Ansible Play to create dynamic inventory group for provisioning
  hosts: localhost
  gather_facts: false
  tasks:

    - name: Create dynamic inventory group for Ansible Role sap_vm_provision
      ansible.builtin.add_host:
        name: "{{ item }}"
        group: sap_vm_provision_target_inventory_group
      loop: "{{ sap_vm_provision_aws_ec2_vs_host_specifications_dictionary[sap_vm_provision_host_specification_plan].keys() }}"

- name: Ansible Play to provision hosts for SAP
  hosts: sap_vm_provision_target_inventory_group # Ansible Play target hosts pattern, use dynamic Inventory Group
  gather_facts: false
  tasks:

    - name: Execute Ansible Role sap_vm_provision
      ansible.builtin.include_role:
        name: community.sap_infrastructure.sap_vm_provision

- name: Ansible Play for remaining tasks on provisioned hosts
  hosts: all
  tasks:

    - name: Verify hosts provisioned by sap_vm_provision and assigned Inventory Groups
      ansible.builtin.debug:
        var: groups
```
Explanation of workflow:
1. First play: `Ansible Play to create dynamic inventory group for provisioning`
  - Control Node will create new Ansible Inventory group `sap_vm_provision_target_inventory_group` with hosts defined in the variable `sap_vm_provision_aws_ec2_vs_host_specifications_dictionary` under chosen plan `sap_vm_provision_host_specification_plan`.
2. Second play: `Ansible Play to provision hosts for SAP`
  - Provisioning tasks are virtually executed on non-existent hosts, but Ansible Role executes provisioning with `delegate_to` Control Node.
  - Configuration tasks after provisioning are executed on newly provisioned hosts.
3. Third play: `Ansible Play for remaining tasks on provisioned hosts`
  - Example of how newly provisioned hosts can be targeted with additional tasks (e.g. SAP Installation).

For further information, see the [sample Ansible Playbooks in `/playbooks`](../playbooks/).
<!-- END Execution Example -->

<!-- BEGIN Role Tags -->
<!-- END Role Tags -->

<!-- BEGIN Further Information -->
## Further Information
- For Hyperscaler Cloud Service Providers that use Resource Groups (IBM Cloud, Microsoft Azure):
    - Virtual Machine and associated resources (Disks, Network Interfaces, Load Balancer etc.) will be provisioned to the same Resource Group as the targeted network/subnet.
    - Optional: Private DNS may be allocated to another Resource Group, and an optional variable is provided for this.
- Virtual Disk with defined IOPS is only possible on AWS, Google Cloud, IBM Cloud

### Known issues
- VMware REST API combined with cloud-init is unstable, `userdata` configuration may not execute and provisioning will fail
<!-- END Further Information -->

## License
<!-- BEGIN License -->
Apache 2.0
<!-- END License -->

## Maintainers
<!-- BEGIN Maintainers -->
- [Sean Freeman](https://github.com/sean-freeman)
- [Marcel Mamula](https://github.com/marcelmamula)
- [Nils Koenig](https://github.com/newkit) - kubevirt_vm / Red Hat OpenShift Virtualization
<!-- END Maintainers -->

## Role Variables
<!-- BEGIN Role Variables -->
The list of all available variables: [/defaults parameters file](./defaults/main.yml).

**Following key variables are required.**

### sap_vm_provision_iac_type
- _Type:_ `string`<br>
- _Choices:_ `ansible , ansible_to_terraform`<br>

Defines the provisioning method.<br>

### sap_vm_provision_iac_platform
- _Type:_ `string`<br>
- _Choices:_ `aws_ec2_vs , gcp_ce_vm , ibmcloud_vs , ibmcloud_powervs , msazure_vm , ibmpowervm_vm , kubevirt_vm , ovirt_vm , vmware_vm`<br>

Defines the target Infrastructure Platform.<br>

### Host Specification Dictionary
- _Type:_ `dict`<br>
- _Default:_ Default value is defined, but it has to be customized to represent required SAP system.<br>

Defines the definition of provisioned SAP system hosts.<br>
This variable name is unique for each Infrastructure Platform. Example: `sap_vm_provision_aws_ec2_vs_host_specifications_dictionary` for `aws_ec2_vs`.<br>
Customization options:<br>
- Adjust existing plan or add new (Selected by variable `sap_vm_provision_host_specification_plan`).
- Adjust number of hosts and their sizing.
- Adjust the variable `sap_host_type` to customize Ansible Inventory groups. **NOTE:** Group names can be customized using `sap_vm_provision_group_*` variables in `vars/default.yml` (e.g. `sap_vm_provision_group_hana_primary`, `sap_vm_provision_group_nwas_ascs`, etc.). 
- Adjust filesystems (size, type, source, etc.).yes

### Host OS Image Dictionary
- _Type:_ `list`<br>
- _Default:_ Defined for each supported Cloud platform.

Defines list of predefined OS Images for each supported Cloud Platform.
This variable name is unique for each Infrastructure Platform. Example: `sap_vm_provision_aws_ec2_vs_host_os_image_dictionary` for `aws_ec2_vs`.<br>
Chosen OS Image is selected by variable unique variable for each Infrastructure Platform. Example: `sap_vm_provision_aws_ec2_vs_host_os_image` for `aws_ec2_vs`.<br>
Customization options:<br>
- Adjust existing or add new OS images that are available.

### Credentials

Each Infrastructure Platform has list of required variables defined in [/defaults parameters file](./defaults/main.yml).
Example for `aws_ec2_vs`:
- `sap_vm_provision_aws_access_key`
- `sap_vm_provision_aws_secret_access_key`
- `sap_vm_provision_aws_region`
- `sap_vm_provision_aws_vpc_availability_zone`
- `sap_vm_provision_aws_vpc_subnet_id`
- `sap_vm_provision_aws_vpc_sg_names`
- `sap_vm_provision_aws_key_pair_name_ssh_host_public_key`

<!-- END Role Variables -->
