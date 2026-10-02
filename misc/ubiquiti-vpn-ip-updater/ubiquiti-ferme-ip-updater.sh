#!/bin/bash

# Ubiquiti EdgeRouter ER-X VPN Peer IP Updater
# This script monitors ferme.ddns.net and updates IPsec peer configuration when IP changes
# Place this script in /config/scripts/ on your EdgeRouter
# Schedule with: set system task-scheduler task update-ferme-ip executable path /config/scripts/ubiquiti-ferme-ip-updater.sh
# Schedule with: set system task-scheduler task update-ferme-ip interval 5m

# Configuration variables
DDNS_HOSTNAME="ferme.ddns.net"
VPN_DESCRIPTION="ferme"
PRE_SHARED_SECRET="xxxxxxxxxx"
REMOTE_ID="192.168.50.2"
LOCAL_ADDRESS="192.168.111.2"
IKE_GROUP="ferme-ike"
ESP_GROUP="ferme-esp"
VTI_INTERFACE="vti1"
LOG_FILE="/var/log/ferme-ip-updater.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to get current configured peer IP
get_configured_peer_ip() {
    # Get all configured VPN peers and find the one with ferme description
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
    local peer_ip=$(/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show vpn ipsec site-to-site peer | grep -B20 "description $VPN_DESCRIPTION" | grep "peer " | head -n1 | awk '{print $2}')
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end
    echo $peer_ip
}

# Function to resolve DDNS hostname to IP
resolve_hostname() {
    # Use ping to resolve hostname to IP address
    local ping_output=$(ping -c 1 -W 5 "$DDNS_HOSTNAME" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        # Extract IP from ping output using regex for complete IP address
        local ip=$(echo "$ping_output" | head -n1 | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n1)
        if [[ -n "$ip" ]]; then
            echo $ip
            return 0
        fi
        
        # Alternative extraction for format: PING hostname (ip) ...
        local ip=$(echo "$ping_output" | head -n1 | sed -n 's/.*(\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)).*/\1/p')
        if [[ -n "$ip" ]]; then
            echo $ip
            return 0
        fi
    fi
    
    # If ping failed, return empty
    echo ""
}

# Function to validate IP address format
is_valid_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra ADDR <<< "$ip"
        for i in "${ADDR[@]}"; do
            if [[ $i -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# Function to configure new VPN peer
configure_new_peer() {
    local new_ip=$1
    local old_ip=$2
    
    log_message "Configuring new peer with IP: $new_ip"
    
    # Enter configuration mode
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
    
    # Remove old peer configuration if it exists
    if [[ -n "$old_ip" && "$old_ip" != "$new_ip" ]]; then
        log_message "Removing old peer configuration for IP: $old_ip"
        /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper delete vpn ipsec site-to-site peer "$old_ip"
    fi
    
    # Configure new peer
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" authentication mode pre-shared-secret
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" authentication pre-shared-secret "'$PRE_SHARED_SECRET'"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" authentication remote-id "$REMOTE_ID"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" connection-type initiate
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" description "$VPN_DESCRIPTION"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" ike-group "$IKE_GROUP"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" ikev2-reauth inherit
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" local-address "$LOCAL_ADDRESS"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" vti bind "$VTI_INTERFACE"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set vpn ipsec site-to-site peer "$new_ip" vti esp-group "$ESP_GROUP"
    
    # Commit and save configuration
    if /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit; then
        /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
        /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end
        log_message "Configuration successfully committed and saved"
        
        # Restart IPsec to apply changes
        sudo ipsec restart
        log_message "IPsec service restarted"
        return 0
    else
        log_message "ERROR: Failed to commit configuration"
        /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper discard
        /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end
        return 1
    fi
}

# Main script execution
log_message "Starting ferme IP update check"

# Get current resolved IP
CURRENT_IP=$(resolve_hostname)

if [[ -z "$CURRENT_IP" ]]; then
    log_message "ERROR: Failed to resolve $DDNS_HOSTNAME"
    exit 1
fi

if ! is_valid_ip "$CURRENT_IP"; then
    log_message "ERROR: Invalid IP address resolved: $CURRENT_IP"
    exit 1
fi

log_message "Resolved $DDNS_HOSTNAME to IP: $CURRENT_IP"

# Get currently configured peer IP
CONFIGURED_IP=$(get_configured_peer_ip)

if [[ -n "$CONFIGURED_IP" ]]; then
    log_message "Currently configured peer IP: $CONFIGURED_IP"
    
    # Check if IPs are different
    if [[ "$CURRENT_IP" != "$CONFIGURED_IP" ]]; then
        log_message "IP address has changed! Updating configuration..."
        if configure_new_peer "$CURRENT_IP" "$CONFIGURED_IP"; then
            log_message "Successfully updated VPN peer configuration"
        else
            log_message "ERROR: Failed to update VPN peer configuration"
            exit 1
        fi
    else
        log_message "IP address unchanged. No configuration update needed."
    fi
else
    log_message "No existing peer configuration found. Creating new configuration..."
    if configure_new_peer "$CURRENT_IP" ""; then
        log_message "Successfully created new VPN peer configuration"
    else
        log_message "ERROR: Failed to create VPN peer configuration"
        exit 1
    fi
fi

log_message "Script execution completed"