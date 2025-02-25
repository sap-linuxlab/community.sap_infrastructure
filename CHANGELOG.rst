===========================================
community.sap\_infrastructure Release Notes
===========================================

.. contents:: Topics

v1.1.2
======

Release Summary
---------------

A few minor changes

Bugfixes
--------

- collection - Bump vmware.vmware_rest to 4.5.0 (https://github.com/sap-linuxlab/community.sap_infrastructure/pull/88)
- collection - Use amazon.aws.ec2_placement_group (https://github.com/sap-linuxlab/community.sap_infrastructure/pull/90)
- collection - implement changelogs/changelog.yaml (https://github.com/sap-linuxlab/community.sap_infrastructure/pull/84)
- sap_vm_provision - AWS tag pacemaker for fence agent stonith:external/ec2 (https://github.com/sap-linuxlab/community.sap_infrastructure/pull/91)
- sap_vm_provision - update azure.azcollection minimum version requirement (https://github.com/sap-linuxlab/community.sap_infrastructure/pull/81)
- sap_vm_provision/sap_vm_temp_vip - Add dynamic group handling for provisioning (https://github.com/sap-linuxlab/community.sap_infrastructure/pull/78)
- sap_vm_verify - stub code comments and reorder (https://github.com/sap-linuxlab/community.sap_infrastructure/pull/80)

v1.1.1
======

Release Summary
---------------

A few minor fixes

Bugfixes
--------

- sap_hypervisor_node_preconfigure - Bug fix for HCO wait and validate
- sap_hypervisor_node_preconfigure - Bug fix for HPP wait

v1.1.0
======

Release Summary
---------------

Various minor changes

Minor Changes
-------------

- sap_hypervisor_node_preconfigure - OCPv add waits for resource readiness
- sap_hypervisor_node_preconfigure - OCPv improve SR-IOV handling
- sap_hypervisor_node_preconfigure - OCPv improve auth and add namespace targets
- sap_hypervisor_node_preconfigure - OCPv update default vars and var prefixes
- sap_vm_provision - add AWS Route53 record overwrite
- sap_vm_provision - add IBM Cloud Private DNS Custom Resolver for IBM Power VS
- sap_vm_provision - add google-guest-agent service for load balancer config
- sap_vm_provision - add readiness for AnyDB HA (e.g. IBM Db2 HADR)
- sap_vm_provision - add spread placement strategy for AWS, GCP, IBM Cloud, MS Azure, IBM PowerVM
- sap_vm_provision - add var for Load Balancer naming on GCP, IBM Cloud, MS Azure
- sap_vm_provision - add var for Virtual IP handling across multiple roles
- sap_vm_provision - add vars for Kubevirt VM
- sap_vm_provision - fix /etc/hosts for Virtual IPs
- sap_vm_provision - fix Ansible to Terraform copy to working directory logic and note
- sap_vm_provision - fix OS Subscription registration logic and BYOL/BYOS
- sap_vm_provision - fix handling of AWS IAM Policy for HA
- sap_vm_provision - fix handling of MS Azure IAM Role for HA
- sap_vm_provision - fix handling of custom IOPS on AWS, GCP, IBM Cloud
- sap_vm_provision - fix handling of nested variables within host_specifications_dictionary
- sap_vm_provision - improve Web Proxy logic
- sap_vm_provision - remove AWS CLI and GCloud CLI dependency
- sap_vm_provision - update IBM Power VS locations lookup list
- sap_vm_provision - update OS Images for AWS, GCP, IBM Cloud, MS Azure
- sap_vm_provision - update embedded Terraform Template with updated var names for imported Terraform Modules
- sap_vm_provision - update logic for IBM Cloud Virtual Network Interfaces (VNI)
- sap_vm_provision - update logic for IBM Power VS Workspace with latest backend routing (PER)
- sap_vm_provision - update platform guidance document
- sap_vm_temp_vip - overhaul documentation
- sap_vm_temp_vip - overhaul replace all shell logic with Ansible Modules and use special vars to determine OS network devices reliably

v1.0.1
======

Release Summary
---------------

Various enhancements

Minor Changes
-------------

- collection - Bug fix for Ansible Collection dependencies
- collection - Bug fix for GH Action requirements
- sap_hypervisor_node_preconfigure - Bug fix for when condition typo and trident version update
- sap_vm_provision - Bug fix for IBM Power VS OS Image clone from stock and provision
- sap_vm_provision - Bug fix for IBM Power VS using Power Edge Router default instead of legacy cloud connections
- sap_vm_provision - Bug fix for MS Azure Virtual Machine info response changed data path for IP Address migrating from 1.x to 2.x Ansible Collection
- sap_vm_provision - Bug fix for MS Azure Virtual Machine vm_identity syntax changed migrating from 1.x to 2.x Ansible Collection
- sap_vm_provision - Bug fix for OS Package Repository registration task not triggering
- sap_vm_provision - Bug fix for Web Forward Proxy task not triggering
- sap_vm_provision - Bug fix for ignoring undefined variables (e.g. sap_id_user_password) set on hosts
- sap_vm_provision - Documentation update for AWS IAM
- sap_vm_provision - Documentation update for design assumptions with execution impact
- sap_vm_provision - Feature add for IBM Power VS using newer hardware machine type (Power10)
- sap_vm_provision - Feature add for MS Azure SSH Key Pair from new dependency Ansible Module
- sap_vm_provision - Feature add for MS Azure and IBM Cloud Private DNS in separate Resource Group
- sap_vm_provision - Feature add for SAP HANA Scale-Out user-defined variable name prefix with sap_vm_provision
- sap_vm_provision - Feature add for all Ansible Tasks calling Infrastructure Platform APIs default to no_log instead of Environment
- sap_vm_provision - Feature add for all Cloud vendors with updated regex for OS Image releases
- sap_vm_provision - Feature add for all internal variable names prefix with __sap_vm_provision_
- sap_vm_provision - Feature add for all to ensure short hostname is not longer than 13 characters (SAP Note 611361)
- sap_vm_provision - Feature add for all with rescue block to output errors without revealing credential secrets
- sap_vm_provision - Feature add sample Ansible Playbook for blank Virtual Machine provision

v1.0.0
======

Release Summary
---------------

Initial Release on Galaxy
