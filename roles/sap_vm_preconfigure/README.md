`WIP`

# sap_vm_preconfigure
![Ansible Lint for sap_vm_preconfigure](https://github.com/sap-linuxlab/community.sap_infrastructure/actions/workflows/ansible-lint-sap_vm_preconfigure.yml/badge.svg)

Ansible Role for Vendor-specific configuration preparation tasks for Virtual Machines running SAP Systems.

This Ansible Role will configure Virtual Machines on the following Infrastructure Platforms in order to run SAP workloads:
- Red Hat Enterprise Virtualization (RHV), i.e. OVirt KVM


## Functionality

Detect current Infrastructure Platform and execute tasks specified by the vendor.


## Scope

All hosts for SAP Software.


## Requirements

### Target hosts

**OS Versions:**
- Red Hat Enterprise Linux 8.2+
- SUSE Linux Enterprise Server 15 SP3+

### Execution/Controller host

**Dependencies:**
- OS Packages
  - Python 3.9.7+ (i.e. CPython distribution)
- Python Packages
    - None
- Ansible
    - Ansible Core 2.12.0+
    - Ansible Collections:
      - None


## Execution

### Sample execution

For further information, see the [sample Ansible Playbooks in `/playbooks`](../playbooks/).

### Suggested execution sequence

Prior to execution of this Ansible Role, it is advised to first execute:
- sap_general_preconfigure
- sap_netweaver_preconfigure / sap_hana_preconfigure

### Summary of execution flow

- Detect Platform (or specify)
- Execute tasks defined by Infrastructure Platform vendor

### Tags to control execution

There are no tags used to control the execution of this Ansible Role


## License

Apache 2.0


## Authors

TBD

---

## Ansible Role Input Variables

Please first check the [/defaults parameters file](./defaults/main.yml), and platform specific parameters within [/vars parameters file](./vars/) path.


### Run the role in assert mode

```yaml
sap_vm_preconfigure_assert (default: no)
```

If the following variable is set to `yes`, the role will only check if the configuration of the managed mmachines is according to this role. Default is `no`.


### Behavior of the role in assert mode

```yaml
sap_vm_preconfigure_assert_ignore_errors (default: no)
```

If the role is run in assert mode and the following variable is set to `yes`, assertion errors will not cause the role to fail. This can be useful for creating reports.

Default is `no`, meaning that the role will fail for any assertion error which is discovered. This variable has no meaning if the role is not run in assert mode.
