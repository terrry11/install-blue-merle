#!/bin/bash

# Pre-install messages.
pre_install() {
cat << MESSAGE

Warning: Please ensure that you are running the latest firmware!

Device's side-switch should be in the down position (away from recessed dot).

MESSAGE
}

# Query IP from user and GH API for latest download URL.
init_vars() {
    read -p "Enter IP address: " ip_address
    local api_url='https://api.github.com/repos/srlabs/blue-merle/releases/latest'
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
}

# Check to see if both device and GH are reachable.
test_conn() {
    if ping -c 1 $ip_address &> /dev/null
        then
            printf "\nProvided IP Address: "
            echo $ip_address
            printf "\nDevice is reachable.\n"
        else
            printf "\nERROR:\n"
            echo "No route to device!"
            printf "Please ensure connectivity to device and try again.\n\n"
            exit 0
    fi
    if [[ $down_url ]]
        then
            printf "\nYou are connected to the internet.\n"
            printf '\nLatest GH Download URL: \n'
            echo $down_url
            echo
        else
            printf "\nERROR:\n"
            echo "You are NOT connected to the internet."
            printf "Please ensure internet connectivity and try again.\n\n"
            exit 0
    fi
}

# Commands sent over SSH stdin as a heredoc.
ssh_install() {
    ssh root@$ip_address -oHostKeyAlgorithms=+ssh-rsa << ENDSSH

    # Check for connection to the internet.
    if ping -c 1 1.1.1.1 &> /dev/null
        then
            printf "\nDevice is connected to the internet.\n"
        else
            printf "\nERROR:\n"
            printf "Device is NOT connected to the internet.\n"
            printf "Please ensure connectivity and try again.\n\n"
            exit 0
    fi

    # Check to see if blue-merle is already installed.
    if opkg list | grep blue-merle &> /dev/null
        then
            printf "\nPackage is already installed!\n\nNothing to do.\n\nExiting...\n\n"
            exit 0
        else
            printf "\nStarting installation.\n\nDevice will reboot upon completion...\n"
            sleep 1
    fi

    # Download and install.
    echo "Downloading blue-merle."
    curl -L $down_url -o /tmp/blue-merle.ipk
    opkg update
    opkg install /tmp/blue-merle.ipk
ENDSSH
}

# Post-install messages.
post_install() {
cat << MESSAGE
Flip side-switch into the up position. (towards recessed dot)

Follow on-device MCU prompts.

MESSAGE
}

# Main.
pre_install
init_vars
test_conn
ssh_install
post_install