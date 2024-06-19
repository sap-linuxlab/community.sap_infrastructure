# Infrastructure Platform Guidance

Table of Contents:
- [Required resources when Ansible provisioning VMs](#required-resources-when-ansible-provisioning-vms)
- [Recommended Infrastructure Platform authorizations](#recommended-infrastructure-platform-authorizations)
- [Recommended Infrastructure Platform configuration](#recommended-infrastructure-platform-configuration)


## Required resources when Ansible provisioning VMs

The following does not apply if Ansible to Terraform is used.

See below for the drop-down list of required environment resources on an Infrastructure Platform resources when Ansible is used to provision Virtual Machines.

<details>
<summary><b>Amazon Web Services (AWS):</b></summary>

- VPC
    - VPC Access Control List (ACL)
    - VPC Subnets
    - VPC Security Groups
- Route53 (Private DNS)
- Internet Gateway (SNAT)
- EFS (NFS)
- Bastion host (AWS EC2 VS)
- Key Pair for hosts

</details>

<details>
<summary><b>Google Cloud (GCP):</b></summary>

- VPC Network
    - VPC Subnetwork
- Compute Firewall
- Compute Router
    - SNAT
- DNS Managed Zone (Private DNS)
- Filestore (NFS)
- Bastion host (GCP CE VM)

</details>

<details>
<summary><b>Microsoft Azure:</b></summary>

- Resource Group
- VNet
    - VNet Subnet
    - VNet Network Security Group (NSG)
- Private DNS Zone
- NAT Gateway (SNAT)
- Storage Account
    - Azure Files (aka. File Storage Share, NFS)
    - Private Endpoint Connection
- Bastion host (MS Azure VM)
- Key Pair for hosts

</details>

<details>
<summary><b>IBM Cloud:</b></summary>

- Resource Group
- VPC
    - VPC Access Control List (ACL)
    - VPC Subnets
    - VPC Security Groups
- Private DNS
- Public Gateway (SNAT)
- File Share (NFS)
- Bastion host (IBM Cloud VS)
- Key Pair for hosts

</details>

<details>
<summary><b>IBM Cloud, IBM Power VS:</b></summary>

- Resource Group
- IBM Power Workspace
    - VLAN Subnet
    - Cloud Connection (from secure enclave to IBM Cloud)
- Private DNS Zone
- Public Gateway (SNAT)
- Bastion host (IBM Cloud VS or IBM Power VS)
- Key Pair for hosts (in IBM Power Workspace)

</details>

<details>
<summary><b>IBM PowerVC:</b></summary>

- Host Group Shared Processor Pool
- Storage Template
- Network Configuration (for SEA or SR-IOV)
- VM OS Image
- Key Pair for hosts

</details>

<details>
<summary><b>KubeVirt:</b></summary>

- `TODO`

</details>

<details>
<summary><b>OVirt:</b></summary>

- `TODO`

</details>

<details>
<summary><b>VMware vCenter:</b></summary>

- Datacenter (SDDC)
    - Cluster
        - Hosts
- NSX
- Datastore
- Content Library
    - VM Template

</details>



## Recommended Infrastructure Platform authorizations

See below for the drop-down list of recommended authorizations for each Infrastructure Platform.


<details>
<summary><b>Amazon Web Services (AWS):</b></summary>

The AWS User and associated key/secret will need to be assigned, by the Cloud Account Administrator. A recommended minimum of AWS IAM user authorization is achieved with the following AWS CLI commands:
```shell
# Login
aws configure

# Create AWS IAM Policy Group
aws iam create-group --group-name 'ag-sap-automation'
aws iam attach-group-policy --group-name 'ag-sap-automation' --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess
aws iam attach-group-policy --group-name 'ag-sap-automation' --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-group-policy --group-name 'ag-sap-automation' --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess
```

It is recommended to create new AWS IAM Policy with detailed actions to improve security.
```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"ec2:DescribeImages",
				"ec2:DescribeInstances",
				"ec2:DescribeTags",
				"ec2:DescribeInstanceAttribute",
				"ec2:DescribeSubnets",
				"ec2:DescribeSecurityGroups",
				"ec2:RunInstances",
				"ec2:CreateTags",
				"ec2:DescribeInstanceStatus",
				"ec2:ModifyInstanceAttribute",
				"ec2:DescribeRouteTables",
				"route53:ListHostedZones",
				"route53:ListResourceRecordSets",
				"route53:ChangeResourceRecordSets",
				"route53:GetChange",
				"ec2:DescribeVolumes",
				"ec2:CreateVolume",
				"ec2:DeleteVolume",
				"ec2:AttachVolume",
				"ec2:DetachVolume",
				"ec2:TerminateInstances",
				"ec2:CreateRoute",
				"iam:GetRole",
				"iam:CreateRole",
				"iam:ListInstanceProfilesForRole",
				"iam:CreateInstanceProfile",
				"iam:AddRoleToInstanceProfile",
				"iam:ListAttachedRolePolicies",
				"iam:ListRoleTags",
				"iam:PutRolePolicy",
				"iam:GetInstanceProfile",
				"iam:PassRole",
				"ec2:AssociateIamInstanceProfile",
				"ec2:ReplaceRoute"
			],
			"Resource": "*"
		}
	]
}
```

</details>

<details>
<summary><b>Google Cloud (GCP):</b></summary>

Google Cloud Platform places upper limit quotas for different resources and limits `'CPUS_ALL_REGIONS'` and `'SSD_TOTAL_GB'` may be too low if using a new GCP Account or a new target GCP Region. Please check `gcloud compute regions describe us-central1 --format="table(quotas:format='table(metric,limit,usage)')"` before provisioning to a GCP Region, and manually request quota increases for these limits in the target GCP Region using instructions on https://cloud.google.com/docs/quota#requesting_higher_quota (from GCP Console or contact with GCP Support Team).

The Google Cloud User credentials (Client ID and Client Secret) JSON file with associated authorizations will need to be assigned, by the Cloud Account Administrator. Thereafter, please manually open and activate various APIs for the GCP Project to avoid HTTP 403 errors during provisioning:
- Enable the Compute Engine API, using https://console.cloud.google.com/apis/api/compute.googleapis.com/overview
- Enable the Cloud DNS API, using https://console.cloud.google.com/apis/api/dns.googleapis.com/overview
- Enable the Network Connectivity API, using https://console.cloud.google.com/apis/library/networkconnectivity.googleapis.com
- Enable the Cloud Filestore API, using https://console.cloud.google.com/apis/library/file.googleapis.com
- Enable the Service Networking API (Private Services Connection to Filestore), using https://console.cloud.google.com/apis/library/servicenetworking.googleapis.com

</details>

<details>
<summary><b>Microsoft Azure:</b></summary>

The Azure Application Service Principal and associated Client ID and Client Secret will need to be assigned, by the Cloud Account Administrator. A recommended minimum of Azure AD Role authorizations is achieved with the following MS Azure CLI commands:

```shell
# Login
az login

# Show Tenant and Subscription ID
export AZ_SUBSCRIPTION_ID=$(az account show | jq .id --raw-output)
export AZ_TENANT_ID=$(az account show | jq .tenantId --raw-output)

# Create Azure Application, includes Client ID
export AZ_CLIENT_ID=$(az ad app create --display-name ansible-terraform | jq .appId --raw-output)

# Create Azure Service Principal, instantiation of Azure Application
export AZ_SERVICE_PRINCIPAL_ID=$(az ad sp create --id $AZ_CLIENT_ID | jq .objectId --raw-output)

# Assign default Azure AD Role with privileges for creating Azure Virtual Machines
az role assignment create --assignee "$AZ_SERVICE_PRINCIPAL_ID" \
--subscription "$AZ_SUBSCRIPTION_ID" \
--role "Virtual Machine Contributor" \
--role "Contributor"

# Reset Azure Application, to provide the Client ID and Client Secret to use the Azure Service Principal
az ad sp credential reset --name $AZ_CLIENT_ID
```

It is recommended to create new Azure custom role with detailed actions to improve security.
```json
{
    "properties": {
        "roleName": "ansible-sap-automation",
        "description": "Custom role for SAP LinuxLab ansible automation.",
        "permissions": [
            {
                "actions": [
                    "Microsoft.Authorization/roleAssignments/read",
                    "Microsoft.Authorization/roleAssignments/write",
                    "Microsoft.Authorization/roleDefinitions/read",
                    "Microsoft.Authorization/roleDefinitions/write",
                    "Microsoft.Compute/disks/read",
                    "Microsoft.Compute/disks/write",
                    "Microsoft.Compute/sshPublicKeys/read",
                    "Microsoft.Compute/sshPublicKeys/write",
                    "Microsoft.Compute/virtualMachines/instanceView/read",
                    "Microsoft.Compute/virtualMachines/read",
                    "Microsoft.Compute/virtualMachines/write",
                    "Microsoft.Network/loadBalancers/backendAddressPools/join/action",
                    "Microsoft.Network/loadBalancers/read",
                    "Microsoft.Network/loadBalancers/write",
                    "Microsoft.Network/networkInterfaces/join/action",
                    "Microsoft.Network/networkInterfaces/read",
                    "Microsoft.Network/networkInterfaces/write",
                    "Microsoft.Network/networkSecurityGroups/read",
                    "Microsoft.Network/privateDnsZones/A/read",
                    "Microsoft.Network/privateDnsZones/A/write",
                    "Microsoft.Network/privateDnsZones/read",
                    "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read",
                    "Microsoft.Network/virtualNetworks/privateDnsZoneLinks/read",
                    "Microsoft.Network/virtualNetworks/subnets/join/action",
                    "Microsoft.Network/virtualNetworks/subnets/read",
                    "Microsoft.Resources/subscriptions/resourceGroups/read",
                ],
                "notActions": [],
                "dataActions": [],
                "notDataActions": []
            }
        ]
    }
}
```

Note: MS Azure VMs provisioned will contain Hyper-V Hypervisor virtual interfaces using eth* on the OS, and when Accelerated Networking (AccelNet) is enabled for the MS Azure VM then the Mellanox SmartNIC/DPU SR-IOV Virtual Function (VF) may use enP* on the OS. For further information, see [MS Azure - How Accelerated Networking works](https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-how-it-works). During High Availability executions, failures may occur and may require additional variable 'sap_ha_pacemaker_cluster_vip_client_interface' to be defined.

</details>

<details>
<summary><b>IBM Cloud:</b></summary>

The IBM Cloud Account User (or Service ID) and associated API Key will need to be assigned, by the Cloud Account Administrator. A recommended minimum of IBM Cloud IAM user authorization is achieved with the following IBM Cloud CLI commands:

```shell
# Login (see alternatives for user/password and SSO using ibmcloud login --help)
ibmcloud login --apikey=

# Create IBM Cloud IAM Access Group
ibmcloud iam access-group-create 'ag-sap-automation'
ibmcloud iam access-group-policy-create 'ag-sap-automation' --roles Editor --service-name=is
ibmcloud iam access-group-policy-create 'ag-sap-automation' --roles Editor,Manager --service-name=transit
ibmcloud iam access-group-policy-create 'ag-sap-automation' --roles Editor,Manager --service-name=dns-svcs

# Access to create an IBM Cloud Resource Group (Ansible to Terraform)
ibmcloud iam access-group-policy-create 'ag-sap-automation' --roles Administrator --resource-type=resource-group

# Assign to a specified Account User or Service ID
ibmcloud iam access-group-user-add 'ag-sap-automation' <<<IBMid>>>
ibmcloud iam access-group-service-id-add 'ag-sap-automation' <<<SERVICE_ID_UUID>>>
```

Alternatively, use the IBM Cloud web console:
- Open cloud.ibm.com - click Manage on navbar, click Access IAM, then on left nav menu click Access Groups
- Create an Access Group, with the following policies:
  - IAM Services > VPC Infrastructure Services > click All resources as scope + Platform Access as Editor
  - IAM Services > DNS Services > click All resources as scope + Platform Access as Editor + Service access as Manager
  - IAM Services > Transit Gateway > click All resources as scope + Platform Access as Editor + Service access as Manager
  - `[OPTIONAL]` IAM Services > All Identity and Access enabled services > click All resources as scope + Platform Access as Viewer + Resource group access as Administrator
  - `[OPTIONAL]` Account Management > Identity and Access Management > click Platform access as Editor
  - `[OPTIONAL]` Account Management > IAM Access Groups Service > click All resources as scope + Platform Access as Editor

</details>

<details>
<summary><b>IBM PowerVC:</b></summary>

The recommended [IBM PowerVC Security Role](https://www.ibm.com/docs/en/powervc/latest?topic=security-managing-roles) is 'Administrator assistant' (admin_assist), because the 'Virtual machine manager' (vm_manager) role is not able to create IBM PowerVM Compute Template (required for setting OpenStack extra_specs specific to the IBM PowerVM hypervisor infrastructure platform, such as Processing Units). Note that the 'Administrator assistant' does not have the privilege to delete Virtual Machines.

</details>


## Recommended Infrastructure Platform configuration

See below for the drop-down list of recommended configurations for each Infrastructure Platform.

<details>
<summary><b>VMware vCenter:</b></summary>

The VM Template must be prepared with cloud-init. This process is subjective to VMware, cloud-init and Guest OS (RHEL / SLES) versions; success will vary. This requires:

- Edit the default cloud-init configuration file, found at `/etc/cloud/cloud.cfg`. It must contain the data source for VMware (and not OVF), and force use of cloud-init metadata and userdata files. Note: appending key `network: {config: disabled}` may cause network `v1` to be incorrectly used instead of network [`v2`](https://cloudinit.readthedocs.io/en/latest/reference/network-config-format-v2.html) in the cloud-init metadata YAML to follow.
  ```yaml
  # Enable VMware VM Guest OS Customization with cloud-init (set to true for traditional customization)
  disable_vmware_customization: false

  # Use allow raw data to directly use the cloud-init metadata and user data files provided by the VMware VM Customization Specification
  # Wait 120 seconds for VMware VM Customization file to be available
  datasource:
    VMware:
      allow_raw_data: true
      vmware_cust_file_max_wait: 60
  ```
- Update `cloud-init` and `open-vm-tools` OS Package
- Enable DHCP on the OS Network Interface (e.g. eth0, ens192 etc.)
- Prior to VM shutdown and marking as a VMware VM Template, run commands:
    - `vmware-toolbox-cmd config set deployPkg enable-custom-scripts true`
    - `vmware-toolbox-cmd config set deployPkg wait-cloudinit-timeout 60`
    - `sudo cloud-init clean --seed --logs` to remove cloud-init logs, remove cloud-init seed directory /var/lib/cloud/seed.
        - If using cloud-init versions prior to 22.3.0 then do not use `--machine-id` parameter.
        - Reportedly, the `--machine-id` parameter which removes `/etc/machine-id` may on first reboot cause the OS Network Interfaces to be `DOWN` which causes the DHCP Request to silently error.
- Once VM is shutdown, then run 'Clone > Clone as Template to Library'
- After provisioning the VM Template via Ansible, debug by checking:
    - `/var/log/vmware-imc/toolsDeployPkg.log`
    - `/var/log/cloud-init-output.log`
    - `/var/log/cloud-init.log`
    - `/var/lib/cloud/instance/user-data.txt`
    - `/var/lib/cloud/instance/cloud-config.txt`
    - `/var/run/cloud-init/instance-data.json`
    - `/var/run/cloud-init/status.json`
- See documentation for further information:
    - [VMware KB 59557 - How to switch vSphere Guest OS Customization engine for Linux virtual machine](https://kb.vmware.com/s/article/59557)
    - [VMware KB 90331 - How does vSphere Guest OS Customization work with cloud-init to customize a Linux VM](https://kb.vmware.com/s/article/90331)
    - [VMware KB 91809 - VMware guest customization key cloud-init changes](https://kb.vmware.com/s/article/91809)
    - [VMware KB 74880 - Setting the customization script for virtual machines in vSphere 7.x and 8.x](https://kb.vmware.com/s/article/74880)
    - [vSphere Web Services SDK Programming Guide - Guest Customization Using cloud-init](https://developer.vmware.com/docs/18555/GUID-75E27FA9-2E40-4CBF-BF3D-22DCFC8F11F7.html)
    - [cloud-init documentation - Reference - Datasources - VMware](https://cloudinit.readthedocs.io/en/latest/reference/datasources/vmware.html)


In addition, the provisioned Virtual Machine must be accessible from the Ansible Controller (i.e. device where Ansible Playbook for SAP is executed must be able to reach the provisioned host).

When VMware vCenter and vSphere clusters with VMware NSX virtualized network overlays using Segments (e.g. 192.168.0.0/16) connected to Tier-0/Tier-1 Gateways (which are bound to the backbone network subnet, e.g. 10.0.0.0/8), it is recommended to:
- Use DHCP Server and attach to Subnet for the target VM. For example, create DHCP Server (e.g. NSX > Networking > Networking Profiles > DHCP Profile), set DHCP in the Gateway (e.g. NSX > Networking > Gateway > Edit > DHCP Config), then set for the Subnet (e.g. NSX > Networking > Segment > <<selected subnet>> > Set DHCP Config) which the VMware VM Template is attached to; this allows subsequent cloned VMs to obtain an IPv4 Address
- Use DNAT configuration for any VMware NSX Segments (e.g. NSX-T Policy NAT Rule)
- For outbound internet connectivity, use SNAT configuration (e.g. rule added on NSX Gateway) set for the Subnet which the VMware VM Template is attached to. Alternatively, use a Web Forward Proxy.

N.B. When VMware vCenter and vSphere clusters with direct network subnet IP allocations to the VMXNet network adapter (no VMware NSX network overlays), the above actions may not be required.

</details>


## Notice regarding SAP High Availability and hardware placement strategies

Each Hyperscaler Cloud Service Provider provides a different approach to the placement strategy of a Virtual Machine to the physical/hardware Hypervisor node it runs atop.

The `sap_vm_provision` Ansible Role enforces scope control for this capability, only providing a "spread" placement strategy for the High Availability scenarios. As such the variable used is `sap_vm_provision_<<infrastructure_platform>>_placement_strategy_spread: true/false`.

The following are the equivalent Placement Strategies, commonly referenced as 'Anti-Affinity', in each Infrastructure Platform:

- **AWS EC2 VS Placement Group, Spread (Rack level)** - each VS on different hosts, in different racks with distinct network source and power supply
- **GCP CE VM Placement Policy, Spread** - each VM on different hosts, in different racks with distinct power supply (dual redundancy from different sources)
- **IBM Cloud VS Placement Group Strategy, Power Spread** - each VS on different hosts, in different racks with distinct network source and power supplies (dual redundancy from different sources)
- **IBM Cloud, IBM Power VS Placement Group Colocation Policy, Different Server Spread** - each VS on different hosts, in different racks with distinct network source and power supplies (dual redundancy from different sources)
- **MS Azure VM Availability Set, Fault Domain Spread** - each VM on different hosts, in different racks with distinct network source and power supply
