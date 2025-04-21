#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run the script as root"
   exit 1
fi

# Check for client name argument
if [ -z "$1" ]; then
  echo "Usage: $0 client_name"
  exit 1
fi

CLIENT=$1
EASYRSA_DIR="/etc/openvpn/easy-rsa"
OUTPUT_DIR="/etc/openvpn/client-configs/files"
BASE_CONFIG="/etc/openvpn/client-configs/base.conf"

cd $EASYRSA_DIR

# Generate client keys and certificates
./easyrsa build-client-full $CLIENT nopass

# Generate the .ovpn client configuration file
cat $BASE_CONFIG \
    <(echo -e '<ca>') $EASYRSA_DIR/pki/ca.crt <(echo -e '</ca>\n<cert>') \
    $EASYRSA_DIR/pki/issued/$CLIENT.crt <(echo -e '</cert>\n<key>') \
    $EASYRSA_DIR/pki/private/$CLIENT.key <(echo -e '</key>\n<tls-auth>') \
    /etc/openvpn/ta.key <(echo -e '</tls-auth>') \
    > $OUTPUT_DIR/$CLIENT.ovpn

echo "VPN profile for $CLIENT has been created and saved to $OUTPUT_DIR/$CLIENT.ovpn"
