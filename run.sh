#!/bin/bash

# Function to generate a random MAC address
generate_mac() {
    echo $(printf '02:%02x:%02x:%02x:%02x:%02x' \
        $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)))
}

# Function to generate a random UUID
generate_uuid() {
    echo $(uuidgen)
}

# Prompt the user for container name
read -p "Enter the Docker container name: " CONTAINER_NAME

# Ensure container name is provided
if [[ -z "$CONTAINER_NAME" ]]; then
    echo "Error: Docker container name is required."
    exit 1
fi

# Ask if the user wants to use a proxy
read -p "Do you want to use a proxy? (yes/no): " USE_PROXY

if [[ "$USE_PROXY" == "yes" ]]; then
    # Prompt for proxy details
    read -p "Enter proxy in format protocol://user:pass@ip:port: " PROXY
    # Validate proxy format
    if [[ ! "$PROXY" =~ ^[a-zA-Z]+://[^\s:@]+(:[^\s:@]+)?@[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
        echo "Error: Invalid proxy format. Expected format: protocol://user:pass@ip:port"
        exit 1
    fi
else
    PROXY=""
fi

# Generate UUID and MAC address
UUID=$(generate_uuid)
MAC=$(generate_mac)

# Output results
echo "Container Name: $CONTAINER_NAME"
echo "Generated UUID: $UUID"
echo "Generated MAC Address: $MAC"

if [[ -n "$PROXY" ]]; then
    echo "Using Proxy: $PROXY"
else
    echo "No Proxy Configured"
fi
