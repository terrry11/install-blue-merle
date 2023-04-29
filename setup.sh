#!/bin/bash

# Warn user
printf "\nWarning: Please ensure that you are running the latest firmware!\n\n"
printf "Device's side-switch should be in the down position (away from recessed dot).\n\n"

# Initialize variables
get_latest() {
    local api_url='https://api.github.com/repos/srlabs/blue-merle/releases/latest'
    latest=$(curl -sL $api_url | grep browser_download | awk -F '"' '{print $4}')
}
read -p "Enter IP address: " ip_address

# Begin SSH Connection
ssh root@$ip_address << 'ENDSSH'
cd /tmp
wget $latest -O blue-merle.ipk
opkg update
opkg install blue-merle.ipk
reboot
ENDSSH

# Post-install considerations
printf '\n\nInstall complete, device will now reboot!\n'
printf 'After device boots:\nFlip side-switch to the up position (towards recessed dot) and follow on-device MCU prompts.\n\n'