# Aviatrix Edge KVM Azure Deployment

This Terraform configuration deploys an Azure Virtual Machine configured as a KVM hypervisor for running Aviatrix Edge Gateway virtual machines.

## Prerequisites

### Terraform Workspace Configuration

**IMPORTANT**: Before deployment, you must create and select a Terraform workspace with a numeric value between 1 and 200.

The workspace value is used in the LAN network CIDR configuration (`172.22.{workspace}.0/24`), so it must be a valid number within the specified range.

#### Create and Select Workspace

```bash
# Create a new workspace (replace 'XX' with a number between 1-200)
terraform workspace new XX

# Or select an existing workspace
terraform workspace select XX

# Verify current workspace
terraform workspace show
```

#### Valid Workspace Examples
- `terraform workspace new 1` → LAN CIDR: `172.22.1.0/24`
- `terraform workspace new 50` → LAN CIDR: `172.22.50.0/24`
- `terraform workspace new 200` → LAN CIDR: `172.22.200.0/24`

#### Invalid Workspace Examples
- `terraform workspace new dev` ❌ (not numeric)
- `terraform workspace new 0` ❌ (below range)
- `terraform workspace new 255` ❌ (above range)

## Deployment

1. **Set workspace** (required):
   ```bash
   terraform workspace new 10  # Replace 10 with your desired number (1-200)
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan deployment**:
   ```bash
   terraform plan
   ```

4. **Apply configuration**:
   ```bash
   terraform apply
   ```

## Configuration Variables

- `admin_password`: Password for the admin-lab user (default: "ChangeMe123!")
  ```bash
  terraform apply -var="admin_password=YourSecurePassword"
  ```

## Resources Created

- **Virtual Machine**: Standard_D2as_v6 running Ubuntu 22.04 with KVM/QEMU
- **Storage**: 30GB OS disk + 100GB data disk for VM storage
- **Networking**: VNet with public IP and security groups for SSH (22) and Cockpit (9090)
- **Storage Account**: Azure File Share for ISO storage
- **KVM Networks**: Three virtual networks (wan, lan, mgmt) with workspace-specific addressing

## Network Configuration

The deployment creates three KVM virtual networks:

- **WAN Network**: `172.22.1.0/24` (static)
- **LAN Network**: `172.22.{workspace}.0/24` (workspace-dependent)
- **MGMT Network**: `172.22.12.0/24` (static)

## Access

After deployment:

- **SSH**: `ssh -i ssh-key-{workspace}.pem admin-lab@{vm-fqdn}`
- **Cockpit Web Interface**: `https://{vm-fqdn}:9090`
- **Default Password**: As specified in `admin_password` variable

## Edge VM ISO Requirements

**IMPORTANT**: Before creating Edge VMs, you must upload the appropriate ISO files to the Azure File Share with the correct naming convention.

### ISO Upload Steps

1. **Access the storage account** created by this deployment (`edgekvmsa{workspace}`)

2. **Navigate to the `edge-isos` file share**

3. **Upload ISO files** with the naming convention: `{vm-name}-{site}.iso`

### Naming Examples
- For VM `edge-gw-01` in `india` site: `edge-gw-01-india.iso`
- For VM `edge-gw-02` in `mumbai` site: `edge-gw-02-mumbai.iso`
- For VM `router-01` in `singapore` site: `router-01-singapore.iso`

### Alternative Upload Methods

**Using Azure CLI:**
```bash
# Upload ISO to the file share
az storage file upload \
  --account-name edgekvmsa{workspace} \
  --share-name edge-isos \
  --source /path/to/your-iso.iso \
  --path vm-name-site.iso \
  --account-key {storage-key}
```

**Using the VM's mounted file share:**
```bash
# Copy ISO file to the mounted directory
sudo cp /path/to/your-iso.iso /mnt/edge-isos/vm-name-site.iso
```

**Note**: The storage account key can be found in the Terraform output or Azure portal.

## VM Management Scripts

The deployment includes helper scripts for managing KVM virtual machines:

- `/home/admin-lab/create-vm.sh <vm-name>`: Create new VM
- `/home/admin-lab/delete-vm.sh <vm-name>`: Delete existing VM
- `/home/admin-lab/mount-fileshare.sh <storage-account> <key>`: Mount Azure File Share

## Clean Up

```bash
terraform destroy
```