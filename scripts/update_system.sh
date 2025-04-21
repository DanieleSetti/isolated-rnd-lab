#!/bin/bash

# Update system script
LOGFILE="/var/log/update_system.log"
echo "==== $(date '+%Y-%m-%d %H:%M:%S') ====" >> "$LOGFILE"
apt update && apt upgrade -y >> "$LOGFILE" 2>&1
echo "Update finished." >> "$LOGFILE"
