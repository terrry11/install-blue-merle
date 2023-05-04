#!/bin/bash

#==================== Main function ====================
main() {
    pre_install             # Pre-install message.
    parse_args $1           # Get data from user.
    test_conn               # Exit if no connection.
    parse_github            # Query GH for latest download URL.
    detect_os               # Install dependencies.
    ssh_install             # Install script.
}

#==================== Define functions ====================
# Print pre-install message.
pre_install() {
printf "\nWarning: Please ensure that you are running the latest firmware!\n"
printf "Device's side-switch should be in the down position. (away from recessed dot)\n\n"
}

# Define command-line arguments or prompt user for ip
parse_args() {
    if [[ $1 ]] ; then
        ip_addr=$1
    else
        read -p "Enter IP address: " ip_addr
    fi
    # Validate IP address
    if [[ ! $ip_addr =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf "\nERROR: Invalid IP address format. Please enter a valid IP address.\n"
    parse_args
    fi
}

# Check to see if device and 1.1.1.1 are responding.
test_conn() {
    if ping -c 1 $ip_addr &> /dev/null ; then
        printf "\nProvided IP Address: $ip_addr\n\nDevice is responding.\n\n"
    else
        printf "\nERROR: No route to device!\nAre you behind a VPN or connected to the wrong network?\n"
        printf "Please ensure connectivity to device and try again.\n\n" ; exit 1
    fi
    if ping -c 1 1.1.1.1 &> /dev/null ; then
        printf "You are connected to the internet.\n\n"
    else
        printf "\nERROR: You are NOT connected to the internet.\n\n"
        printf "Please ensure internet connectivity and try again.\n\n" ; exit 1
    fi
}

# Query GH API for latest download URL.
parse_github() {
    local auth_repo='srlabs/blue-merle'
    local api_url="https://api.github.com/repos/$auth_repo/releases/latest"
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
    if [ -z "$down_url" ] ; then
        printf "ERROR: Unable to retrieve latest download URL from GitHub API.\n"
        printf "\nUsing default download URL.\n"
        down_url="https://github.com/srlabs/blue-merle/releases/download/v1.0/blue-merle_1.0.0-1_mips_24kc.ipk"
    else
        printf "Latest GH download URL: \n$down_url\n\n"
    fi
}

# Detect the OS of the host, install dependencies.
detect_os() {
    local target=$(uname -o)
    if [ "$target" = "Android" ] ; then
        printf "Host OS: $target\n\nInstalling: openssh\n\n" ; 
        pkg update ; pkg install openssh ; echo
    else
        printf "Host OS: $target\n\n"
    fi
}

#==================== Start SSH connection ====================
# Commands sent over SSH stdin as a heredoc.
ssh_install() {
ssh root@$ip_addr -oHostKeyAlgorithms=+ssh-rsa << ENDSSH

# Check to see if blue-merle is already installed.
echo ; if opkg list | grep blue-merle ; then
    printf "\nPackage is already installed!\n\nExiting...\n" ; exit 1
else
    printf "\nStarting install.\n\nDevice will reboot upon completion...\n\n" ; sleep 1
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
}

#==================== Start execution ====================
main $1