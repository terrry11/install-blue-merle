#!/bin/bash

#==================== Main function ====================
main() {
    parse_args $1           # Get data from user.
    test_conn               # Exit if no connection.
    parse_github            # Query GH for download URL.
    detect_os               # Install dependencies.
    ssh_install             # Install script.
}

#==================== Define functions ====================
# Define command-line arguments, prompt user for ip, validate inputs.
parse_args() {
    # IP address
    if [[ $1 ]] ; then ip_addr=$1 ; fi
    get_ip
}

# Read and validate IP Address.
get_ip() {
    local valid_ip="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
    while true; do
        if [[ ! $ip_addr =~ $valid_ip ]] ; then
            printf "\nPlease enter a valid IP address.\n"
            read -p "Enter IP address: " ip_addr
        else
            break
        fi
    done
}

# Check to see if device and Github are responding.
test_conn() {
    # Check for response with ping.
    if ! ping -c 1 $ip_addr &> /dev/null ; then
        printf "\nERROR: No route to device!\nAre you behind a VPN or connected to the wrong network?\n"
        printf "Please ensure connectivity to device and try again.\n\n" ; exit 1
    fi
    # Check for internet connectivity with ping.
    if ! ping -c 1 github.com &> /dev/null ; then
        printf "ERROR: You are NOT connected to the internet.\n"
        printf "Please ensure internet connectivity and try again.\n\n" ; exit 1
    fi
}

# Query GH API for latest version number and download URL.
parse_github() {
    local auth='srlabs'
    local repo='blue-merle'
    local api_url="https://api.github.com/repos/$auth/$repo/releases/latest"
    local latest=$(curl -sL $api_url | grep tag_name | awk -F \" '{print $4}') &> /dev/null
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
    if [ -z "$latest" ] ; then
        # Using fallback URL.
        printf "ERROR: Unable to retrieve latest download URL from GitHub API.\n\n"
        printf "Using default download URL.\n\n"
        down_url="https://github.com/srlabs/blue-merle/releases/download/v1.0/blue-merle_1.0.0-1_mips_24kc.ipk"
    fi
}

# Detect the OS of the host, install dependencies.
detect_os() {
    local host=$(uname -o)
    # Android dependencies.
    if [ "$host" = "Android" ] ; then
        if ! command -v pkg &> /dev/null ; then
            printf "\nERROR: This script must be run in Termux.\n\n" ; exit 1 ; fi
        if ! command -v ssh &> /dev/null ; then
            pkg update &> /dev/null
            pkg install openssh &> /dev/null
        fi
    fi
}

# Commands sent over SSH stdin as a heredoc.
ssh_install() {
#==================== Start SSH connection ====================
ssh root@$ip_addr -oStrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-rsa 2> /dev/null <<- ENDSSH
printf "\nWarning: Please ensure that you are running the latest firmware!\n"
printf "Device's side-switch should be in the down position. (away from recessed dot)\n\n"

# Check to see if blue-merle is already installed.
if opkg list | grep blue-merle 1> /dev/null ; then
    printf "blue-merle already installed!\n\nExiting...\n\n" ; exit 1
fi

printf "Downloading blue-merle.\n\n"
if ! curl -L $down_url -o /tmp/blue-merle.ipk
    printf "ERROR: Download failed.\n"
    printf "Please ensure internet connectivity and try again.\n\n" ; exit 1
fi

printf "Updating package list.\n\n"
opkg update &> /dev/null

printf "Installing blue-merle.\n\nDevice will reboot.\n\n"
if ! yes | opkg install /tmp/blue-merle.ipk 1> /dev/null ; then
    printf "ERROR: blue-merle not installed.\n\n" ; exit 1
fi

printf "SUCCESS: INSTALL COMPLETED.\n\n"
printf "After reboot: Flip side-switch up. (towards recessed dot)\n\n"
printf "Follow on-device display prompts.\n\n"
ENDSSH
#==================== End SSH connection ====================
}

#==================== Start execution ====================
main $1