#!/bin/bash
CACHE_PATH="/tmp/waybar_mpris_art.png"
URL_CACHE="/tmp/waybar_mpris_art.url"
MAX_TIME=3

# Check player status first
PLAYER_STATUS=$(playerctl status 2>/dev/null)

if [[ "$PLAYER_STATUS" != "Playing" && "$PLAYER_STATUS" != "Paused" ]]; then
    # No player active: delete the cached image and URL cache
    rm -f "$CACHE_PATH" "$URL_CACHE" 
    echo "" # Output empty line so Waybar shows nothing
    exit 0
fi

# Continue with the rest of your optimization logic if a player is active
ART_URL=$(playerctl metadata --format '{{mpris:artUrl}}' 2>/dev/null)
LAST_URL=$(cat "$URL_CACHE" 2>/dev/null)

if [ "$ART_URL" = "$LAST_URL" ]; then
    if [ -f "$CACHE_PATH" ]; then
        echo "$CACHE_PATH"
        exit 0
    fi
fi

# Store the current URL for the next run
echo "$ART_URL" > "$URL_CACHE"

# Handle Image Fetch (remaining logic unchanged)
if [[ "$ART_URL" == file://* ]]; then
    LOCAL_PATH=$(echo "$ART_URL" | sed 's/file:\/\///')
    if [ -f "$LOCAL_PATH" ]; then
        cp -f "$LOCAL_PATH" "$CACHE_PATH"
        echo "$CACHE_PATH"
        exit 0
    fi
elif [[ "$ART_URL" == http* ]]; then
    if curl -s -f --max-time "$MAX_TIME" -o "$CACHE_PATH" "$ART_URL"; then
        echo "$CACHE_PATH"
        exit 0
    fi
fi

# Fallback: If art download failed but a player is still active
echo ""
