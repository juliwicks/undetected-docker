#!/bin/bash

# Define color codes
INFO='\033[0;36m'  # Cyan
BANNER='\033[0;35m' # Magenta
WARNING='\033[0;33m'
ERROR='\033[0;31m'
SUCCESS='\033[0;32m'
NC='\033[0m' # No Color

# Function to display the banner
display_banner() {
    echo -e "${BANNER}                 _      _            _           _           ${NC}"
    echo -e "${BANNER} /\ /\ _ __   __| | ___| |_ ___  ___| |_ ___  __| | ${NC}"
    echo -e "${BANNER}/ / \\ \\ '_ \\ / _\` |/ _ \\ __/ _ \\/ __| __/ _ \\/ _\` | ${NC}"
    echo -e "${BANNER}\\ \\_/ / | | | (_| |  __/ ||  __/ (__| ||  __/ (_| | ${NC}"
    echo -e "${BANNER} \\___/|_| |_|\__,_|\___|\__\\___|\\___|\\__\\___|\__,_| ${NC}"
    echo -e "${BANNER}                                                   ${NC}"
    echo -e "${BANNER}    ___           _                     _   ___    ${NC}"
    echo -e "${BANNER}   /   \\___   ___| | _____ _ __  __   _/ | / _ \\   ${NC}"
    echo -e "${BANNER}  / /\\ / _ \\ / __| |/ / _ \\ '__| \\ \\ / / || | | |  ${NC}"
    echo -e "${BANNER} / /_// (_) | (__|   <  __/ |     \\ V /| || |_| |  ${NC}"
    echo -e "${BANNER}/___,' \\___/ \\___|_|\_\___|_|      \\_/ |_(_)___/   ${NC}"
    echo -e "${NC}"  # Reset color
}

display_banner()

# Function to generate a random MAC address
generate_mac_address() {
    mac="02:$(od -An -N5 -tx1 /dev/urandom | tr ' ' ':' | cut -c2-)"
    echo "$mac"
}

# Function to generate a random UUID
generate_uuid() {
    uuid=$(cat /proc/sys/kernel/random/uuid)
    echo "$uuid"
}

