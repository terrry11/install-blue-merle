#!/bin/bash

# Pre-install messages.
pre_install() {
cat << MESSAGE

Warning:
Please ensure that you are running the latest firmware!
Device's side-switch should be in the down position. (away from recessed dot)

MESSAGE
}

# Define command-line arguments or prompt user for ip
parse_args() {
    if [[ $1 ]] ; then
        ip_addr=$1
    else
        read -p "Enter IP address: " ip_addr
    fi
}

# Query GH API for latest download URL.
parse_github() {
    local author='srlabs'
    local repo='blue-merle'
    local api_url="https://api.github.com/repos/$author/$repo/releases/latest"
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
}

# Check to see if both device and GH are reachable.
test_conn() {
    if ping -c 1 $ip_addr &> /dev/null ; then
        printf "\nProvided IP Address: $ip_addr\n\nDevice is reachable.\n\n"
    else
        printf "\nERROR:\nNo route to device!\n"
        printf "Please ensure connectivity to device and try again.\n\n" ; exit 0
    fi
    if [[ $down_url ]] ; then
        printf "You are connected to the internet.\n\n"
        printf "Latest GH download URL: \n$down_url\n\n"
    else
        printf "\nERROR:\nYou are NOT connected to the internet.\n\n"
        printf "Please ensure internet connectivity and try again.\n\n" ; exit 0
    fi
}

#####################
# Begin SSH session #
#####################
# Commands sent over SSH stdin as a heredoc.
ssh_install() {
ssh root@$ip_addr -oHostKeyAlgorithms=+ssh-rsa << ENDSSH

# Check to see if blue-merle is already installed.
echo
if opkg list | grep blue-merle ; then
    printf "\nPackage is already installed!\n\nExiting...\n" ; exit 0
else
    printf "\nStarting install.\n\nDevice will reboot upon completion...\n\n" ; sleep 1
fi

# Download and install.
printf "Downloading blue-merle.\n"
if curl -L $down_url -o /tmp/blue-merle.ipk ; then
    opkg update ; opkg install /tmp/blue-merle.ipk ; reboot
else
    printf "\nERROR:\nDevice is NOT connected to the internet.\n"
    printf "Please ensure connectivity and try again.\n\n" ; exit 0
fi
ENDSSH
}
###################
# End SSH session #
###################

# Post-install messages.
post_install() {
cat << MESSAGE

After reboot:
Flip side-switch into the up position. (towards recessed dot)
Follow on-device MCU prompts.

MESSAGE
}

# Main.
pre_install
parse_args $1
parse_github
test_conn
ssh_install
post_install