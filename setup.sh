#!/bin/bash

#==================== PRE_INSTALL ====================
# Pre-install messages.
pre_install() {
cat << MESSAGE

Warning: Please ensure that you are running the latest firmware!
Device's side-switch should be in the down position. (away from recessed dot)

MESSAGE
}
#==================== PARSE_ARGS ====================
# Define command-line arguments or prompt user for ip
parse_args() {
    if [[ $1 ]] ; then
        ip_addr=$1
    else
        read -p "Enter IP address: " ip_addr
    fi
}
#==================== PARSE_GITHUB ====================
# Query GH API for latest download URL.
parse_github() {
    local auth_repo='srlabs/blue-merle'
    local api_url="https://api.github.com/repos/$auth_repo/releases/latest"
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
}
#==================== TEST_CONN ====================
# Check to see if device and GH are responding.
test_conn() {
    if ping -c 1 $ip_addr &> /dev/null ; then
        printf "\nProvided IP Address: $ip_addr\n\nDevice is responding.\n\n"
    else
        printf "\nERROR: No route to device!\nAre you behind a VPN or connected to the wrong network?\n"
        printf "Please ensure connectivity to device and try again.\n\n" ; exit 0
    fi
    if [[ $down_url ]] ; then
        printf "You are connected to the internet.\n\n"
        printf "Latest GH download URL: \n$down_url\n\n"
    else
        printf "\nERROR: You are NOT connected to the internet.\n\n"
        printf "Please ensure internet connectivity and try again.\n\n" ; exit 0
    fi
}
#==================== DETECT_OS ====================
# Detect the OS of the host.
detect_os() {
    target=$(uname -o)
    if [ "$target" = "Android" ] ; then
        printf "Host OS: $target\n\nInstalling: openssh\n\n" ; 
        pkg update ; pkg install openssh ; echo
    else
        printf "Host OS: $target\n\n"
    fi
}
#==================== SSH_INSTALL ====================
# Commands sent over SSH stdin as a heredoc.
ssh_install() {
ssh root@$ip_addr -oHostKeyAlgorithms=+ssh-rsa 2> /dev/null << ENDSSH

# Check to see if blue-merle is already installed.
echo ; if opkg list | grep blue-merle ; then
    printf "\nPackage is already installed!\n\nExiting...\n" ; exit 0
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
    printf "Please ensure internet connectivity and try again.\n\n" ; exit 0
fi
ENDSSH
}
#==================== MAIN ====================
pre_install
parse_args $1
parse_github
test_conn
detect_os
ssh_install