# Function to generate fake OS info
generate_fake_os_info() {
    os_names=("Ubuntu" "Debian" "Fedora" "CentOS" "Arch Linux" "Linux Mint" "Manjaro" "Slackware" "Raspberry Pi OS" "Pop!_OS" "Kali Linux" "openSUSE" "Alpine Linux" "FreeBSD")
    os_versions=("20.04 LTS" "21.10" "34" "8" "5.0" "19.3" "22.04 LTS" "2023" "11.0" "19.04" "3.1" "2.1" "5.1" "10.3" "12.2")
    os_kernel_versions=("5.4.0-42-generic" "5.10.0-13-amd64" "5.6.15" "4.19.0" "5.13.0" "5.14.8" "4.14.128" "5.8.0")
    os_name=${os_names[$RANDOM % ${#os_names[@]}]}
    os_version=${os_versions[$RANDOM % ${#os_versions[@]}]}
    os_kernel=${os_kernel_versions[$RANDOM % ${#os_kernel_versions[@]}]}
    echo -e "NAME=\"$os_name\"\nVERSION=\"$os_version\"\nID=ubuntu\nID_LIKE=debian\nVERSION_ID=20.04\nPRETTY_NAME=\"$os_name $os_version\"" | sudo tee /etc/os-release > /dev/null
    echo "Linux version $os_kernel" | sudo tee /proc/version > /dev/null
}

# Function to generate fake CPU info
generate_fake_cpu_info() {
    processor_types=("Intel" "AMD" "ARM" "Qualcomm" "Apple")
    intel_models=("Core i9-9900K" "Core i7-10700K" "Core i5-11600K" "Core i7-9700K" "Core i9-12900K" "Core i5-9600K")
    amd_models=("Ryzen 9 5900X" "Ryzen 7 5800X" "Ryzen 5 5600X" "Ryzen 9 5950X" "Ryzen 7 3800X" "Ryzen 5 3600")
    arm_models=("Cortex-A53" "Cortex-A72" "Cortex-A76" "Cortex-A9" "Cortex-A55")
    qualcomm_models=("Snapdragon 888" "Snapdragon 865" "Snapdragon 845" "Snapdragon 710")
    apple_models=("M1" "M1 Pro" "M2" "A13 Bionic")

    processor_type=${processor_types[$RANDOM % ${#processor_types[@]}]}
    case $processor_type in
        "Intel")
            cpu_model="Intel ${intel_models[$RANDOM % ${#intel_models[@]}]}"
            ;;
        "AMD")
            cpu_model="AMD ${amd_models[$RANDOM % ${#amd_models[@]}]}"
            ;;
        "ARM")
            cpu_model="ARM ${arm_models[$RANDOM % ${#arm_models[@]}]}"
            ;;
        "Qualcomm")
            cpu_model="Qualcomm ${qualcomm_models[$RANDOM % ${#qualcomm_models[@]}]}"
            ;;
        "Apple")
            cpu_model="Apple ${apple_models[$RANDOM % ${#apple_models[@]}]}"
            ;;
        *)
            cpu_model="Unknown Processor"
            ;;
    esac

    cpu_cores=$(shuf -i 2-16 -n 1)
    cpu_speed=$(shuf -i 2000-5000 -n 1)  # In MHz

    echo -e "model name\t: $cpu_model\nprocessor\t: 0\ncpu MHz\t\t: $cpu_speed\ncpu cores\t: $cpu_cores" | sudo tee /proc/cpuinfo > /dev/null
}

# Function to generate fake memory info
generate_fake_memory_info() {
    total_mem=$(shuf -i 4096-32768 -n 1)  # Total RAM in MB
    free_mem=$(shuf -i 1024-8192 -n 1)    # Free RAM in MB
    swap_mem=$(shuf -i 0-8192 -n 1)       # Swap space in MB
    echo -e "MemTotal:       $total_mem kB\nMemFree:        $free_mem kB\nSwapTotal:      $swap_mem kB" | sudo tee /proc/meminfo > /dev/null
}

# Function to generate a fake hostname
generate_fake_hostname() {
    first_names=("Alice" "Bob" "Charlie" "David" "Eva" "Frank" "Grace" "Hannah" "Ian" "Jack" "Kelly" "Liam" "Xiu" "Yuki" "Hiroshi" "Jin" "Siti" "Wei" "Akira" "Mei")
    last_names=("Smith" "Johnson" "Brown" "Taylor" "Anderson" "Thomas" "Jackson" "White" "Harris" "Martin" "Lee" "Wang" "Tanaka" "Li" "Nguyen" "Zhang" "Kumar" "Singh")
    places=("Paris" "London" "Berlin" "Tokyo" "NewYork" "Sydney" "Rome" "Madrid" "LosAngeles" "Chicago" "Toronto" "Beijing" "Shanghai" "Bangkok" "Seoul" "Mumbai" "Delhi" "Jakarta")
    random_first_name=${first_names[$RANDOM % ${#first_names[@]}]}
    random_last_name=${last_names[$RANDOM % ${#last_names[@]}]}
    random_place=${places[$RANDOM % ${#places[@]}]}
    random_hostname="${random_first_name}-${random_last_name}-${random_place}"
    sudo hostnamectl set-hostname "$random_hostname"
    echo "$random_hostname"
}

# Function to randomize network namespace
randomize_network_namespace() {
    random_namespace="netns-$(shuf -i 1000-9999 -n 1)"
    sudo ip link set dev eth0 netns $random_namespace
    echo "$random_namespace"
}

# Function to randomize timezone and locale based on proxy region
randomize_timezone_and_locale() {
    if [ -z "$http_proxy" ]; then
        echo -e "${INFO}No proxy set, skipping timezone and locale randomization.${NC}"
        return
    fi

    echo -e "${INFO}Proxy detected, randomizing timezone and locale...${NC}"

    # Extract region from proxy (you could use an API to get location based on proxy IP)
    # In this example, we'll assume proxy region as a placeholder, for example "US" or "EU"
    proxy_region="US"

    if [ "$proxy_region" == "US" ]; then
        echo "America/New_York" | sudo tee /etc/timezone > /dev/null
        sudo locale-gen "en_US.UTF-8"
        sudo update-locale LANG=en_US.UTF-8
    elif [ "$proxy_region" == "EU" ]; then
        echo "Europe/Paris" | sudo tee /etc/timezone > /dev/null
        sudo locale-gen "fr_FR.UTF-8"
        sudo update-locale LANG=fr_FR.UTF-8
    else
        echo "Asia/Tokyo" | sudo tee /etc/timezone > /dev/null
        sudo locale-gen "ja_JP.UTF-8"
        sudo update-locale LANG=ja_JP.UTF-8
    fi
}

# Function to set proxy if selected
set_proxy() {
    echo -e "\nWould you like to set a proxy? (yes/no)"
    read -r proxy_choice
    if [[ "$proxy_choice" == "yes" ]]; then
        echo -e "\nEnter proxy details in format protocol://user:pass@ip:port (e.g., http://user:pass@192.168.1.1:8080)"
        read -r proxy
        export http_proxy="$proxy"
        export https_proxy="$proxy"
        echo -e "${SUCCESS}Proxy set to: $proxy${NC}"
    fi
}

# Main execution starts here
echo "Enter the Docker container name:"
read -r docker_name

echo "Generating random data..."

mac_address=$(generate_mac_address)
uuid=$(generate_uuid)
generate_fake_os_info
generate_fake_cpu_info
generate_fake_memory_info
hostname=$(generate_fake_hostname)
device_name=$(generate_fake_device_name)
network_namespace=$(randomize_network_namespace)

# Set proxy if required
set_proxy

# Randomize timezone and locale based on proxy region
randomize_timezone_and_locale

# Output the results
echo -e "\n${SUCCESS}Randomized Docker container data for $docker_name:${NC}"
echo -e "${INFO}MAC Address: ${mac_address}${NC}"
echo -e "${INFO}UUID: ${uuid}${NC}"
echo -e "${INFO}OS Info:$(cat /etc/os-release)${NC}"
echo -e "${INFO}Memory Info:$(cat /proc/meminfo | head -n 5)${NC}"
echo -e "${INFO}Hostname: ${hostname}${NC}"
echo -e "${INFO}Device Name: ${device_name}${NC}"
echo -e "${INFO}Network Namespace: ${network_namespace}${NC}"
