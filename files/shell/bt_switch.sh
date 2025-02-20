#!/bin/bash

BT_DEVICE="bluez_card.7C_F3_4D_7D_E7_FB"

CURRENT_PROFILE=$(pactl list cards | grep -A 20 "$BT_DEVICE" | grep "Active Profile" | awk -F ': ' '{print $2}')

echo "Current Profile: $CURRENT_PROFILE"

if [[ "$CURRENT_PROFILE" == *"a2dp_sink"* ]]; then
    echo "Switching to Hands-Free (HFP/HSP)"
    pactl set-card-profile "$BT_DEVICE" handsfree_head_unit
elif [[ "$CURRENT_PROFILE" == *"handsfree_head_unit"* ]]; then
    echo "Switching to A2DP Sink (High Fidelity)"
    pactl set-card-profile "$BT_DEVICE" a2dp_sink
else
    echo "Unknown profile or profile not available. Current profile is: $CURRENT_PROFILE"
    echo "Please check your device status."
fi
