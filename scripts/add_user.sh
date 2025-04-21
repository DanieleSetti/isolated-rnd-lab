#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run the script as root"
   exit 1
fi

# Check for username argument
if [ -z "$1" ]; then
  echo "Usage: $0 username"
  exit 1
fi

USERNAME=$1
GROUP="developers"

# Create group if it doesn't exist
if ! getent group $GROUP > /dev/null; then
  groupadd $GROUP
fi

# Create user if they don't exist
if ! id "$USERNAME" &>/dev/null; then
  useradd -m -s /bin/bash -g $GROUP "$USERNAME"
  echo "User $USERNAME created."
else
  echo "User $USERNAME already exists."
fi

# Create user folder in the NFS directory if it doesn't exist
USER_DIR="/home/$USERNAME"
if [ ! -d "$USER_DIR" ]; then
  mkdir -p "$USER_DIR"
  chown "$USERNAME:$GROUP" "$USER_DIR"
  chmod 700 "$USER_DIR"
  echo "Directory $USER_DIR created and configured."
fi

# SSH key generation can be added if needed
# su - "$USERNAME" -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"

echo "User $USERNAME has been added and the directory has been set up."
