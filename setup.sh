#!/bin/bash

#======================================== Main function ========================================
# Main function executed from EOF.
main() {
    auth="srlabs"
    repo="blue-merle"
    alt_url="https://github.com/srlabs/blue-merle/releases/download/v3.0/blue-merle_3.0.5-0_mips_24kc.ipk"
    ssh_arg="-oStrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-rsa"

    parse_arg "$@"                      # Get data from user.
    test_conn                           # Exit if no connection.
    parse_github                        # Query GH for download URL.
    detect_os                           # Install dependencies.
    ssh_install                         # Install script.
}

#======================================== Define functions ========================================
# If no/invalid argument, prompt user.
parse_arg() {
    is_valid_ip "$1" && ip_addr="$1" || ip_addr=""
    while ! is_valid_ip "$ip_addr" ; do
        read -p "Enter IP address: " ip_addr ; done
}

# Validate IP address
is_valid_ip() {
    valid_ip="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
    echo "$1" | grep -Eq "$valid_ip" && return 0 || return 1
}

# Check if device and GH respond.
test_conn() {
    ! ping -c 1 "$ip_addr" 1> /dev/null && printf "\nERROR: No route to device!\n\n" && exit 1
    ! ping -c 1 github.com 1> /dev/null && printf "\nERROR: No internet connection.\n\n" && exit 1
}

# Query GH API for latest version and URL.
parse_github() {
    api_url="https://api.github.com/repos/$auth/$repo/releases/latest"
    latest=$(curl -sL $api_url | grep tag_name | awk -F \" '{print $4}')
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
    [ -z "$latest" ] && down_url=$alt_url && printf "\nUsing fallback URL.\n\n"
}

# Install dependencies for host OS.
detect_os() {
    host=$(uname -o)
    case "$host" in
        "Android")
            ! command -v pkg 1> /dev/null && printf "\nERROR: Termux required.\n\n" && exit 1
            ! command -v ssh 1> /dev/null && pkg update && pkg install openssh ;; esac
}

# Commands sent over SSH stdin via heredoc.
ssh_install() {
#======================================== Start SSH connection ========================================
ssh root@$ip_addr $ssh_arg 2> /dev/null <<- ENDSSH
printf "\nWarning: Please ensure that you are running the latest firmware!\n"
printf "Set device side-switch into the down position. (away from recessed dot)\n\n"

# Check to see if blue-merle is already installed.
opkg list | grep blue-merle 1> /dev/null && printf "Already installed!\n\n" && exit 1

printf "Downloading blue-merle.\n\n"
! curl -sL $down_url -o /tmp/blue-merle.ipk && printf "ERROR: Download failed.\n\n" && exit 1

printf "Updating package list.\n\n" ; opkg update 1> /dev/null

printf "Installing blue-merle.\n\nDevice will reboot.\n\n"
! yes | opkg install /tmp/blue-merle.ipk 1> /dev/null && printf "ERROR: Install failed.\n\n" && exit 1

printf "SUCCESS: INSTALL COMPLETED.\n\n"
printf "After reboot: Flip side-switch up. (towards recessed dot)\n\n"
printf "Follow on-device display prompts.\n\n"
ENDSSH
#======================================== End SSH connection ========================================
}

#======================================== Start execution ========================================
main "$@"
