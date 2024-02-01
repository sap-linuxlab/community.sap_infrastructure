`WIP`

# sap_vm_verify Ansible Role

Ansible Role for verification of Virtual Machine state and readiness to perform SAP Software installation.

This Ansible Role will perform preflight checks whether necessary storage and directories exist on the host, network connectivity between hosts on specific ports and network connectivity to NFS etc.


## Functionality

All hosts of SAP Software require various storage and network requirements to be fulfilled; particularly network interconnectivity between hosts and other services (e.g. NFS). Prior to installation of SAP Software, verification checks can provide an alert for blocked Ports and error before a partial/errored installation occurs.


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

Prior to execution of this Ansible Role, there are no Ansible Roles suggested to be executed first.

### Summary of execution flow

- Detect Platform (or specify)
- Execute storage availability and I/O checks
- Execute network interconnectivity checks

### Tags to control execution

There are no tags used to control the execution of this Ansible Role


## License

Apache 2.0


## Authors

TBD

---

## Ansible Role Input Variables

Please first check the [/defaults parameters file](./defaults/main.yml).
