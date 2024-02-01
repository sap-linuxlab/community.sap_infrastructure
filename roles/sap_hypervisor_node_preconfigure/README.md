`Beta`

# sap_hypervisor_node_preconfigure

Ansible Role for configuration of Hypervisor Nodes and Control Plane for hosting Virtual Machines with SAP Systems.

This Ansible Role will configure the following hypervisors in order to run SAP workloads:
- Red Hat OpenShift Virtualization (OCPV), i.e. KubeVirt
- Red Hat Enterprise Virtualization (RHV), i.e. OVirt KVM


## Functionality

The hypervisor nodes for Virtual Machines hosting SAP Software are amended by the Ansible Role according to SAP Notes and best practices defined by jointly by the Hypervisor vendor and SAP. The majority of these alterations are to improve the performance of SAP Software with the Virtual Machine and the Hypervisor.


## Scope

All hosts for SAP Software on a target Hypervisor.


## Requirements

### Target hypervisor nodes

**Hypervisor Versions:**
- Red Hat OpenShift Virtualization (OCPV) version XYZ+
- Red Hat Virtualization (RHV) version 4.4+ (Extended Support until 1H-2026)
    - Contains 'Red Hat Virtualization Manager (RHV-M)' and the 'Red Hat Virtualization Host (RHV-H)' hypervisor nodes that this Ansible Role preconfigures
    - _Formerly called Red Hat Enterprise Virtualization (RHEV) prior to version 4.4_
    - _Not to be confused with standalone RHEL KVM (RHEL-KVM) hypervisor nodes, which this Ansible Role is not compatible with_

**Prerequisites:**
- Hypervisor Administrator credentials

**Platform-specific - Red Hat OpenShift Virtualization (OCPV):**
- Red Hat OpenShift cluster:
    - Preferable without any previous customization
    - Worker nodes with minimum 96GB of Memory (DRAM)
    - Worker nodes with Intel CPU Instruction Sets: `TSX` <sup>([SAP Note 2737837](https://me.sap.com/notes/2737837/E))</sup>
    - Storage as Local Storage (e.g. LVM) using host path provisioner, NFS, OpenShift Data Foundation, or other via storage orchestrators (such as Trident for NetApp)

### Execution/Controller host

**Dependencies:**
- OS Packages
  - Python 3.9.7+ (i.e. CPython distribution)
  - Red Hat OpenShift CLI Client (`oc` binary)
- Python Packages:
    - `kubernetes` 29.0.0+
- Ansible
    - Ansible Core 2.12.0+
    - Ansible Collections:
      - `kubernetes.core` 3.0.0+

**During execution:**
- For Red Hat OpenShift Virtualization (OCPV), use Environment Variable `KUBECONFIG`


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

- Execute with specified Hypervisor platform using variable `sap_hypervisor_node_platform`
- Import default variables from `/vars` for specified Hypervisor platform
- Re-configure specified Hypervisor platform
- Append performance configuration for specified Hypervisor platform

### Tags to control execution

There are no tags used to control the execution of this Ansible Role


## License

Apache 2.0


## Authors

Nils Koenig

---

## Ansible Role Input Variables

Please first check the [/defaults parameters file](./defaults/main.yml), and platform specific parameters (e.g. [/vars/platform_defaults_redhat_ocp_virt](./vars/platform_defaults_redhat_ocp_virt.yml).

Below is the list of input parameters for this Ansible Role.


`sap_hypervisor_node_preconfigure_reserved_ram (default: 100)` Reserve memory [GB] for hypervisor host. Depending in the use case should be at least 50-100GB. 

`sap_hypervisor_node_preconfigure_reserve_hugepages (default: static)` Hugepage allocation method: {static|runtime}.
static: done at kernel command line which is slow, but safe
runtime: done with hugeadm which is faster, but can in some cases not ensure all HPs are allocated.

`sap_hypervisor_node_preconfigure_kvm_nx_huge_pages (default: "auto")` Setting for the huge page shattering kvm.nx_huge_pages: {"auto"|"on"|"off"}. Note the importance of the quotes, otherwise off will be mapped to false. See https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html for additional information:

```ini
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
