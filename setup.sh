#!/bin/bash

#======================================== Main function ========================================
# Main function is executed from the end of the script.
main() {
    # Parse GitHub
    auth="srlabs"
    repo="blue-merle"
    alt_url="https://github.com/$auth/$repo/releases/download/v1.0/blue-merle_1.0.0-1_mips_24kc.ipk"
    # SSH arguments
    ssh_arg="-oStrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-rsa"

    parse_arg "$@"                      # Get data from user.
    test_conn                           # Exit if no connection.
    parse_github                        # Query GH for download URL.
    detect_os                           # Install dependencies.
    ssh_install                         # Install script.
}

#======================================== Define functions ========================================
# Define command-line arguments, prompt user for ip, validate inputs.
parse_arg() {
    if [ -n "$1" ] ; then ip_addr=$1 ; fi
    valid_ip="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
    while ! echo "$ip_addr" | grep -Eq "$valid_ip" ; do
        read -p "Enter IP address: " ip_addr ; done
}

# Check to see if device and GitHub are responding.
test_conn() {
    if ! ping -c 1 "$ip_addr" 1> /dev/null ; then
        printf "\nERROR: No route to device!\nAre you behind a VPN or connected to the wrong network?\n"
        printf "Please ensure device connectivity and try again.\n\n" ; exit 1 ; fi
    if ! ping -c 1 github.com 1> /dev/null ; then
        printf "\nERROR: You are NOT connected to the internet.\n"
        printf "Please ensure internet connectivity and try again.\n\n" ; exit 1 ; fi
}

# Query GH API for latest version number and download URL.
parse_github() {
    api_url="https://api.github.com/repos/$auth/$repo/releases/latest"
    latest=$(curl -sL $api_url | grep tag_name | awk -F \" '{print $4}')
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
    if [ -z "$latest" ] ; then
        printf "\nERROR: Unable to retrieve latest download URL from GitHub API.\n\n"
        printf "Using alternate download URL.\n\n" ; down_url=$alt_url ; fi
}

# Detect the OS of the host, install dependencies.
detect_os() {
    host=$(uname -o)
    if [ "$host" = "Android" ] ; then
        if ! command -v pkg 1> /dev/null ; then
            printf "\nERROR: This script must be run in Termux.\n\n" ; exit 1 ; fi
        if ! command -v ssh 1> /dev/null ; then
            printf "\nUpdating package list.\n\n" ; pkg update 1> /dev/null
            printf "\nInstalling openssh.\n\n" ; pkg install openssh 1> /dev/null ; fi ;fi
}

# Commands sent over SSH stdin as a heredoc.
ssh_install() {
#======================================== Start SSH connection ========================================
ssh root@"$ip_addr" "$ssh_arg" 2> /dev/null <<- ENDSSH
printf "\nWarning: Please ensure that you are running the latest firmware!\n"
printf "Set device side-switch into the down position. (away from recessed dot)\n\n"

# Check to see if blue-merle is already installed.
if opkg list | grep blue-merle 1> /dev/null ; then
    printf "blue-merle already installed!\n\nExiting...\n\n" ; exit 1 ; fi

printf "Downloading blue-merle.\n\n"
if ! curl -L $down_url -o /tmp/blue-merle.ipk
    printf "ERROR: Download failed.\n"
    printf "Please ensure internet connectivity and try again.\n\n" ; exit 1 ; fi

printf "Updating package list.\n\n" ; opkg update 1> /dev/null

printf "Installing blue-merle.\n\nDevice will reboot.\n\n"
if ! yes | opkg install /tmp/blue-merle.ipk 1> /dev/null ; then
    printf "ERROR: blue-merle not installed.\n\n" ; exit 1 ; fi

printf "SUCCESS: INSTALL COMPLETED.\n\n"
printf "After reboot: Flip side-switch up. (towards recessed dot)\n\n"
printf "Follow on-device display prompts.\n\n"
ENDSSH
#======================================== End SSH connection ========================================
}

#======================================== Start execution ========================================
main "$@"