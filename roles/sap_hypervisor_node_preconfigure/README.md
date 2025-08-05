`Beta`

# sap_hypervisor_node_preconfigure

Ansible Role for configuration of Hypervisor Nodes and Control Plane for hosting Virtual Machines with SAP Systems.

This Ansible Role can configure the following hypervisors in order to run SAP workloads:
- Red Hat OpenShift Virtualization (OCPV). The corresponding upstream project KubeVirt is not tested with this role. While this might work, there is no guarantee.
- Red Hat Enterprise Virtualization (RHV). The corresponding upstream project OVirt KVM is not tested with this role. While this might work, there is no guarantee.

## Functionality

The hypervisor nodes for Virtual Machines hosting SAP Software are amended by the Ansible Role according to SAP Notes and best practices defined by jointly by the Hypervisor vendor and SAP. The majority of these alterations are to improve the performance of SAP Software with the Virtual Machine and the Hypervisor.


## Scope

All hosts for SAP Software running one of the following hypervisors.

**Hypervisor Versions**
- Red Hat OpenShift Virtualization (OCPV) version 4.14+
- Red Hat Virtualization (RHV) version 4.4+ (Extended Support until 1H-2026)
    - Contains 'Red Hat Virtualization Manager (RHV-M)' and the 'Red Hat Virtualization Host (RHV-H)' hypervisor nodes that this Ansible Role preconfigures
    - _Formerly called Red Hat Enterprise Virtualization (RHEV) prior to version 4.4_
    - _Not to be confused with standalone RHEL KVM (RHEL-KVM) hypervisor nodes, which this Ansible Role is not compatible with_

## Execution

### Sample execution

For further information, see the [sample Ansible Playbooks in `/playbooks`](../playbooks/). For example:

```shell
ansible-playbook --connection=local -i "localhost," \
./playbooks/sample-sap-hypervisor-redhat-ocp-virt-preconfigure.yml \
-e @./playbooks/vars/sample-variables-sap-hypervisor-redhat-ocp-virt-preconfigure.yml
```

### Suggested execution sequence

Prior to execution of this Ansible Role, there are no Ansible Roles suggested to be executed first.

### Summary of execution flow

- Execute with specified Hypervisor platform using variable `sap_hypervisor_node_preconfigure_platform`
- Import default variables from `/vars` for specified Hypervisor platform
- Re-configure specified Hypervisor platform
- Append performance configuration for specified Hypervisor platform

### Tags to control execution

There are no tags used to control the execution of this Ansible Role

## Platform: Red Hat OpenShift Virtualization

Configure a plain vanilla Red Hat OpenShift cluster so it can be used for SAP workloads. 

