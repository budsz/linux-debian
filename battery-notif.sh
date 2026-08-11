#!/usr/bin/dash

BATPER="$(cat /sys/class/power_supply/BAT0/capacity)"
BATSTA="$(cat /sys/class/power_supply/BAT0/status)"

if [ "$BATPER" -le 20 ] && [ "$BATSTA" = "Discharging" ]; then
    export DISPLAY=:0
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

    /usr/bin/notify-send -u critical "BATTERY LOW" "Please Connect to Charger! ($BATPER% - $BATSTA)"
fi
