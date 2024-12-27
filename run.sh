#!/bin/bash

# Function to generate a random MAC address
generate_mac_address() {
    echo "02:$(od -An -N5 -tx1 /dev/urandom | tr ' ' ':' | cut -c2-)"
}

# Function to generate a new UUID
generate_uuid() {
    uuid=$(cat /proc/sys/kernel/random/uuid)
    echo $uuid
}

# Function to generate fake OS info
generate_fake_os_info() {
    echo "Faking OS and Kernel version..."
    os_names=("Ubuntu" "Debian" "Fedora" "CentOS" "Arch Linux" "Linux Mint" "Manjaro" "Slackware" "Raspberry Pi OS" "Pop!_OS" "Kali Linux" "openSUSE" "Alpine Linux" "FreeBSD")
    os_versions=("20.04 LTS" "21.10" "34" "8" "5.0" "19.3" "22.04 LTS" "2023" "11.0" "19.04" "3.1" "2.1" "5.1" "10.3" "12.2")
    os_kernel_versions=("5.4.0-42-generic" "5.10.0-13-amd64" "5.6.15" "4.19.0" "5.13.0" "5.14.8" "4.14.128" "5.8.0")
    os_name=${os_names[$RANDOM % ${#os_names[@]}]}
    os_version=${os_versions[$RANDOM % ${#os_versions[@]}]}
    os_kernel=${os_kernel_versions[$RANDOM % ${#os_kernel_versions[@]}]}
    echo -e "NAME=\"$os_name\"\nVERSION=\"$os_version\"\nID=ubuntu\nID_LIKE=debian\nVERSION_ID=20.04\nPRETTY_NAME=\"$os_name $os_version\"" > /etc/os-release
    echo "Linux version $os_kernel" > /proc/version
}

# Function to generate fake CPU info
generate_fake_cpu_info() {
    echo "Faking CPU info..."
    cpu_models=("Intel Core i9-9900K" "AMD Ryzen 9 5900X" "Intel Xeon E5-2680 v4" "ARM Cortex-A53" "Intel Core i7-10700K" "Intel Core i5-9600K" "AMD Ryzen 5 5600X" "Apple M1" "AMD Athlon 3000G" "Qualcomm Snapdragon 888")
    cpu_cores=$(shuf -i 2-16 -n 1)
    cpu_speed=$(shuf -i 2000-5000 -n 1)  # In MHz
    cpu_model=${cpu_models[$RANDOM % ${#cpu_models[@]}]}
    echo -e "model name\t: $cpu_model\nprocessor\t: 0\ncpu MHz\t\t: $cpu_speed\ncpu cores\t: $cpu_cores" > /proc/cpuinfo
}

# Function to generate fake memory info
generate_fake_memory_info() {
    echo "Faking memory info..."
    total_mem=$(shuf -i 4096-32768 -n 1)  # Total RAM in MB
    free_mem=$(shuf -i 1024-8192 -n 1)    # Free RAM in MB
    swap_mem=$(shuf -i 0-8192 -n 1)       # Swap space in MB
    echo -e "MemTotal:       $total_mem kB\nMemFree:        $free_mem kB\nSwapTotal:      $swap_mem kB" > /proc/meminfo
}

# Function to fake Hostname
fake_hostname() {
    echo "Faking Hostname..."
    hostnamectl set-hostname "fake-machine-$(shuf -i 1000-9999 -n 1)"
}

# Function to hide Docker-specific files
hide_docker_files() {
    echo "Hiding Docker-specific files..."
    ln -s /dev/null /sys/fs/cgroup
    ln -s /dev/null /var/lib/docker
    ln -s /dev/null /var/run/docker.sock
    ln -s /dev/null /sys/kernel/debug
    ln -s /dev/null /sys/firmware
}

# Function to hide Docker-specific directories
hide_docker_network() {
    echo "Hiding Docker network interfaces..."
    ip link set dev eth0 down
    ip link set dev docker0 down
    ip link set dev br-xxxxxxx down
}

# Function to randomize the network namespace
randomize_network_namespace() {
    echo "Randomizing network namespace..."
    ip link set dev eth0 name eth$(shuf -i 1-999 -n 1)
}

# Function to ensure a non-empty value
get_non_empty_input() {
    local prompt="$1"
    local input=""
    while [ -z "$input" ]; do
        read -p "$prompt" input
        if [ -z "$input" ]; then
            echo -e "Error: This field cannot be empty."
        fi
    done
    echo "$input"
}

# Generate random UUID and MAC address
random_uuid=$(generate_uuid)
random_mac=$(generate_mac_address)
echo "Generated UUID: $random_uuid"
echo "Generated MAC Address: $random_mac"

# Generate a random device name (e.g., device-1234)
random_device_name="device-$(shuf -i 1000-9999 -n 1)"
echo "Generated random device name: $random_device_name"

# Ask for the Docker container name
read -p "Enter a name for the Docker container: " docker_container_name

# Create a directory for the configuration (this will be used during image creation)
device_dir="./$random_device_name"
if [ ! -d "$device_dir" ]; then
    mkdir "$device_dir"
    echo "Created directory for configuration at $device_dir"
fi

# Save the UUID to a file inside the device directory
uuid_file="$device_dir/fake_uuid.txt"
echo "$random_uuid" > "$uuid_file"

# Proxy configuration
read -p "Do you want to use a proxy? (Y/N): " use_proxy

proxy_protocol=""
proxy_user=""
proxy_pass=""
proxy_ip=""
proxy_port=""

if [[ "$use_proxy" == "Y" || "$use_proxy" == "y" ]]; then
    proxy_url=$(get_non_empty_input "Enter proxy (format: protocol://user:pass@ip:port): ")

    # Parse the proxy URL
    proxy_protocol=$(echo "$proxy_url" | awk -F'://' '{print $1}')
    proxy_credentials=$(echo "$proxy_url" | awk -F'://' '{print $2}' | awk -F'@' '{print $1}')
    proxy_user=$(echo "$proxy_credentials" | awk -F':' '{print $1}')
    proxy_pass=$(echo "$proxy_credentials" | awk -F':' '{print $2}')
    proxy_address=$(echo "$proxy_url" | awk -F'@' '{print $2}')
    proxy_ip=$(echo "$proxy_address" | awk -F':' '{print $1}')
    proxy_port=$(echo "$proxy_address" | awk -F':' '{print $2}')

    if [[ -z "$proxy_protocol" || -z "$proxy_ip" || -z "$proxy_port" ]]; then
        echo "Error: Invalid proxy format. Use protocol://user:pass@ip:port"
        exit 1
    fi
fi

# Step 1: Create the Dockerfile
echo "Creating the Dockerfile..."
cat << EOL > "$device_dir/Dockerfile"
FROM ubuntu:latest
WORKDIR /app
RUN apt-get update && apt-get install -y bash curl redsocks iptables
COPY redsocks.conf /etc/redsocks.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EOL

# Create the redsocks configuration file if a proxy is used
if [[ "$use_proxy" == "Y" || "$use_proxy" == "y" ]]; then
    cat <<EOL > "$device_dir/redsocks.conf"
base {
    log_debug = off;
    log_info = on;
    log = "stderr";
    daemon = on;
    redirector = iptables;
}

redsocks {
    local_ip = 127.0.0.1;
    local_port = 12345;
    ip = $proxy_ip;
    port = $proxy_port;
    type = $proxy_protocol;
EOL

    if [[ -n "$proxy_user" && -n "$proxy_pass" ]]; then
        cat <<EOL >> "$device_dir/redsocks.conf"
    login = "$proxy_user";
    password = "$proxy_pass";
EOL
    fi

    cat <<EOL >> "$device_dir/redsocks.conf"
}
EOL

    # Create the entrypoint script
    cat <<EOL > "$device_dir/entrypoint.sh"
#!/bin/sh

echo "Starting redsocks..."
redsocks -c /etc/redsocks.conf &
sleep 3

echo "Configuring iptables for proxy redirection..."
iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-ports 12345
iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to-ports 12345
echo "Iptables configured."

exec "\$@"
EOL
fi

# Step 2: Build the Docker image
echo "Building the Docker image '$docker_container_name'..."
docker build -t "$docker_container_name" "$device_dir"

# Step 3: Run the Docker container with the specified name, random UUID, and MAC address
echo "Running the Docker container..."
docker run -it \
    --mac-address="$random_mac" \
    -v "$uuid_file:/sys/class/dmi/id/product_uuid" \
    --name="$docker_container_name" \
    "$docker_container_name"
