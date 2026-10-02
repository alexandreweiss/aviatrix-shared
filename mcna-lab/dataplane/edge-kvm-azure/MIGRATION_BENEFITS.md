# Before vs After: Template Variable Escaping Issues

## Problem with templatefile() approach

In the original `cloud-init.yaml`, bash variables had to be escaped with `$$` to avoid conflicts with Terraform's templatefile function:

### Example 1: Variable Assignment
```yaml
# Before (templatefile) - Required $$ escaping
DISK="/dev/nvme0n2"
PART="$${DISK}p1"          # Had to use $$DISK
MOUNTPOINT="/virtu"
```

```bash
# After (standalone scripts) - Normal bash syntax
DISK="/dev/nvme0n2"
PART="${DISK}p1"           # Normal ${DISK}
MOUNTPOINT="/virtu"
```

### Example 2: Conditional Checks  
```yaml
# Before (templatefile) - Complex escaping
if [[ ! -b "$$PART" ]]; then
  echo "Creating GPT and primary partition on $${DISK}..."
  parted -s "$$DISK" mkpart primary "$${FS_TYPE}" 0% 100%
fi
```

```bash
# After (standalone scripts) - Clean and readable
if [[ ! -b "$PART" ]]; then
  echo "Creating GPT and primary partition on ${DISK}..."
  parted -s "$DISK" mkpart primary "${FS_TYPE}" 0% 100%
fi
```

### Example 3: Command Substitution
```yaml
# Before (templatefile) - Confusing escaping  
UUID=$$(blkid -s UUID -o value "$$PART")
if ! grep -q "$$UUID" "$$FSTAB"; then
  echo "$$FSTAB_LINE" >> "$$FSTAB"
fi
```

```bash
# After (standalone scripts) - Standard bash
UUID=$(blkid -s UUID -o value "$PART")
if ! grep -q "$UUID" "$FSTAB"; then
  echo "$FSTAB_LINE" >> "$FSTAB"
fi
```

### Example 4: Array Processing
```yaml
# Before (templatefile) - Difficult to read
networks=("wan" "lan" "mgmt")
for network in "$${networks[@]}"
do
  echo "Creating network: $$network"
  virsh net-define /tmp/$${network}-network.xml
done
```

```bash
# After (standalone scripts) - Natural bash syntax
networks=("wan" "lan" "mgmt")
for network in "${networks[@]}"
do
  echo "Creating network: $network"
  virsh net-define /tmp/${network}-network.xml
done
```

## Benefits Summary

| Aspect | templatefile() Approach | Standalone Scripts Approach |
|--------|------------------------|---------------------------- |
| **Variable Syntax** | `$$VARIABLE` (confusing) | `$VARIABLE` (standard) |
| **Debugging** | Hard to test embedded scripts | Easy to test individual scripts |
| **Maintenance** | Single large file | Modular script files |
| **Readability** | Cluttered with escaping | Clean, standard bash |
| **Reusability** | Tied to cloud-init template | Reusable in other contexts |
| **Error Isolation** | Hard to pinpoint issues | Clear script-level errors |
| **Version Control** | Large diff for small changes | Focused diffs per script |

## Migration Impact

✅ **Zero functional changes** - All existing functionality preserved
✅ **Same VM creation commands** - `create-vm.sh`, `delete-vm.sh`, etc. work identically  
✅ **Same network configuration** - KVM networks created with same IPs
✅ **Same file locations** - Scripts still copied to `/home/admin-lab/`
✅ **Same user experience** - Cockpit, SSH access, all the same

The only difference is **how** the scripts are delivered and executed - much cleaner now!