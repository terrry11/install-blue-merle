#!/bin/bash

#==================== Main function ====================
main() {
    pre_install             # Pre-install message.
    parse_args $1           # Get data from user.
    test_conn               # Exit if no connection.
    parse_github            # Query GH for download URL.
    detect_os               # Install dependencies.
    ssh_install             # Install script.
}

#==================== Define functions ====================
# Print pre-install message.
pre_install() {
printf "\nWarning: Please ensure that you are running the latest firmware!\n"
printf "Device's side-switch should be in the down position. (away from recessed dot)\n\n"
}

# Define command-line arguments, prompt user for ip, validate inputs.
parse_args() {
    # IP address
    if [[ $1 ]] ; then ip_addr=$1 ; fi
    get_ip
}

# Read and validate IP Address.
get_ip() {
    local valid_ip="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
    if [[ ! $ip_addr =~ $valid_ip ]] ; then
        while true; do
            echo ; read -p "Enter IP address: " ip_addr
            if [[ $ip_addr =~ $valid_ip ]] ; then
                break
            else
                printf "\nERROR: Invalid IP address format.\nPlease enter a valid IP address.\n"
            fi
        done
    fi
}

# Check to see if device and Github are responding.
test_conn() {
    # Check for SSH on port 22 with netcat.
    if nc -z -w1 $ip_addr 22 &> /dev/null ; then
        printf "\nProvided IP Address: $ip_addr\n\nDevice is responding.\n\n"
    else
        printf "\nERROR: No route to device!\nAre you behind a VPN or connected to the wrong network?\n"
        printf "Please ensure connectivity to device and try again.\n\n" ; exit 1
    fi
    # Check for internet connectivity with ping.
    if ping -c 1 github.com &> /dev/null ; then
        printf "You are connected to the internet.\n\n"
    else
        printf "\nERROR: You are NOT connected to the internet.\n\n"
        printf "Please ensure internet connectivity and try again.\n\n" ; exit 1
    fi
}

# Query GH API for latest download URL.
parse_github() {
    local auth='srlabs'
    local repo='blue-merle'
    local api_url="https://api.github.com/repos/$auth/$repo/releases/latest"
    local latest=$(curl -sL $api_url | grep tag_name | awk -F \" '{print $4}') &> /dev/null
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
    if [ -z "$down_url" ] ; then
        # Using fallback URL.
        printf "ERROR: Unable to retrieve latest download URL from GitHub API.\n"
        printf "\nUsing default download URL.\n"
        down_url="https://github.com/srlabs/blue-merle/releases/download/v1.0/blue-merle_1.0.0-1_mips_24kc.ipk"
    else
    printf "Latest $repo version: $latest\n\nLatest GH download URL: \n$down_url\n\n"
    fi
}

# Detect the OS of the host, install dependencies.
detect_os() {
    local target=$(uname -o)
    printf "Host OS: $target\n\n"
    # Android dependencies.
    if [ "$target" = "Android" ] ; then
        printf "Installing: openssh\n\n"
        if ! command -v pkg &> /dev/null; then
            printf "\nERROR: This script must be run in Termux to run on Android.\n" ; exit 1
        fi
        pkg update ; pkg install openssh ; echo
    fi
}

# Commands sent over SSH stdin as a heredoc.
ssh_install() {
#==================== Start SSH connection ====================
ssh root@$ip_addr -oHostKeyAlgorithms=+ssh-rsa << ENDSSH

# Check to see if blue-merle is already installed.
echo ; if opkg list | grep blue-merle ; then
    printf "\nPackage is already installed!\n\nExiting...\n\n" ; exit 1
else
    printf "\nStarting install.\n\nDevice will reboot upon completion...\n\n"
    sleep 1
fi

# Download and install.
printf "Downloading blue-merle.\n"
if curl -L $down_url -o /tmp/blue-merle.ipk ; then
    opkg update ; opkg install /tmp/blue-merle.ipk
    printf "Device will now reboot.\nAfter reboot: "
    printf "Flip side-switch into the up position. (towards recessed dot)\n
    printf "Follow on-device MCU prompts.\n" ; reboot
else
    printf "\nERROR: Device is NOT connected to the internet.\n"
    printf "Please ensure internet connectivity and try again.\n\n" ; exit 1
fi
ENDSSH
#==================== End SSH connection ====================
}

#==================== Start execution ====================
main $1