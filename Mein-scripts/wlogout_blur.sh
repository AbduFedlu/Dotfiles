#!/bin/bash

# Define temporary file paths
IMAGE="/tmp/wlogout_shot.png"
BLURRED_IMAGE="/tmp/wlogout_shot_blurred.png"

# 1. Take screenshot
grim "$IMAGE"

# 2. Blur the screenshot (adjust '0x5' for blur intensity)
#    A sigma of 5 (the second number) gives a strong blur.
magick "$IMAGE" -blur 0x5 "$BLURRED_IMAGE"

# 3. Launch wlogout using the blurred image path
wlogout --protocol layer-shell
