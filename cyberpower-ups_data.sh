#!/usr/bin/env bash

set -e

cpp_server=localhost

CACHE_FILE=/var/log/zabbix/cyberpower-ups-data.log
LOCK_FILE=/tmp/pihole-data.lock

run_ups_query() {
    cd "$(readlink -f "$(dirname "$0")")" || exit 9

    # Lock
    if [[ -e "$LOCK_FILE" ]]
    then
        echo "Already getting data from pihole" >&2
        exit 2
    fi
    touch "$LOCK_FILE"
    trap "rm -rf $LOCK_FILE" EXIT HUP INT QUIT PIPE TERM

    local cpp_involts cpp_battvolts cpp_loadwatt cpp_capacity runtimeHour runtimeMinute cpp_runtime cpp_loadpercent


        get_ups_info_cpp() {
                #-- Cyber Power Panel --

                #Pull data from the Cyber Power Panel.
                cpp_json_data=$(curl -s http://$cpp_server:3052/agent/ppbe.js/init_status.js)

                #input voltage
                cpp_involts=$(echo $cpp_json_data | grep -oP '(?<="voltage":")[^."]*' | head -1)

                #battery voltage
                cpp_battvolts=$(echo $cpp_json_data | grep -oP '(?<="voltage":")[^."]*' | tail -1)

                #Load(Watts)
                cpp_loadwatt=$(echo $cpp_json_data | grep -oP '(?<="watt":)[^,]*' | head -1)

                #Capacity %
                cpp_capacity=$(echo $cpp_json_data | grep -oP '(?<="capacity":)[^,]*' | head -1)

                #Runtime
                runtimeHour=$(echo $cpp_json_data | grep -oP '(?<="runtimeHour":)[^,]*' | head -1)
                runtimeMinute=$(echo $cpp_json_data | grep -oP '(?<="runtimeMinute":)[^,]*' | head -1)
                cpp_runtime=$(($runtimeHour*60+$runtimeMinute))

                #Load %
                cpp_loadpercent=$(echo $cpp_json_data | grep -oP '(?<="load":)[^,]*' | head -1)
        }

    get_ups_info_cpp

    {
                echo "CPP UPS Battery Voltage: $cpp_battvolts"
                echo "CPP UPS Battery Charge %: $cpp_capacity"
                echo "CPP UPS Load %: $cpp_loadpercent %"
                echo "CPP UPS Load Watts: $cpp_loadwatt"
                echo "CPP UPS Input Voltage: $cpp_involts"
                echo "CPP UPS Runtime: $cpp_runtime"
    } > "$CACHE_FILE"

    # Make sure to remove the lock file (may be redundant)
    rm -rf "$LOCK_FILE"
}

case "$1" in
    -c|--cached)
        cat "$CACHE_FILE"
        ;;
    -bv|--battery_voltage)
        awk '/CPP UPS Battery Voltage/ { print $5 }' "$CACHE_FILE"
        ;;
    -bc|--battery_charge_percent)
        awk '/CPP UPS Battery Charge %/ { print $6 }' "$CACHE_FILE"
        ;;
    -ulp|--ups_load_percent)
        awk '/CPP UPS Load %/ { print $5 }' "$CACHE_FILE"
        ;;
    -ulw|--ups_load_watts)
        awk '/CPP UPS Load Watts/ { print $5 }' "$CACHE_FILE"
        ;;
    -uiv|--ups_input_volts)
        awk '/CPP UPS Input Voltage/ { print $5 }' "$CACHE_FILE"
        ;;
    -urt|--ups_runtime)
        awk '/CPP UPS Runtime/ { print $4 }' "$CACHE_FILE"
        ;;
    -f|--force)
        rm -rf "$LOCK_FILE"
        run_ups_query
        ;;
    *)
        run_ups_query
        ;;
esac