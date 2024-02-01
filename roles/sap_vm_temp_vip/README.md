`Beta`

# sap_vm_temp_vip Ansible Role

Ansible Role for assignment of Temporary Virtual IP (VIP) to OS Network Interface prior to Linux Pacemaker ownership.

This Ansible Role will (dependent on detected Infrastructure Platform) perform assignment of a Virtual IP Address to the OS Network Interface.


## Functionality

The hosts for SAP Software allocated for High Availability are configured with a temporary Virtual IP for the OS Network Interface; thereby allowing Linux Pacemaker to be installed once the SAP Software installation has concluded (best practice for Linux Pacemaker). When an Infrastructure Platform with specific requirements is detected (e.g. Load Balancers), then bespoke actions are performed.


## Scope

Only hosts required for High Availability (such as SAP HANA Primary node, SAP NetWeaver ASCS/ERS) should use this Ansible Role.

Assumptions are made based upon the default High Availability configuration for a given Infrastructure Platform (e.g. using Linux Pacemaker `IPAddr2` resource agent).


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

It is advised this Ansible Role is used only for High Availability and executed prior to execution of:
- sap_hana_install
- sap_swpm

Prior to execution of this Ansible Role, there are no Ansible Roles suggested to be executed first.

### Summary of execution flow

- Identify IPv4 Address with CIDR and Broadcast Address
- If SAP AnyDB or SAP NetWeaver, assign Virtual IP to OS Network Interface. If SAP HANA, skip
- Start temporary listener for SAP HANA, SAP AnyDB or SAP NetWeaver when using Load Balancers _(GCP, IBM Cloud, MS Azure)_

### Tags to control execution

There are no tags used to control the execution of this Ansible Role


## License

Apache 2.0


## Authors

Sean Freeman

---

## Ansible Role Input Variables

Please first check the [/defaults parameters file](./defaults/main.yml).
