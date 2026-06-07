#!/usr/bin/env bash
# Enable natural scrolling on touchpad, if present.

DEVICE_NAME="VEN_27C6:00 27C6:0F60 Touchpad"
PROP_NAME="libinput Natural Scrolling Enabled"

# Find device ID by name (tolerant if missing)
DEVICE_ID=$(xinput list --id-only "$DEVICE_NAME" 2>/dev/null)

# If device not found, just exit quietly
if [ -z "$DEVICE_ID" ]; then
    exit 0
fi

# Find the property ID for natural scrolling
PROP_ID=$(xinput list-props "$DEVICE_ID" \
    | awk -F'[()]' -v prop="$PROP_NAME" '$1 ~ prop {print $2; exit}')

# If property not found, also exit quietly
if [ -z "$PROP_ID" ]; then
    exit 0
fi

# Enable natural scrolling; ignore errors
xinput set-prop "$DEVICE_ID" "$PROP_ID" 1 2>/dev/null || true
