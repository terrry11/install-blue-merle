#!/bin/bash

# Pre-install messages.
pre_install() {
    printf "\nWarning: Please ensure that you are running the latest firmware!\n\n"
    printf "Device's side-switch should be in the down position (away from recessed dot).\n\n"
}

# Query IP from user and GH API for latest download URL.
init_vars() {
    read -p "Enter IP address: " ip_address
    local api_url='https://api.github.com/repos/srlabs/blue-merle/releases/latest'
    down_url=$(curl -sL $api_url | grep browser_download | awk -F \" '{print $4}')
}

# Test.
test() {
    printf '\nUser provided IP: '
    echo $ip_address
    printf '\nGH Download URL: '
    echo $down_url
}

# Commands sent over SSH stdin as a heredoc.
remote_install() {
    ssh root@$ip_address -oHostKeyAlgorithms=+ssh-rsa << ENDSSH

    # Connection check.
    if ping -c 1 1.1.1.1 &> /dev/null
        then
            echo "Device is connected to the internet."
        else
            echo "Device is not connected to the internet."
            exit 0
    fi

    # Check to see if blue-merle is already installed.
    if opkg list | grep blue-merle &> /dev/null
        then
            printf "\n\nAlready installed!\n"
            exit 0
        else
            printf "\n\nStarting installation.\n"
    fi

    # Download and install.
    echo "Downloading blue-merle."
    curl -L $down_url -o /tmp/blue-merle.ipk
    opkg update
    opkg install /tmp/blue-merle.ipk

    # Error Check to see if blue-merle is installed.
    if opkg list | grep blue-merle &> /dev/null
        then
            printf "\n\nInstall complete, device will now reboot!\n"
            printf '\nAfter device boots:\nFlip side-switch to the up position (towards recessed dot) and follow on-device MCU prompts.\n\n'
            sleep 1
            reboot
        else
            printf "\n\nInstall Failed!\n"
            exit 0
    fi
ENDSSH
}

# Main.
pre_install
init_vars
#test
remote_install