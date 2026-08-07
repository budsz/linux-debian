#!/usr/bin/dash

BATPER="$(cat /sys/class/power_supply/BAT0/capacity)"

if [ "$BATPER" -le 43 ]; then
    notify-send "BATTERY LOW - Please Connect to Charger!"
fi