### Requirements
- Jumphost which can access the Red Hat OpenShift cluster
- Optional: Ansible Automation Platform Controller can be used to facilitate the orchestration
- Red Hat OpenShift cluster:
    - Cluster without any previous customization
    - Credentials such as kubeconfig, admin user and password
    - Worker nodes with minimum 96GB of memory (DRAM)
    - For SAP HANA: Worker nodes with Intel CPU Instruction Sets: `TSX` <sup>([SAP Note 2737837](https://me.sap.com/notes/2737837/E))</sup>
    - Storage
      - Netapp filer with NFS using Astra Trident Operator or
      - Local storage using Host Path Provisioner (HPP).
      - OpenShift Data Foundation or other storage orchestrators have to be manually configured.


### Execution/Controller host

An Ansible Automation Platform Controller can be used to facilitate the orchestration. A jumphost with access to the Red Hat OpenShift cluster is required.

**Dependencies**
- OS Packages
  - Python 3.9.7+ (i.e. CPython distribution)
- Python Packages:
    - `kubernetes` 29.0.0+
- Ansible
    - Ansible Core 2.12.0+
    - Ansible Collections:
      - `kubernetes.core` 3.0.0+
      - `community.okd` 3.0.1

See also the `requirements.yml` if running standalone. The requirements can be installed with
```
# ansible-galaxy install -r requirements.yml
```

**During execution**
- For Red Hat OpenShift Virtualization (OCPV), use environment variable `K8S_AUTH_KUBECONFIG`


### Role Variables
Use [sample-variables-sap-hypervisor-redhat-ocp-virt-preconfigure.yml](../playbooks/vars/sample-variables-sap-hypervisor-redhat-ocp-virt-preconfigure.yml) as a starting point and add your configuration.

Let's have a look at the most important variables you need to set.

```
###########################################################
# Red Hat OpenShift cluster connection details
###########################################################

# kubeconfig file Red Hat OpenShift cluster connection.
# Needs to contain a valid API token for trident storage operator to work.
# If not provided, the kubeconfig will be read from the environment variables
# KUBECONFIG or K8S_AUTH_KUBECONFIG
sap_hypervisor_node_preconfigure_kubeconfig:

```
The `kubeconfig` configuration file has to be provided by either:

1. The Ansible variable `sap_hypervisor_node_kubeconfig`.
2. The environment variable `K8S_AUTH_KUBECONFIG`.
3. The environment variable `KUBECONFIG`.

If using the trident storage operator, the `kubeconfig` has also to contain a valid API token.

Next are variables that define what storage configuration should be configured, if the operators should be installed and the configuration of the workers should be done.

```
###########################################################
# Configuration of what should be preconfigured
###########################################################

# Install and configure the host path provisioner (hpp) for a local storage disk
sap_hypervisor_node_preconfigure_install_hpp: false

# Install the trident NFS storage provider
sap_hypervisor_node_preconfigure_install_trident: false

# Should the operators be installed
sap_hypervisor_node_preconfigure_install_operators: true

# Configure the workers?
sap_hypervisor_node_preconfigure_setup_worker_nodes: true
```

The next section you have to modify are the cluster configuration details. Every worker has to have an entry in the `workers` section and make sure, that the name attribute corresponds with the cluster node name (here: worker-0). Adjust the network interface name you want to use. There are two types of networking technologies available: bridging or SR-IOV. See the configuration example file for more options (`playbooks/vars/sample-variables-sap-hypervisor-redhat-ocp-virt-preconfigure.yml`).

There is a section for the `trident` configuration, this is required when installing the NetApp Astra Trident Operator for NFS storage. When using the host path provisioner, `worker_localstorage_device` has to point to the block device which should be used.


```
###########################################################
# Red Hat OpenShift cluster configuration details
###########################################################

# Example configuration for redhat_ocp_virt
sap_hypervisor_node_preconfigure_cluster_config:

  # namespace under which the VMs are created, note this has to be
  # openshift-sriov-network-operator in case of using SR-IOV network
  # devices
  vm_namespace: sap

  # Optional, configuration for trident driver for Netapp NFS filer
  trident:
    management: management.domain.org
    data: datalif.netapp.domain.org
    svm: sap_svm
    backend: nas_backend
    aggregate: aggregate_Name
    username: admin
    password: xxxxx
    storage_driver: ontap-nas
    storage_prefix: ocpv_sap_

  # CPU cores which will be reserved for kubernetes
  worker_kubernetes_reserved_cpus: "0,1"

  # Storage device used for host path provisioner as local storage.
  worker_localstorage_device: /dev/vdb

  # detailed configuration for every worker that should be configured
  workers:

    - name: worker-0                   # name must match the node name
      networks:                        # Example network config

        - name: sapbridge              # using a bridge
          description: SAP bridge
          state: up
          type: linux-bridge
          ipv4:
            enabled: false
            auto-gateway: false
            auto-dns: false
          bridge:
            options:
              stp:
                enabled: false
            port:
              - name: ens1f0           # network IF name

```
### Example Playbook
See [sample-sap-hypervisor-redhat_ocp_virt-preconfigure.yml](../playbooks/sample-sap-hypervisor-redhat_ocp_virt-preconfigure.yml) for an example.

### Example Usage
Make sure to set the `K8S_AUTH_KUBECONFIG` environment variable, e.g.
```
export K8S_AUTH_KUBECONFIG=/path/to/my_kubeconfig
```
To invoke the example playbook with the example configuration using your localhost as ansible host use the following command line:

```shell
ansible-playbook --connection=local -i localhost, \
playbooks/sample-sap-hypervisor-redhat_ocp_virt-preconfigure.yml \
-e @playbooks/vars/sample-sap-hypervisor-redhat_ocp_virt-preconfigure.yml
```


## Platform: Red Hat Virtualization (RHV)
This Ansible Role allows preconfigure of Red Hat Virtualization (RHV), formerly called Red Hat Enterprise Virtualization (RHEV) prior to version 4.4 release. Red Hat Virtualization (RHV) consists of 'Red Hat Virtualization Manager (RHV-M)' and the 'Red Hat Virtualization Host (RHV-H)' hypervisor nodes that this Ansible Role preconfigures. Please note, Red Hat Virtualization is discontinued and maintenance support will end mid-2024. Extended life support for RHV ends mid-2026.
This Ansible Role does not preconfigure RHEL KVM (RHEL-KVM) hypervisor nodes. Please note that RHEL KVM is standalone, and does not have Management tooling (previously provided by RHV-M).

### Requirements

**Prerequisites:**
- Hypervisor Administrator credentials
- RHV hypervisor(s)


**Platform-specific - Red Hat Virtualization (RHV)**
- Jumphost

### Role Variables
See [sample-variables-sap-hypervisor-redhat-rhel-kvm-preconfigure.yml](../playbooks/vars/sample-variables-sap-hypervisor-redhat-rhel-kvm-preconfigure.yml) for details.

`sap_hypervisor_node_preconfigure_reserved_ram (default: 100)` Reserve memory [GB] for hypervisor host. Depending in the use case should be at least 50-100GB. 

`sap_hypervisor_node_preconfigure_reserve_hugepages (default: static)` Hugepage allocation method: {static|runtime}.
static: done at kernel command line which is slow, but safe
runtime: done with hugeadm which is faster, but can in some cases not ensure all HPs are allocated.

`sap_hypervisor_node_preconfigure_kvm_nx_huge_pages (default: "auto")` Setting for the huge page shattering kvm.nx_huge_pages: {"auto"|"on"|"off"}. Note the importance of the quotes, otherwise off will be mapped to false. See https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html for additional information:
```
        kvm.nx_huge_pages=
                        [KVM] Controls the software workaround for the
                        X86_BUG_ITLB_MULTIHIT bug.
                        force   : Always deploy workaround.
                        off     : Never deploy workaround.
                        auto    : Deploy workaround based on the presence of
                                  X86_BUG_ITLB_MULTIHIT.

                        Default is 'auto'.

                        If the software workaround is enabled for the host,
                        guests do need not to enable it for nested guests.
```

`sap_hypervisor_node_preconfigure_tsx (default: "off")` Intel Transactional Synchronization Extensions (TSX): {"on"|"off"}. Note the importance of the quotes, otherwise off will be mapped to false.

`sap_hypervisor_node_preconfigure_assert (default: false)` In assert mode, the parameters on the system are checked if the confirm with what this role would set.

`sap_hypervisor_node_preconfigure_ignore_failed_assertion (default: no)` Fail if assertion is invalid.

`sap_hypervisor_node_preconfigure_run_grub2_mkconfig (default: yes)` Update the grub2 config.


### Example Playbook
See [sample-sap-hypervisor-redhat-rhel-kvm-preconfigure.yml](../playbooks/sample-sap-hypervisor-redhat-rhel-kvm-preconfigure.yml) for an example.

### License
Apache 2.0

### Author Information
Nils Koenig (nkoenig@redhat.com)
