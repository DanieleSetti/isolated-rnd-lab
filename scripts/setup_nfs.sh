#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root"
   exit 1
fi

# Install NFS if it's not already installed
apt update && apt install -y nfs-kernel-server

# Directory to export
EXPORT_DIR="/home"

# Allowed client IP or subnet (you can change this to your network)
ALLOWED_IP="192.168.56.0/24"

# Configure the export
echo "$EXPORT_DIR $ALLOWED_IP(rw,sync,no_subtree_check)" > /etc/exports

# Apply the export changes
exportfs -ra

# Restart the NFS service
systemctl restart nfs-kernel-server
echo "NFS is configured and exporting $EXPORT_DIR to $ALLOWED_IP"
