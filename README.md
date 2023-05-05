# Mudi Blue-Merle Installer  <img src="https://user-images.githubusercontent.com/95660759/234453418-60f008a9-632b-4d48-bc9d-218ce659d304.png" width="50" height="50">
## Description:
This Bash script installs *[blue-merle](https://github.com/srlabs/blue-merle)* onto a **GL-E750 / Mudi** 4G mobile wi-fi router for increased anonyminity. The script prompts the user for an IP address then uses SSH to connect and perform the installation.

## Installation:
1.  Make sure that you are running the latest firmware.
2.  Make sure device's side-switch is in the down position. (away from recessed dot)
3.  Open a terminal window on your local machine (laptop).
4.  Copy the following command and paste it into the terminal window:
```
curl -O https://raw.githubusercontent.com/oldstreetloft/install-blue-merle/main/setup.sh ; sh setup.sh
```
5.  Press Enter to run the command.
6.  Follow the prompts to complete the installation.
7.  After reboot: Flip side-switch into the up position. (towards recessed dot)
Follow on-device MCU prompts.

## Example:
Script can run with or without command line arguments:
```
./setup.sh <ip_address>

Warning: Please ensure that you are running the latest firmware!
Device's side-switch should be in the down position. (away from recessed dot)
...
Enter password: <password>
...
```
```
./setup.sh

Warning: Please ensure that you are running the latest firmware!
Device's side-switch should be in the down position. (away from recessed dot)

Enter IP address: <ip_address>
...
Enter password: <password>
...
```

## About blue-merle:
The *blue-merle* software package enhances anonymity and reduces forensic traceability of the **GL-E750 / Mudi 4G mobile wi-fi router ("Mudi router")**. The portable device is explicitly marketed to privacy-interested retail users.

*blue-merle* addresses the traceability drawbacks of the Mudi router by adding the following features to the Mudi router:

1.  Mobile Equipment Identity (IMEI) changer

2.  Media Access Control (MAC) address log wiper

3.  Basic Service Set Identifier (BSSID) randomization

## License:
This script is licensed under the GPLv3 License. See the LICENSE file for more information.
