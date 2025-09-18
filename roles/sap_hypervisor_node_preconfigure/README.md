`Beta`

<!-- BEGIN Title -->
# sap_hypervisor_node_preconfigure
<!-- END Title -->
![Ansible Lint for sap_hypervisor_node_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_hypervisor_node_preconfigure.yml/badge.svg)

## Description
<!-- BEGIN Description -->
The Ansible Role `sap_hypervisor_node_preconfigure` configures hypervisor nodes and the control plane for hosting virtual machines with SAP systems.  

This Ansible role supports the following hypervisors:
- Red Hat OpenShift Virtualization (OCPV): 4.14 or higher
- Red Hat Enterprise Virtualization (RHV) `deprecated`: 4.4 or higher
  - _Formerly called Red Hat Enterprise Virtualization (RHEV) prior to version 4.4_
  - _Note: This role is not compatible with standalone RHEL KVM (RHEL-KVM) hypervisor nodes._

The hypervisor nodes for virtual machines hosting SAP software are configured by this role according to SAP Notes and best practices defined jointly by the hypervisor vendor and SAP.  

The majority of these alterations are intended to improve the performance of SAP software on the virtual machine and the hypervisor.
<!-- END Description -->

<!-- BEGIN Dependencies -->
<!-- END Dependencies -->

<!-- BEGIN Prerequisites -->
<!-- END Prerequisites -->

## Execution
<!-- BEGIN Execution -->
<!-- END Execution -->

### Execution Flow
<!-- BEGIN Execution Flow -->
1. Assert that required inputs have been provided.
2. Load hypervisor-specific variables depending on the value of `sap_hypervisor_node_preconfigure_platform`.
3. Configure the selected hypervisor.
4. Adjust performance configuration, if applicable.
<!-- END Execution Flow -->

### Example
<!-- BEGIN Execution Example -->
The platform specific playbook examples are available in their dedicated sections below.
<!-- END Execution Example -->


## Platform: Red Hat OpenShift Virtualization (redhat_ocp_virt)
Configures the Red Hat OpenShift cluster for SAP workloads. 

### Requirements
- A fresh OpenShift cluster without prior custom configurations is required.
- Cluster credentials available: `kubeconfig`.
- Worker nodes with a minimum of 96GB of RAM. Note that larger configurations may be necessary for production SAP workloads.
- Storage:
  - NetApp NFS storage provisioned by the Astra Trident Operator.
  - Local storage provisioned by the Host Path Provisioner (HPP).
  - OpenShift Data Foundation (ODF) and other storage orchestrators must be configured separately.
- For SAP HANA: Worker nodes with Intel CPU Instruction Sets: `TSX` <sup>([SAP Note 2737837](https://me.sap.com/notes/2737837/E))</sup>

### Control Node Requirements
For a list of all collection prerequisites, please see the [Ansible Collection Readme](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/README.md#requirements).

Direct access to the Red Hat OpenShift cluster is required.
- An Ansible Automation Platform Controller can be used to facilitate the orchestration.

- Operating System packages:
  - Python 3.11 or higher
- Python libraries and modules:
  - `ansible-core` 2.16 or higher
  - `kubernetes` >= 29.0.0
- Ansible Collections:
  - `kubernetes.core` >= 3.0.0

### Platform Specific Variables
All platform specific variables are available in [vars/platform_defaults_redhat_ocp_virt.yml](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/roles/sap_hypervisor_node_preconfigure/vars/platform_defaults_redhat_ocp_virt.yml).

The `kubeconfig` configuration file has to be provided by either:
1. The Ansible variable `sap_hypervisor_node_kubeconfig`.
2. The environment variable `K8S_AUTH_KUBECONFIG`.
3. The environment variable `KUBECONFIG`.
**NOTE:** If using the trident storage operator, the `kubeconfig` file has also to contain a valid API token.

Every worker has to have an entry in the `workers` section of the variable `sap_hypervisor_node_preconfigure_cluster_config` and make sure, that the name attribute corresponds with the cluster node name (e.g. worker-0). Adjust the network interface name you want to use. There are two types of networking technologies available: bridging or SR-IOV.

There is a section for the `trident` configuration, this is required when installing the NetApp Astra Trident Operator for NFS storage. When using the host path provisioner, `worker_localstorage_device` has to point to the block device which should be used.

### Example
See [sample-sap-hypervisor-redhat_ocp_virt-preconfigure.yml](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/playbooks/sample-sap-hypervisor-redhat_ocp_virt-preconfigure.yml) for an example.

Make sure to set the `K8S_AUTH_KUBECONFIG` environment variable, e.g.
```
export K8S_AUTH_KUBECONFIG=/path/to/my_kubeconfig
```
To invoke the example playbook with the example configuration using your localhost as ansible host use the following command. In this example it has to be executed from `/playbooks` directory, otherwise the path hast to be adjusted.

```shell
ansible-playbook --connection=local -i localhost, \
  sample-sap-hypervisor-redhat_ocp_virt-preconfigure.yml \
  -e @./vars/sample-sap-hypervisor-redhat_ocp_virt-preconfigure.yml
```


## Platform: Red Hat Virtualization (RHV) `deprecated`
Configures the Red Hat Virtualization (RHV) hypervisor nodes, formerly known as Red Hat Enterprise Virtualization (RHEV) prior to version 4.4.

Red Hat Virtualization consists of a `Red Hat Virtualization Manager (RHV-M)` and the `Red Hat Virtualization Host (RHV-H)` hypervisor nodes that this role pre-configures.
  - **End of Life note:** Red Hat Virtualization is discontinued and maintenance support will end mid-2024. Extended life support for RHV ends mid-2026.

This Ansible Role does not preconfigure RHEL KVM (RHEL-KVM) hypervisor nodes.
  - Please note that RHEL KVM is a standalone hypervisor and does not include the management tooling provided by RHV-M.

### Requirements
For a list of all collection prerequisites, please see the [Ansible Collection Readme](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/README.md#requirements).

- Hypervisor Administrator credentials
- One or more available RHV hypervisors.

### Platform Specific Variables
All platform specific variables are available in [vars/platform_defaults_redhat_rhel_kvm.yml](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/roles/sap_hypervisor_node_preconfigure/vars/platform_defaults_redhat_rhel_kvm.yml).

### Example
See [sample-sap-hypervisor-redhat-rhel-kvm-preconfigure.yml](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/playbooks/sample-sap-hypervisor-redhat-rhel-kvm-preconfigure.yml) for an example.


<!-- BEGIN Further Information -->
<!-- END Further Information -->

## Testing
Additionally the Ansible Role `sap_hypervisor_node_preconfigure` is continuously tested for Red Hat OpenShift. Goal is to ensure that this roles work on all supported OpenShift versions. All network related setup is tested with ipv4 only.

## License
<!-- BEGIN License -->
Apache 2.0
<!-- END License -->

## Maintainers
<!-- BEGIN Maintainers -->
- [Nils Koenig](https://github.com/newkit)
<!-- END Maintainers -->

## Role Variables
<!-- BEGIN Role Variables -->
The list of all available variables: [/defaults parameters file](https://github.com/sap-linuxlab/community.sap_infrastructure/blob/main/roles/sap_hypervisor_node_preconfigure/vars/platform_defaults_redhat_rhel_kvm.yml).  
The platform specific variables are defined in their respective files under `vars/` directory.
<!-- END Role Variables -->
