#!/bin/bash
PID_FILE="/tmp/imv_albumart.pid"
IMAGE_PATH="/tmp/waybar_mpris_art.png"

if [ -f $PID_FILE ] && kill -0 $(cat $PID_FILE) 2> /dev/null; then
    kill $(cat $PID_FILE)
    rm $PID_FILE
else
    # Added '-s none' to prevent scaling
    setsid imv  scaling full -H 300 -W 300 "$IMAGE_PATH" &
    echo $! > $PID_FILE
fi
