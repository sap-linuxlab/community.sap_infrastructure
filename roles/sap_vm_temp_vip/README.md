<!-- BEGIN Title -->
# sap_vm_temp_vip Ansible Role
<!-- END Title -->

## Description
<!-- BEGIN Description -->
Ansible role `sap_vm_temp_vip` is used to enable installation of SAP Application and Database on High Availability clusters provisioned by [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision) role.

Installation of cluster environment requires temporary assignment of Virtual IP (VIP) before executing installation roles [sap_hana_install](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_hana_install) and [sap_swpm](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_swpm).
- This is temporary and it will be replaced by Cluster VIP resource once cluster is configured by [sap_ha_pacemaker_cluster](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_ha_pacemaker_cluster) role.

This role does not update `/etc/hosts` or DNS records, as these steps are performed by the [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision) role.
<!-- END Description -->

## Prerequisites
<!-- BEGIN Prerequisites -->
Environment:
- Assign hosts to correct groups, which are also used in other roles in our project
  - Supported cluster groups: `hana_primary, hana_secondary, anydb_primary, anydb_secondary, nwas_ascs, nwas_ers`

Role dependency:
- [sap_vm_provision](https://github.com/sap-linuxlab/community.sap_infrastructure/tree/main/roles/sap_vm_provision), for creating required resources: DNS, Load Balancers and Health Checks.
<!-- END Prerequisites -->

## Execution
<!-- BEGIN Execution -->
Role can be execute separately or as part of [ansible.playbooks_for_sap](https://github.com/sap-linuxlab/ansible.playbooks_for_sap) playbooks.
<!-- END Execution -->

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

## Role Input Parameters
All input parameters used by role are described in [INPUT_PARAMETERS.md](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/roles/sap_vm_temp_vip/INPUT_PARAMETERS.md)
