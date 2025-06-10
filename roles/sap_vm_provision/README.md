# sap_vm_provision Ansible Role

Ansible Role to provision Virtual Machines to host SAP Software.

This Ansible Role will provision Virtual Machines to different Infrastructure Platforms; with optional Ansible to Terraform to provision minimal landing zone (partial compatibility via [Terraform Modules for SAP](https://github.com/sap-linuxlab/terraform.modules_for_sap)).

Primarily, this Ansible Role was designed to be executed end-to-end (i.e. Provision host/s, configure OS for SAP Software, install SAP Software, instantiate the SAP System); such as the [Ansible Playbooks for SAP](https://github.com/sap-linuxlab/ansible.playbooks_for_sap).


## Functionality

The provisioned hosts by the Ansible Role provide a near-homogenous setup across different Infrastructure Platforms, while following requirements and best practices defined by each vendor.

A series of choices is provided by the Ansible Role:
- Infrastructure-as-Code type (Ansible or Ansible to Terraform)
- Infrastructure Platform
- Host Specification Dictionary, containing 1..n Plans
- Host OS Image Dictionary

Dependent on the choices made by the end user, host/s will be provisioned to the target Infrastructure Platform.

## Scope

The code modularity and commonality of provisioning enables a wide gamut of SAP Software Solution Scenarios to be deployed to many Infrastructure Platforms with differing configuration.

### Available Infrastructure Platforms

- AWS EC2 Virtual Server instance/s
- Google Cloud Compute Engine Virtual Machine/s
- IBM Cloud, Intel Virtual Server/s
- IBM Cloud, Power Virtual Server/s
- Microsoft Azure Virtual Machine/s
- IBM PowerVM Virtual Machine/s _(formerly LPAR/s)_
- OVirt Virtual Machine/s (e.g. Red Hat Enterprise Linux KVM)
- KubeVirt Virtual Machine/s (e.g. SUSE Rancher with Harvester HCI) `[Experimental]`
- Red Hat OpenShift Virtualization `[Experimental]`
- VMware vSphere Virtual Machine/s `[Beta]`

### Known issues

- VMware REST API combined with cloud-init is unstable, `userdata` configuration may not execute and provisioning will fail


## Requirements

### Target Infrastructure Platform

For a list of requirements and recommended authorizations on each Infrastructure Platform, please see the separate [Infrastructure Platform Guidance](./PLATFORM_GUIDANCE.md) document and the drop-down for each different Infrastructure Platform.

### Target hosts

**OS Versions:**
- Red Hat Enterprise Linux 8.0+
- SUSE Linux Enterprise Server 15 SP0+

### Execution/Controller host

**Dependencies:**
- OS Packages
    - Python 3.9.7+ (i.e. CPython distribution)
    - IBM Cloud CLI _(when High Availability on IBM Cloud)_
    - Terraform 1.0.0-1.5.5 _(when Ansible to Terraform, or legacy Ansible Collection for IBM Cloud)_
- Python Packages
    - `requests` 2.0+
    - `passlib` 1.7+
    - `jmespath` 1.0.1+
    - `boto3` for Amazon Web Services
    - `google-auth` for Google Cloud
    - `https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt` for Microsoft Azure
    - `openstacksdk` for IBM PowerVM
    - `ovirt-engine-sdk-python` for OVirt
    - `aiohttp` for VMware
    - `kubernetes` for Kubernetes based platforms such as Red Hat OpenShift Virtualization
- Ansible
    - Ansible Core 2.12.0+
    - Ansible Collections:
        - `amazon.aws`
        - `azure.azcollection`
        - `cloud.common`
        - `cloud.terraform`
        - `community.aws`
        - `google.cloud`
        - `ibm.cloudcollection`
            - _(legacy, to be replaced with `ibm.cloud` in future)_
        - `kubevirt.core` for kubevirt_vm or Red Hat OpenShift Virtualization
        - `openstack.cloud`
        - `ovirt.ovirt`
        - `vmware.vmware_rest` <sup>_(requires `cloud.common`)_</sup>

TODO: Split up above dependencies per platform.


## Execution

### Sample execution

For further information, see the [sample Ansible Playbooks in `/playbooks`](../playbooks/).

### Suggested execution sequence

Prior to execution of this Ansible Role, there are no Ansible Roles suggested to be executed first.

### Summary of execution flow

- Define target Host/s Specifications with a 'plan' name (e.g. `test1_256gb_memory` containing 1 host of 256GB Memory for SAP HANA and 1 host for SAP NetWeaver); append to the Host Specification Dictionary
- Define target Host OS Image Dictionary, or use defaults provided for each Cloud Hyperscaler.
- Execute with chosen:
    - Infrastructure-as-Code method (Ansible or Ansible to Terraform) using variable `sap_vm_provision_iac_type`
    - Infrastructure Platform target using variable `sap_vm_provision_iac_platform`
    - Selected plan using variable `sap_vm_provision_host_specification_plan` referring to the definition in the Host Specification Dictionary
    - Variables specific to each Infrastructure Platform (e.g. `sap_vm_provision_aws_access_key`)
    - Include files from subdirectory based upon chosen method and target (e.g. `/tasks/platform_ansible_to_terraform/aws_ec2_vs/`)
- Provision host/s
- Add hosts to Ansible Inventory Groups defined by the Host Specification Dictionary `sap_host_type` variable _(e.g. hana_primary, hana_secondary, nwas_ascs, nwas_ers, nwas_pas, nwas_aas, anydb_primary, anydb_secondary)_</br>
  **NOTE:** Group names can be customized using `sap_vm_provision_group_*` variables in `vars/default.yml` (e.g. `sap_vm_provision_group_hana_primary`, `sap_vm_provision_group_nwas_ascs`, etc.).
- Perform additional tasks for host/s (e.g. DNS Records, /etc/hosts, register OS for Packages, register Web Forward Proxy)
- Set variables if other Ansible Roles are to be executed (e.g. variables for Ansible Roles in the `sap_install` Ansible Collection)
- Perform any tasks for High Availability (execution dependent on hosts in Ansible Inventory Groups)
- **POST:** Re-execute Ansible Role with variable `sap_vm_provision_iac_post_deployment: true` to update High Availability configurations using Load Balancer (i.e. LB Health Check Port moved to Linux Pacemaker listener)


### Required structure in Ansible Playbook

_**CRITICAL NOTE**_

To provide parallelisation of provisioning, the following structure must be used to dynamically create an Ansible Inventory Group for the requested hostnames. Without this necessary pre-task, the Ansible Role will not function.

> Design decision note: This required structure avoids the Ansible Role using a sequential loop, where each host will execute all Ansible Tasks before the next host is provisioned; or using an async loop which hides all Ansible Task output from the end user.

This required structure will:

- In the first Ansible Play using `localhost`, dynamically create an Ansible Inventory with the hostnames listed parsed from the Ansible Dictionary (variable named `sap_vm_provision_XYZ_host_specifications_dictionary` dependent on the Infrastructure Platform)
- In the second Ansible Play use the dynamic Ansible Inventory `sap_vm_provision_target_inventory_group`, create an Ansible Play Batch containing each target host in the dynamic Ansible Inventory, which will then execute all proceeding Ansible Tasks in parallel for each target host.

**Structure to execute sap_vm_provision:**

```yaml
- name: Ansible Play to create dynamic inventory group for provisioning
  hosts: localhost
  gather_facts: false
  tasks:

    - name: Create dynamic inventory group for Ansible Role sap_vm_provision
      ansible.builtin.add_host:
        name: "{{ item }}"
        group: sap_vm_provision_target_inventory_group
      # Adjust var name in loop (i.e. replace _XYZ_ to the correct Ansible Dictionary)
      loop: "{{ sap_vm_provision_XYZ_host_specifications_dictionary[sap_vm_provision_host_specification_plan].keys() }}"

- name: Ansible Play to provision hosts for SAP
  hosts: sap_vm_provision_target_inventory_group # Ansible Play target hosts pattern, use dynamic Inventory Group
  gather_facts: false
  tasks:

    - name: Execute Ansible Role sap_vm_provision
      ansible.builtin.include_role:
        name: community.sap_infrastructure.sap_vm_provision

- name: Ansible Play for verify provisioned hosts for SAP
  hosts: all
  tasks:

    - name: Verify hosts provisioned by sap_vm_provision and assigned Inventory Groups
      ansible.builtin.debug:
        var: groups
```

### Design assumptions with execution impact

- For Hyperscaler Cloud Service Providers that use Resource Groups (IBM Cloud, Microsoft Azure):
    - Virtual Machine and associated resources (Disks, Network Interfaces, Load Balancer etc.) will be provisioned to the same Resource Group as the targeted network/subnet.
    - Optional: Private DNS may be allocated to another Resource Group, and an optional variable is provided for this.
- Virtual Disk with defined IOPS is only possible on AWS, Google Cloud, IBM Cloud

### Tags to control execution

There are no tags used to control the execution of this Ansible Role


## License

Apache 2.0


## Authors

Sean Freeman
Nils Koenig (nkoenig@redhat.com) kubevirt_vm / Red Hat OpenShift Virtualization

---

## Ansible Role Input Variables

Please first check the [/defaults parameters file](./defaults/main.yml).
