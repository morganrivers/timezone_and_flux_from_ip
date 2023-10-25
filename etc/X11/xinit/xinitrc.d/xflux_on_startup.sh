#!/bin/sh
username=$(who | awk '{print $1; exit}')
OUTPUT_FILE="/home/$username/latlon.txt"
LOG_FILE="/home/$username/xflux_log.log"

log_message() {
    echo "$1" >> "$LOG_FILE"
}

kill_xflux() {
    killall -q xflux
    while true;
            do allxflux=$(pidof xflux);
            wtsp=" ";
            tmpxflux=${allxflux%%"$wtsp"*};
            allxflux=${allxflux#*"$wtsp"};
            case "$allxflux" in
                    *" "*)
                            kill -9 "$tmpxflux"  > /dev/null 2>&1;
                            continue;
                    ;;
                    *)
                            kill -9 "$tmpxflux"  > /dev/null 2>&1;
                            break;
                    ;;
            esac;
    done;
    log_message "xflux killed"
}


check_lat_and_lon_are_valid() {
    case $1 in
        -*[0-9]*.*[0-9]*) ;;  # matches negative floating number
        *[0-9]*.*[0-9]*)  ;;  # matches positive floating number
        *) return 1 ;;
    esac

    case $2 in
        -*[0-9]*.*[0-9]*) ;;  # matches negative floating number
        *[0-9]*.*[0-9]*)  ;;  # matches positive floating number
        *) return 1 ;;
    esac

    return 0
}

# Make log if doesn't exist
[ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"

log_message " "
log_message "---------------------------------------------------"
log_message "Startup Script run on: $(date +'%Y-%m-%d %H:%M:%S')"

# Test if output file exists
if [ -f "$OUTPUT_FILE" ]; then
    LAT=$(cut -d ',' -f 1 "$OUTPUT_FILE")
    LON=$(cut -d ',' -f 2 "$OUTPUT_FILE")
    
    if ! check_lat_and_lon_are_valid $LAT $LON; then
        log_message "The lat and lon read from the OUTPUT_FILE were invalid."
        log_message "---------------------------------------------------"
        log_message " "
        return
    fi
    
    XAUTHORITY="/home/$username/.Xauthority"
    DISPLAY=":0"
    export XAUTHORITY DISPLAY

    kill_xflux

    xflux -l $LAT -g $LON -k 2000 >> "$LOG_FILE" 2>&1 &
    log_message "xflux started with LAT: $LAT and LON: $LON."
else
    log_message "Warning: Output file $OUTPUT_FILE does not exist. xflux not started."
fi

echo "---------------------------------------------------" >> "$LOG_FILE"
my echo " " >> "$LOG_FILE"
