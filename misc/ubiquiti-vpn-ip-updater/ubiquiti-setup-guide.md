# Ubiquiti EdgeRouter Dynamic VPN Peer Updater

This guide explains how to install and configure the ferme.ddns.net IP updater script on your Ubiquiti EdgeRouter ER-X.

## What it does

The script monitors `ferme.ddns.net` and automatically updates your IPsec VPN peer configuration when the IP address changes. It will:

- Resolve the current IP of ferme.ddns.net
- Compare it with the configured VPN peer IP
- If different, create new peer configuration and remove the old one
- Commit and save the configuration
- Restart IPsec service

## Installation Steps

### 1. Copy the script to your EdgeRouter

```bash
# SSH to your EdgeRouter
ssh ubnt@your-router-ip

# Create scripts directory if it doesn't exist
sudo mkdir -p /config/scripts

# Create the script file
sudo vi /config/scripts/ubiquiti-ferme-ip-updater.sh
# Copy the content from ubiquiti-ferme-ip-updater.sh into this file

# Make the script executable
sudo chmod +x /config/scripts/ubiquiti-ferme-ip-updater.sh

# Create log directory
sudo mkdir -p /var/log
sudo touch /var/log/ferme-ip-updater.log
sudo chmod 666 /var/log/ferme-ip-updater.log
```

### 2. Test the script manually

```bash
# Run the script once to test
sudo /config/scripts/ubiquiti-ferme-ip-updater.sh

# Check the log
tail -f /var/log/ferme-ip-updater.log
```

### 3. Configure cron job via EdgeRouter CLI

```bash
# Enter configuration mode
configure

# Create task scheduler entry (runs every 5 minutes)
set system task-scheduler task update-ferme-ip executable path /config/scripts/ubiquiti-ferme-ip-updater.sh
set system task-scheduler task update-ferme-ip interval 5m

# Commit and save
commit
save
exit
```

### 4. Alternative: Configure cron job directly (if task-scheduler doesn't work)

```bash
# Edit crontab
sudo crontab -e

# Add this line (runs every 5 minutes)
*/5 * * * * /config/scripts/ubiquiti-ferme-ip-updater.sh

# Save and exit
```

## Configuration Variables

Edit these variables at the top of the script if needed:

- `DDNS_HOSTNAME`: The dynamic DNS hostname to monitor
- `VPN_DESCRIPTION`: Description used to identify the VPN peer
- `PRE_SHARED_SECRET`: Your VPN pre-shared key
- `REMOTE_ID`: Remote ID for authentication
- `LOCAL_ADDRESS`: Your local VPN endpoint IP
- `IKE_GROUP` and `ESP_GROUP`: IPsec groups
- `VTI_INTERFACE`: Virtual tunnel interface

## Monitoring

### Check logs
```bash
# View recent log entries
tail -20 /var/log/ferme-ip-updater.log

# Follow log in real-time
tail -f /var/log/ferme-ip-updater.log
```

### Check current VPN status
```bash
# Show VPN peers
show vpn ipsec sa

# Show current configuration
show vpn ipsec site-to-site peer
```

### Check task scheduler status
```bash
# Show scheduled tasks
show system task-scheduler

# Show task logs
show log | match "task-scheduler"
```

## Troubleshooting

### Script not running
- Verify the script has execute permissions: `ls -la /config/scripts/`
- Check task scheduler configuration: `show system task-scheduler`
- Verify cron is running: `ps aux | grep cron`

### DNS resolution issues
- Test manual resolution: `nslookup ferme.ddns.net`
- Check DNS configuration: `show system name-server`

### VPN configuration issues
- Verify IKE and ESP groups exist: `show vpn ipsec ike-group` and `show vpn ipsec esp-group`
- Check if VTI interface exists: `show interfaces vti`

### Permissions issues
- Ensure script runs as root or with proper sudo permissions
- Check log file permissions: `ls -la /var/log/ferme-ip-updater.log` 

## Manual trigger

To manually trigger an update check:

```bash
sudo /config/scripts/ubiquiti-ferme-ip-updater.sh
```

## Backup recommendation

Before deploying, backup your current configuration:

```bash
# From operational mode
show configuration commands > /tmp/backup-config.txt
```