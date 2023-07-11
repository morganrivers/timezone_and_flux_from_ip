# Timezone and Flux from IP

This Linux-based shell script automatically updates your system timezone and adjusts your display's color temperature based on your current IP geolocation. This script is designed to work with NetworkManager's dispatcher, and triggers whenever your network connection goes up.

## Prerequisites

1. **Linux with NetworkManager**: To check if NetworkManager is installed, use the command `nmcli -v`. This will return the installed version, or an error if it's not installed.

2. **X server (e.g. X11)**: To check if you are using X, run `ps -e | grep tty`. As long as "Xorg" appears in the process list, you're using X.

## System Compatibility

This script has been tested on:

- `Linux 5.10.0-14-amd64 #1 SMP Debian 5.10.113-1 (2022-04-29) x86_64 GNU/Linux`
- `Linux casta 5.10.133 #1 SMP PREEMPT Sat Nov 19 21:06:46 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux`

Check your system using `uname -a`.

## Functionality

The main script, located at `/etc/NetworkManager/dispatcher.d/update_timezone`, executes the following steps:

1. Logs the script start, network interface, and status.
2. If the network interface status is "up":
    - Updates the system timezone with `tzupdate`.
    - Retrieves and saves current latitude and longitude using the ipinfo.io API.
    - Kills any running `xflux` instances.
    - Starts a new `xflux` instance with the new latitude and longitude.
3. Logs the script execution end.

## Installation

1. Clone the repository and copy the script to `/etc/NetworkManager/dispatcher.d/`, ensuring it's executable:

   ```
   git clone https://github.com/morganrivers/timezone_and_flux_from_ip.git
   sudo cp timezone_and_flux_from_ip/etc/NetworkManager/dispatcher.d/update_timezone /etc/NetworkManager/dispatcher.d/
   sudo chmod +x /etc/NetworkManager/dispatcher.d/update_timezone
   ```

2. Install `tzupdate` and `xflux`:

   - For `tzupdate`: `sudo pip install -U tzupdate`
   - For `xflux`, download from [here](https://justgetflux.com/linux.html) and run:

     ```
     tar zxvf xflux64.tgz
     ./xflux
     sudo cp xflux /usr/local/bin/
     ```

## Usage

The script triggers automatically upon establishing a network connection using NetworkManager, updating the timezone and adjusting screen temperature only if the timezone changes.

Connect to a network, e.g., via Wi-Fi:

```
nmcli device wifi connect <your_network> password <your_password>
```

## Dependencies

- `tzupdate`: Updates the system timezone.
- `curl`: Makes API calls.
- `xflux`: Adjusts display's color temperature.
- `nmcli`: NetworkManager command-line tool.
