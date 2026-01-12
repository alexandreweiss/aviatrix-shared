# Standalone Scripts Approach - Migration Guide

This directory has been refactored to use standalone script files instead of templatefile rendering for cloud-init. This approach solves issues with bash script variables that are not well escaped when using Terraform's templatefile function.

## What Changed

### Before (templatefile approach)
- Single `cloud-init.yaml` file with embedded bash scripts
- Used `templatefile()` function to substitute variables like `${workspace_id}`, `${admin_password}`
- Required escaping bash variables with `$$` to avoid conflicts
- Complex to debug and maintain

### After (standalone scripts approach)
- Separate script files in `scripts/` directory
- Simple `cloud-init-standalone.yaml` that downloads and executes scripts
- Configuration passed via `config.env` file uploaded to Azure Storage
- No variable escaping issues in bash scripts

## File Structure

```
├── cloud-init-standalone.yaml     # New simplified cloud-init file
├── config.env.tpl                # Configuration template
├── scripts/                      # Standalone script files
│   ├── setup-disk.sh            # Disk partitioning and mounting
│   ├── setup-edge.sh             # Download Aviatrix Edge images
│   ├── setup-fileshare.sh        # Azure File Share mounting
│   ├── setup-networks.sh         # KVM network configuration
│   ├── create-vm.sh              # Create Aviatrix Edge VM
│   ├── delete-vm.sh              # Delete VMs
│   └── create-evp-router.sh      # Create EVP router VM
├── cloud-init.yaml               # Original file (kept for reference)
└── cloud-init-simple.yaml        # Alternative approach (not used)
```

## How It Works

1. **Terraform Phase:**
   - Creates Azure Storage Account with a `scripts` container
   - Uploads all script files to the container with public blob access
   - Generates `config.env` from template with actual values
   - Uploads config.env to storage

2. **Cloud-Init Phase:**
   - Downloads `config.env` and all script files from Azure Storage
   - Makes scripts executable
   - Sources `config.env` in scripts that need configuration variables
   - Executes scripts in the correct order

3. **Script Execution:**
   - Each script is self-contained and executable
   - Scripts that need configuration source `/tmp/config.env`
   - No variable escaping issues with `$$`
   - Easier to test and debug individually

## Benefits

1. **No Variable Escaping:** Bash variables can be used normally (e.g., `$VARIABLE` instead of `$$VARIABLE`)
2. **Easier Debugging:** Each script can be tested independently
3. **Better Maintainability:** Scripts are separated by function
4. **Reusability:** Scripts can be reused in other contexts
5. **Cleaner Code:** No complex templatefile interpolation

## Configuration Variables

The following variables are passed to scripts via `config.env`:

- `WORKSPACE_ID`: Terraform workspace number for network configuration
- `ADMIN_PASSWORD`: Password for admin-lab user
- `STORAGE_ACCOUNT_NAME`: Azure Storage Account name
- `STORAGE_ACCOUNT_KEY`: Azure Storage Account key
- `SITE`: Site identifier for VM creation

## Usage

Scripts are automatically downloaded and executed during cloud-init. After VM provisioning, you can also:

1. **SSH to the VM:**
   ```bash
   ssh -i ssh-key-<workspace>.pem admin-lab@<public-ip>
   ```

2. **Run VM management scripts:**
   ```bash
   # Create an Aviatrix Edge VM
   ./create-vm.sh edge-gw-01 mumbai
   
   # Create an EVP router VM
   ./create-evp-router.sh evp-router-01
   
   # Delete a VM
   ./delete-vm.sh edge-gw-01
   ```

3. **Access Cockpit web interface:**
   - URL provided in Terraform outputs
   - Manage VMs through web interface

## Testing Individual Scripts

You can test scripts individually by:

1. Creating a test `config.env` file with required variables
2. Running the script: `./scripts/setup-networks.sh`

## Migration Notes

- Original `cloud-init.yaml` is preserved for reference
- The new approach is fully backward compatible
- All existing functionality is maintained
- VM creation and management scripts work identically

## Troubleshooting

If scripts fail to download or execute:

1. Check Azure Storage container permissions (should be public blob access)
2. Verify network connectivity from VM to Azure Storage
3. Check cloud-init logs: `sudo tail -f /var/log/cloud-init-output.log`
4. Manually download and test scripts for debugging

## Future Enhancements

1. Script versioning for updates
2. Checksum validation for downloaded scripts
3. Fallback mechanisms for script download failures
4. Script dependency management