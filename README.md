# Timezone and Flux from IP

This repository contains a shell script that updates the system timezone and the color temperature of the display based on the geolocation of the current IP address. The script is designed to be used with NetworkManager's dispatcher to be executed whenever a network connection goes up.

NOTE: ONLY WORKS ON LINUX MACHINES WITH NETWORKMANAGER INSTALLED
ALSO, YOU NEED TO BE USING X (PROBABLY X11)... SORRY

To see  if you have network manager, run the following script: 

```
nmcli -v
```
If NetworkManager is installed, this command will return the version of NetworkManager that is currently installed on your system. If it is not installed, you will see an error message saying "command not found" or similar.

## Script

The main script is located at `/etc/NetworkManager/dispatcher.d/update_timezone` and needs to be made executable (`chmod +x`) to work correctly. 

The script performs the following actions:

1. Logs the start of the script, the network interface, and its status.
2. If the network interface status is "up", the script updates the system timezone using `tzupdate`.
3. Retrieves the latitude and longitude of the current public IP using the ipinfo.io API.
4. Saves the latitude and longitude to a file located at `$HOME/latlon.txt`. Feel free to alter the script to whatever location you need.
5. Kills any running instances of `xflux`, a program that adjusts a display's color temperature according to location and time of day.
6. Starts a new instance of `xflux` with the new latitude and longitude.
7. Logs the end of the script execution.

## Installation

To install, clone this repository and copy the `update_timezone` script to `/etc/NetworkManager/dispatcher.d/`. Make sure to set the script as executable with `chmod +x`.

```
git clone https://github.com/morganrivers/timezone_and_flux_from_ip.git
sudo cp timezone_and_flux_from_ip/etc/NetworkManager/dispatcher.d/update_timezone /etc/NetworkManager/dispatcher.d/
sudo chmod +x /etc/NetworkManager/dispatcher.d/update_timezone
```

You also need to install xflux and tzupdate.

On systems with pip3, tzupdate installation would be:

```
pip3 install --user tzupdate
```
As for xflux, check out:

https://justgetflux.com/linux.html

(Sorry, xflux is apparently closed source. But also redshift is not working well for some people with debian/archlinux. You could modify the script to work with redshift reasonably easily as well.)

## Dependencies

The script depends on the following tools:
- `tzupdate`: for updating the system timezone.
- `curl`: for making API calls.
- `xflux`: for adjusting the display's color temperature.

Ensure these tools are installed on your system before running the script.
