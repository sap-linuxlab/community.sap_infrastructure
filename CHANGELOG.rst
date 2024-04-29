===================================
community.sap_infrastructure Release Notes
===================================

.. contents:: Topics

v1.0.1
======

Release Summary
---------------

| Release Date: 2024-04-29
| collection: Bug fix for GH Action requirements
| collection: Bug fix for Ansible Collection dependencies
| sap_hypervisor_node_preconfigure: Bug fix for when condition typo and trident version update
| sap_vm_provision: Documentation update for AWS IAM
| sap_vm_provision: Documentation update for design assumptions with execution impact
| sap_vm_provision: Feature add for all to ensure short hostname is not longer than 13 characters (SAP Note 611361)
| sap_vm_provision: Feature add for all internal variable names prefix with __sap_vm_provision_
| sap_vm_provision: Feature add for all with rescue block to output errors without revealing credential secrets
| sap_vm_provision: Feature add for SAP HANA Scale-Out user-defined variable name prefix with sap_vm_provision
| sap_vm_provision: Feature add for all Ansible Tasks calling Infrastructure Platform APIs default to no_log instead of Environment
| sap_vm_provision: Feature add sample Ansible Playbook for blank Virtual Machine provision
| sap_vm_provision: Feature add for MS Azure SSH Key Pair from new dependency Ansible Module
| sap_vm_provision: Feature add for MS Azure and IBM Cloud Private DNS in separate Resource Group
| sap_vm_provision: Feature add for all Cloud vendors with updated regex for OS Image releases
| sap_vm_provision: Feature add for IBM Power VS using newer hardware machine type (Power10)
| sap_vm_provision: Bug fix for OS Package Repository registration task not triggering
| sap_vm_provision: Bug fix for Web Forward Proxy task not triggering
| sap_vm_provision: Bug fix for ignoring undefined variables (e.g. sap_id_user_password) set on hosts
| sap_vm_provision: Bug fix for IBM Power VS using Power Edge Router default instead of legacy cloud connections
| sap_vm_provision: Bug fix for IBM Power VS OS Image clone from stock and provision
| sap_vm_provision: Bug fix for MS Azure Virtual Machine info response changed data path for IP Address migrating from 1.x to 2.x Ansible Collection
| sap_vm_provision: Bug fix for MS Azure Virtual Machine vm_identity syntax changed migrating from 1.x to 2.x Ansible Collection

v1.0.0
======

Release Summary
---------------

| Release Date: 2024-02-02
| Initial Release on Galaxy
