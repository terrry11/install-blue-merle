# install-blue-merle
## Description:
This Bash script installs Blue-Merle onto a GL-E750 router for increased anonyminity. The script prompts the user for an IP address then uses SSH to connect and perform the installation.

## Installation:
Download the setup.sh file, make it executable, run it, then provide device IP address:

```
curl -O https://raw.githubusercontent.com/oldstreetloft/install-blue-merle/main/setup.sh
chmod +x setup.sh
$ ./setup.sh
```
```
Warning: Please ensure that you are running the latest firmware!
Device's side-switch should be in the down position (away from recessed dot).
Enter the IP address: <ip_address>

...

After device boots:
Flip side-switch to the up position (towards recessed dot) and follow on-device MCU prompts.
```

## License:
This script is licensed under the GPLv3 License. See the LICENSE file for more information.