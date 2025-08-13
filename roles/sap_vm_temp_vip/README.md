<!-- BEGIN Title -->
# sap_vm_temp_vip Ansible Role
<!-- END Title -->
![Ansible Lint for sap_vm_temp_vip](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_temp_vip.yml/badge.svg)

## Description
<!-- BEGIN Description -->
The Ansible role `sap_vm_temp_vip` is used to enable installation of SAP Application and Database on High Availability clusters provisioned by [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision) role.

Installation of cluster environment requires temporary assignment of Virtual IP (VIP) before executing installation roles [sap_hana_install](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_hana_install) and [sap_swpm](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_swpm).
- This is temporary and it will be replaced by Cluster VIP resource once cluster is configured by [sap_ha_pacemaker_cluster](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_ha_pacemaker_cluster) role.

This role does not update `/etc/hosts` or DNS records, as these steps are performed by the [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision) role.
<!-- END Description -->

<!-- BEGIN Dependencies -->
## Dependencies
- `community.sap_infrastructure`
    - Roles:
        - `sap_vm_provision`
    - Reason: This role is expected to run after provisioning of resources by Ansible Role [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision).

<!-- END Dependencies -->

## Prerequisites
<!-- BEGIN Prerequisites -->
Environment:
- Assign hosts to correct groups, which are also used in other roles in our project
  - Supported cluster groups: `hana_primary, hana_secondary, anydb_primary, anydb_secondary, nwas_ascs, nwas_ers`
<!-- END Prerequisites -->

## Execution
<!-- BEGIN Execution -->
<!-- END Execution -->

<!-- BEGIN Execution Recommended -->
### Recommended
It is recommended to execute this role together with other roles in this collection, in the following order:</br>
1. [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision)
2. *`sap_vm_temp_vip`*
<!-- END Execution Recommended -->

### Execution Flow
<!-- BEGIN Execution Flow -->
1. Assert that required inputs were provided.
2. Collect missing inputs using provided inputs (example: Calculate prefix from netmask, if VIP prefix was not defined)
3. Append VIP to network interface</br>
  **NOTE:** Group names can be customized using `sap_vm_temp_vip_group_*` variables in `vars/default.yml` (e.g. `sap_vm_temp_vip_group_hana_primary`, `sap_vm_temp_vip_group_nwas_ascs`, etc.).
    - SAP HANA Primary host if both groups are present: `hana_primary, hana_secondary`
    - SAP AnyDB Primary host if both groups are present: `anydb_primary, anydb_secondary`
    - SAP ASCS host if both groups are present: `nwas_ascs, nwas_ers`
    - SAP ERS host if both groups are present:` nwas_ascs, nwas_ers`
4. Install `netcat` and start 12 hour process to ensure that Load Balancer Health Checks are working before Cluster is configured.
    - Limited to platforms with Network Load Balancers and `IPAddr2` resource agent: Google Cloud, MS Azure, IBM Cloud.
<!-- END Execution Flow -->

### Example
<!-- BEGIN Execution Example -->
```yaml
- name: Ansible Play for Temporary VIP setup on SAP ASCS/ERS hosts
  hosts: nwas_ascs, nwas_ers
  become: true
  any_errors_fatal: true
  max_fail_percentage: 0
  tasks:

    - name: Execute Ansible Role sap_vm_temp_vip
      ansible.builtin.include_role:
        name: community.sap_infrastructure.sap_vm_temp_vip
```
<!-- END Execution Example -->

<!-- BEGIN Role Tags -->
<!-- END Role Tags -->

<!-- BEGIN Further Information -->
## Further Information
For more examples on how to use this role in different installation scenarios, refer to the [ansible.playbooks_for_sap](https://github.com/sap-linuxlab/ansible.playbooks_for_sap) playbooks.
<!-- END Further Information -->

## License
<!-- BEGIN License -->
Apache 2.0
<!-- END License -->

## Maintainers
<!-- BEGIN Maintainers -->
- [Sean Freeman](https://github.com/sean-freeman)
- [Marcel Mamula](https://github.com/marcelmamula)
<!-- END Maintainers -->

## Role Variables
<!-- BEGIN Role Variables -->
### sap_vm_temp_vip_default_ip
- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.address`

Specifies the IP Address of the default network interface.

### sap_vm_temp_vip_default_netmask
- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.netmask`

Specifies the Netmask of the default network interface.

### sap_vm_temp_vip_default_prefix
- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.prefix`

Specifies the prefix of the default network interface.

### sap_vm_temp_vip_default_broadcast
- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.broadcast`

Specifies the broadcast of the default network interface.</br>
This parameter is empty on some cloud platforms and VIP is created without broadcast if attempt to calculate fails.

### sap_vm_temp_vip_default_interface
- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.interface` or `eth0`

Specifies the default network interface name.</br>
Ensure to use correct network interface if default interface from Ansible Facts does not represent desired network interface.

### sap_vm_temp_vip_hana_primary
- _Type:_ `string`
- _Default:_ `sap_ha_pacemaker_cluster_vip_hana_primary_ip_address`

This variable is mandatory for SAP HANA cluster setup.</br>
The VIP address is by default assigned from `sap_ha_pacemaker_cluster_vip_hana_primary_ip_address` input parameter used by Ansible Role [sap_ha_pacemaker_cluster](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_ha_pacemaker_cluster).

### sap_vm_temp_vip_nwas_abap_ascs
- _Type:_ `string`
- _Default:_ `sap_ha_pacemaker_cluster_vip_nwas_abap_ascs_ip_address`

This variable is mandatory for SAP ASCS/ERS cluster setup.</br>
The VIP address is by default assigned from `sap_ha_pacemaker_cluster_vip_nwas_abap_ascs_ip_address` input parameter used by Ansible Role [sap_ha_pacemaker_cluster](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_ha_pacemaker_cluster).

### sap_vm_temp_vip_nwas_abap_ers
- _Type:_ `string`
- _Default:_ `sap_ha_pacemaker_cluster_vip_nwas_abap_ers_ip_address`

This variable is mandatory for SAP ASCS/ERS cluster setup.</br>
The VIP address is by default assigned from `sap_ha_pacemaker_cluster_vip_hana_primary_ip_address` input parameter used by Ansible Role [sap_ha_pacemaker_cluster](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_ha_pacemaker_cluster).

### sap_vm_temp_vip_anydb_primary
- _Type:_ `string`

This variable is mandatory for SAP AnyDB cluster setup.
<!-- END Role Variables -->
