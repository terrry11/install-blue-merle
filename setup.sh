#!/bin/bash

# Warn user
printf "\nWarning: Please ensure that you are running the latest firmware!\n\n"
printf "Device's side-switch should be in the down position (away from recessed dot).\n\n"

# Initialize variables
latest='https://github.com/srlabs/blue-merle/releases/download/v1.0/blue-merle_1.0.0-1_mips_24kc.ipk'
read -p "Enter IP address: " ip_address

# Begin SSH Connection
ssh root@$ip_address << 'ENDSSH'
cd /tmp
wget $latest -O blue-merle.ipk
opkg update
opkg install blue-merle.ipk
reboot
ENDSSH

# Post-install user considerations
printf '\n\nInstall complete, device will now reboot!\n'
printf 'After device boots:\nFlip side-switch to the up position (towards recessed dot) and follow on-device MCU prompts.\n\n'