## Input Parameters for sap_vm_temp_vip Ansible Role
<!-- BEGIN Role Input Parameters -->
### sap_vm_temp_vip_default_ip

- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.address`

IP Address of default network interface is obtained from Ansible Facts and it is used for calculation of missing input parameters.

### sap_vm_temp_vip_default_netmask

- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.netmask`

Netmask of default network interface is obtained from Ansible Facts and it is used for calculation of missing input parameters.

### sap_vm_temp_vip_default_prefix

- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.prefix`

Prefix of default network interface is obtained from Ansible Facts and it is used for calculation of missing input parameters.

### sap_vm_temp_vip_default_broadcast

- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.broadcast`

Broadcast of default network interface is obtained from Ansible Facts and it is used for calculation of missing input parameters.</br>
This parameter is empty on some cloud platforms and VIP is created without broadcast if attempt to calculate fails.

### sap_vm_temp_vip_default_interface

- _Type:_ `string`
- _Default:_ `ansible_default_ipv4.interface` or `eth0`

Default Network Interface name is obtained from Ansible Facts and it is used for calculation of missing input parameters.</br>
Ensure to use correct Network Interface if default interface from Ansible Facts does not represent desired Network Interface.

### sap_vm_temp_vip_hana_primary
- _Type:_ `string`
- _Default:_ `sap_ha_pacemaker_cluster_vip_hana_primary_ip_address`

Mandatory for SAP HANA cluster setup.</br>
VIP address is by default assigned from `sap_ha_pacemaker_cluster_vip_hana_primary_ip_address` input parameter used by [sap_ha_pacemaker_cluster](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_ha_pacemaker_cluster) role.

### sap_vm_temp_vip_nwas_abap_ascs
- _Type:_ `string`
- _Default:_ `sap_ha_pacemaker_cluster_vip_nwas_abap_ascs_ip_address`

Mandatory for SAP ASCS/ERS cluster setup.</br>
VIP address is by default assigned from `sap_ha_pacemaker_cluster_vip_nwas_abap_ascs_ip_address` input parameter used by [sap_ha_pacemaker_cluster](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_ha_pacemaker_cluster) role.

### sap_vm_temp_vip_nwas_abap_ers
- _Type:_ `string`
- _Default:_ `sap_ha_pacemaker_cluster_vip_nwas_abap_ers_ip_address`

Mandatory for SAP ASCS/ERS cluster setup.</br>
VIP address is by default assigned from `sap_ha_pacemaker_cluster_vip_hana_primary_ip_address` input parameter used by [sap_ha_pacemaker_cluster](https://github.com/sap-linuxlab/community.sap_install/tree/main/roles/sap_ha_pacemaker_cluster) role.

### sap_vm_temp_vip_anydb_primary
- _Type:_ `string`

Mandatory for SAP AnyDB cluster setup.

<!-- END Role Input Parameters -->