# Timezone and Flux from IP

This Linux-based shell script automatically updates your system timezone and adjusts your display's color temperature based on your current IP geolocation. This script is designed to work with NetworkManager's dispatcher, and triggers whenever your network connection goes up.

## Prerequisites

1. **Linux with NetworkManager**: To check if NetworkManager is installed, use the command `nmcli -v`. This will return the installed version, or an error if it's not installed.

2. **X server (e.g. X11)**: To check if you are using X, run `ps -e | grep tty`. As long as "Xorg" appears in the process list, you're using X.

3. **curl**: To check for curl, run `curl --version`. If it doesn't show a version, run `sudo apt install curl` to install curl.

4. **pip**: Install with `sudo apt-get install pip`

## System Compatibility

This script has been tested on:

- `Linux 5.10.0-14-amd64 #1 SMP Debian 5.10.113-1 (2022-04-29) x86_64 GNU/Linux`
- `Linux casta 5.10.133 #1 SMP PREEMPT Sat Nov 19 21:06:46 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux`

Check your system using `uname -a`.

## Functionality

The update_timezone script, located at `/etc/NetworkManager/dispatcher.d/update_timezone`, executes the following steps:

1. Logs the script start, network interface, and status.
2. If the network interface status is "up":
    - Updates the system timezone with `tzupdate`.
    - Retrieves and saves current latitude and longitude using the ipinfo.io API.
    - Kills any running `xflux` instances.
    - Starts a new `xflux` instance with the new latitude and longitude.
3. Logs the script execution end.

If you're interested in Redshift: Although xflux is closed source, redshift is not working well for some people with debian/ubuntu/archlinux. You could modify the script to work with redshift reasonably easily as well. for example, replacing the line calling xflux with: `redshift -l $LAT:$LON`.



## Installation

1. Clone the repository and enter it (`cd timezone_and_flux_from_ip`):

   ```
   git clone https://github.com/morganrivers/timezone_and_flux_from_ip.git
   cd timezone_and_flux_from_ip
   ```

2. Install `tzupdate` and `xflux`:

   - For `tzupdate`, try installing like this:
     ```
     sudo pip install -U tzupdate`
     ```
     Ensure this worked by running `sudo tzupdate`. You should get a response like: `Set system timezone to [your continent]/[your city].`

     On Ubuntu, sometimes `sudo tzupdate` command doesn't work, but `sudo ~/.local/bin/tzupdate` does. In this case it is necessary to edit the `etc/NetworkManager/dispatcher.d/update_timezone` file and replace the update_timezone() command:

     From this:
     ```
     update_timezone() { 
         log_message "tzupdate things"
         sudo tzupdate >> $LOG_FILE
         log_message "tzupdate command executed"
     }
     ```

     To this:
     ```
     update_timezone() { 
         log_message "tzupdate things"
         sudo /home/$username/.local/bin/tzupdate >> $LOG_FILE
         log_message "tzupdate command executed"
     }
     ```
     
   - For `xflux`, download from [here](https://justgetflux.com/linux.html) and run:

     ```
     tar zxvf xflux64.tgz
     ```

     Now if you run `./xflux` You should see:
     ```
     --------
     Welcome to xflux (f.lux for X)
     This will only work if you're running X on console.
    
     Usage: ./xflux [-z zipcode | -l latitude] [-g longitude] [-k colortemp (default 3400)] [-r 1 (use randr)] [-nofork]
     protip: Say where you are (use -z or -l).
     ```

     Finally to install xflux, run the command:     
     ```
     sudo cp xflux /usr/local/bin/
     ```
     
3. If the steps above worked, copy the script to `/etc/NetworkManager/dispatcher.d/`, ensuring it's executable.
   ```
   sudo cp etc/NetworkManager/dispatcher.d/update_timezone /etc/NetworkManager/dispatcher.d/
   sudo chmod +x /etc/NetworkManager/dispatcher.d/update_timezone
   ```    
5.  If you'd also like to have xflux on startup, you can place the `xflux_on_startup.sh` script in `/etc/X11/xinit/xinitrc.d`.

    ```
    sudo mkdir -p /etc/X11/xinit/xinitrc.d/
    sudo cp etc/X11/xinit/xinitrc.d/xflux_on_startup.sh /etc/X11/xinit/xinitrc.d/
    sudo chmod +x /etc/X11/xinit/xinitrc.d/xflux_on_startup.sh
    ```

    You will also need to modify your .xinitrc if it doesn't already have the following lines. Add these lines at the bottom if they're not already in the `~/.xinitrc` script. Watch out not to put it after an exec command, such as `exec i3` or similiar!

    ```
    # Start the scripts located in /etc/X11/xinit/xinitrc.d after the x server launches
    if [ -d /etc/X11/xinit/xinitrc.d ] ; then
      for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
        done
      unset f
    fi
    ```



## Usage

The script triggers automatically upon establishing a network connection using NetworkManager, updating the timezone and adjusting screen temperature only if the timezone changes.

Connect to a network, e.g., via Wi-Fi:

```
nmcli device wifi connect <your_network> password <your_password>
```

The startup script will automatically kill any  xflux and start on boot as well. This will only work if you've connected to the internet, as xflux needs latitude and longitude information to set the correct color temperature.

You'd need to use a text editor to edit `/etc/X11/xinit/xinitrc.d/xflux_on_startup.sh` and `/etc/NetworkManager/dispatcher.d/update_timezone`.

To change the redness, you would edit the line in both files:
```
xflux -l $LAT -g $LON -k 2000
```
You can change the 2000 after the "-k" to be some other temperature. 2000 is the lowest xflux allows, and a little less red and more blue is 2500, 3000 or 4000.

## Checking if it worked
Your xflux log is located at `~/xflux_log.log` and has sudo permissions for read/write. Your location file stores your location determined by `tzupdate` at `~/latlon.txt`. You can change these locations in the `update_timezone` and `xflux_on_startup.sh` scripts. This stores both error logs and normal operations, including the history of lat/lon locations.

To check if the script is working, you can run `sudo cat ~/xflux_log.log`. You should see something like the following once you have connected to `NetworkManager` using `nmcli` command or similar:

```

---------------------------------------------------
Script update_timezone started at Mon Sep  2 13:06:32 CEST 2024
Arguments passed to script: /etc/NetworkManager/dispatcher.d/update_timezone wlp0s20f3 up
tzupdate things
Set system timezone to Europe/Berlin.
tzupdate command executed
check_output_file_values: false
check_timezone_change: false
Current location info: LAT=52.6763, LON=13.2777, TZ=Europe/Berlin
cat: /home/dmrivers/latlon.txt: No such file or directory
XFLUX_TIMEZONE: , CURRENT_TZ: Europe/Berlin
location_exists_but_doesnt_match_timezone: mismatch in timezones!
Location exists but doesn't match timezone: true
Latitude: 52.6763, Longitude: 13.2777, Current timezone:Europe/Berlin
xflux killed
New xflux started at latitude=52.6763, longitude=13.2777
update_timezone finished at Mon Sep  2 13:06:34 CEST 2024
---------------------------------------------------

^[[2J^[[0;0f
--------
Welcome to xflux (f.lux for X)
This will only work if you're running X on console.

Found 1 screen.
Your location (lat, long) is 52.7, 13.3

Your night-time color temperature is 2000
Going to background: 'kill 11725' to turn off.
```
## Dependencies

- `tzupdate`: Updates the system timezone.
- `curl`: Makes API calls.
- `xflux`: Adjusts display's color temperature.
- `nmcli`: NetworkManager command-line tool.
- `pip`: Python package manager.
