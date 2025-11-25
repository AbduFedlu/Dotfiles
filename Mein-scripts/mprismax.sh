#!/bin/bash
# Path to cache the downloaded raw image
CACHE_RAW="/tmp/waybar_mpris_art_raw.png"

# Get metadata and URL safely
METADATA=$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)
ART_URL=$(playerctl metadata --format '{{mpris:artUrl}}' 2>/dev/null)

LOCAL_PATH=""

# 1. Handle Art Caching
if [[ "$ART_URL" == file://* ]]; then
    LOCAL_PATH=$(echo "$ART_URL" | sed 's/file:\/\///')
elif [[ "$ART_URL" == http* ]]; then
    # Download with timeout to prevent hanging
    if curl -s -f --max-time 3 -o "$CACHE_RAW" "$ART_URL"; then
        LOCAL_PATH="$CACHE_RAW"
    fi
fi

# 2. Generate JSON Output
if [ -n "$METADATA" ]; then
    # Sanitize metadata for JSON (escape quotes, backslashes, newlines)
    CLEAN_METADATA=$(echo "$METADATA" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/&/&amp;/g')
    
    # Text for the bar (uses proper Pango quotes)
    TEXT_BAR="<span font_weight=\"bold\">${CLEAN_METADATA}</span>"
    
    if [ -f "$LOCAL_PATH" ]; then
        # Pango markup for tooltip (large image)
        LARGE_ART="<img src=\"$LOCAL_PATH\" height=\"200\" width=\"200\"\/>"
        
        # Manually build the JSON string using printf
        # FIX: The 'text' field only contains the song title for reliable rendering.
        printf '{"text": "%s", "tooltip": "%s\n%s", "class": "mpris-active"}\n' \
            "$TEXT_BAR" \
            "$LARGE_ART" \
            "$CLEAN_METADATA"
    else
        # If no image is found, output only the text
        printf '{"text": "%s", "tooltip": "%s", "class": "mpris-active"}\n' \
            "$TEXT_BAR" \
            "$CLEAN_METADATA"
    fi
else
    # Output valid empty JSON when no media is playing
    echo '{"text": " ", "tooltip": "", "class": "mpris-inactive"}'
fi
