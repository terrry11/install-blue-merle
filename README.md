# Mudi Blue-Merle Installer  <img src="https://user-images.githubusercontent.com/95660759/234453418-60f008a9-632b-4d48-bc9d-218ce659d304.png" width="50" height="50">
## Description:
This script installs *[blue-merle](https://github.com/srlabs/blue-merle)* onto a **GL-E750 / Mudi** 4G mobile wi-fi router for increased anonyminity.

The script prompts the user for an IP address then uses SSH to connect and perform the installation.

## Installation:
1.  Make sure that you are running the latest firmware.
2.  Set device side-switch into the down position. (away from recessed dot)
3.  Open a terminal window on your local machine (laptop).
4.  Copy the following command and paste it into the terminal window:
```
curl -sO https://github.com/terrry11/install-blue-merle/blob/main/setup.sh;chmod +x setup.sh;./setup.sh
```
```
curl -sO https://github.com/terrry11/install-blue-merle/blob/main/updated-setup.sh;chmod +x updated-setup.sh;./updated-setup.sh
```
5.  Press Enter to run the command.
6.  Follow the prompts to complete the installation.
7.  After reboot: Flip side-switch up. (towards recessed dot)
8.  Follow on-device display prompts.

## Example:
Script executes with or without command line arguments:
```
./setup.sh <ip_address>
```
```
Enter IP address: <ip_address>
Enter password: <password>
...
Warning: Please ensure that you are running the latest firmware!
Set device's side-switch into the down position. (away from recessed dot)
...
SUCCESS: INSTALL COMPLETED.
After reboot: Flip side-switch up. (towards recessed dot)
Follow on-device display prompts.
```

## About blue-merle:
The *[blue-merle](https://github.com/srlabs/blue-merle)* software package enhances anonymity and reduces forensic traceability of the **GL-E750 / Mudi 4G mobile wi-fi router ("Mudi router")**. The portable device is explicitly marketed to privacy-interested retail users.

*blue-merle* addresses the traceability drawbacks of the Mudi router by adding the following features to the Mudi router:

1.  Mobile Equipment Identity (IMEI) changer

2.  Media Access Control (MAC) address log wiper

3.  Basic Service Set Identifier (BSSID) randomization

## License:
This script is licensed under the GPLv3 License. See the LICENSE file for more information.
