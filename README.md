# Timezone and Flux from IP

This repository contains a shell script that updates the system timezone and the color temperature of the display based on the geolocation of the current IP address. The script is designed to be used with NetworkManager's dispatcher to be executed whenever a network connection goes up.

NOTE: ONLY WORKS ON LINUX MACHINES WITH NETWORKMANAGER INSTALLED

ALSO, YOU NEED TO BE USING X (PROBABLY X11)

To see  if you have network manager, run the following script: 

```
nmcli -v
```
If NetworkManager is installed, this command will return the version of NetworkManager that is currently installed on your system. If it is not installed, you will see an error message saying "command not found" or similar.

## Script

The main script is located at `/etc/NetworkManager/dispatcher.d/update_timezone`.
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
sudo pip install -U tzupdate
```

As for xflux, you can download from here:

https://justgetflux.com/linux.html

Once you dowload, you can just run:

```
 tar zxvf xflux64.tgz
```
check it works by running it

```
./xflux
```

You should get:
```
--------
Welcome to xflux (f.lux for X)
This will only work if you're running X on console.

Usage: ./xflux [-z zipcode | -l latitude] [-g longitude] [-k colortemp (default 3400)] [-r 1 (use randr)] [-nofork]
protip: Say where you are (use -z or -l).
```

Now, if that worked add xflux to your discoverable executables:

```
sudo cp xflux /usr/local/bin/
```

(Sorry, xflux is apparently closed source. But also redshift is not working well for some people with debian/archlinux. You could modify the script to work with redshift reasonably easily as well. for example, replacing the line calling xflux with: `redshift -l $LAT:$LON`)

## Dependencies

The script depends on the following tools:
- `tzupdate`: for updating the system timezone.
- `curl`: for making API calls.
- `xflux`: for adjusting the display's color temperature.
- `nmcli`: NetworkManager, needed to call script on network connection.


Ensure these tools are installed on your system before running the script.
